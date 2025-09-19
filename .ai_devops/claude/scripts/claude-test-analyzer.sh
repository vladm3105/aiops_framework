#!/bin/bash

# Claude Test Analyzer Script
# Analyzes test coverage and identifies gaps using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/testing-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-analysis-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📊 Claude Test Analyzer - Starting coverage analysis..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    UNIT_TARGET=$(jq -r '.coverage_targets.unit' "$CONFIG_FILE" 2>/dev/null || echo "95")
    INTEGRATION_TARGET=$(jq -r '.coverage_targets.integration' "$CONFIG_FILE" 2>/dev/null || echo "85")
    E2E_TARGET=$(jq -r '.coverage_targets.e2e' "$CONFIG_FILE" 2>/dev/null || echo "75")
    TEST_DIRS=$(jq -r '.file_patterns.test_dirs[]' "$CONFIG_FILE" 2>/dev/null || echo "tests/")
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
else
    echo "⚠️  Warning: Config file not found, using defaults"
    UNIT_TARGET="95"
    INTEGRATION_TARGET="85"
    E2E_TARGET="75"
    TEST_DIRS="tests/"
    CLAUDE_MAX_TURNS="3"
fi

echo "🎯 Coverage targets: Unit ${UNIT_TARGET}%, Integration ${INTEGRATION_TARGET}%, E2E ${E2E_TARGET}%"

# Find source code files
echo "🔍 Discovering source files..."
find . -name "*.py" -not -path "./venv/*" -not -path "./.venv/*" -not -path "./.*" -not -path "./tests/*" -not -path "./test/*" > "$TEMP_DIR/source_files.txt" || true
find . -name "*.js" -not -path "./node_modules/*" -not -path "./.*" -not -path "./tests/*" -not -path "./test/*" >> "$TEMP_DIR/source_files.txt" || true
find . -name "*.ts" -not -path "./node_modules/*" -not -path "./.*" -not -path "./tests/*" -not -path "./test/*" >> "$TEMP_DIR/source_files.txt" || true

# Find test files
echo "🧪 Discovering test files..."
find . -name "*test*.py" -o -name "test_*.py" > "$TEMP_DIR/test_files.txt" || true
find . -name "*test*.js" -o -name "*.test.js" -o -name "*spec*.js" >> "$TEMP_DIR/test_files.txt" || true
find . -name "*test*.ts" -o -name "*.test.ts" -o -name "*spec*.ts" >> "$TEMP_DIR/test_files.txt" || true

SOURCE_COUNT=$(wc -l < "$TEMP_DIR/source_files.txt" 2>/dev/null || echo "0")
TEST_COUNT=$(wc -l < "$TEMP_DIR/test_files.txt" 2>/dev/null || echo "0")

echo "📈 Found $SOURCE_COUNT source files and $TEST_COUNT test files"

# Generate coverage report if coverage tools are available
COVERAGE_REPORT=""
if command -v pytest &> /dev/null && command -v coverage &> /dev/null; then
    echo "🔬 Running Python coverage analysis..."
    coverage run -m pytest . --tb=short 2>/dev/null || true
    coverage report --format=text > "$TEMP_DIR/python_coverage.txt" 2>/dev/null || true
    if [[ -f "$TEMP_DIR/python_coverage.txt" ]]; then
        COVERAGE_REPORT=$(cat "$TEMP_DIR/python_coverage.txt")
    fi
elif command -v npm &> /dev/null && [[ -f "package.json" ]]; then
    echo "🔬 Running JavaScript coverage analysis..."
    npm test -- --coverage --watchAll=false > "$TEMP_DIR/js_coverage.txt" 2>/dev/null || true
    if [[ -f "$TEMP_DIR/js_coverage.txt" ]]; then
        COVERAGE_REPORT=$(cat "$TEMP_DIR/js_coverage.txt")
    fi
fi

if [[ -z "$COVERAGE_REPORT" ]]; then
    COVERAGE_REPORT="Coverage analysis not available - no coverage tools found or configured"
fi

# Load coverage analysis prompt
COVERAGE_PROMPT=""
if [[ -f "$PROMPTS_DIR/coverage-analysis.txt" ]]; then
    COVERAGE_PROMPT=$(cat "$PROMPTS_DIR/coverage-analysis.txt")
else
    # Fallback prompt
    COVERAGE_PROMPT="Review test coverage for this codebase and identify improvements. Analyze functions without tests, missing edge case coverage, integration gaps, and suggest test improvements."
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$COVERAGE_PROMPT" | \
    sed "s/{unit_target}/$UNIT_TARGET/g" | \
    sed "s/{integration_target}/$INTEGRATION_TARGET/g" | \
    sed "s/{e2e_target}/$E2E_TARGET/g")

# Prepare file samples for analysis (limit to avoid token limits)
SOURCE_SAMPLES=""
if [[ -s "$TEMP_DIR/source_files.txt" ]]; then
    SOURCE_SAMPLES=$(head -20 "$TEMP_DIR/source_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -50 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

TEST_SAMPLES=""
if [[ -s "$TEMP_DIR/test_files.txt" ]]; then
    TEST_SAMPLES=$(head -10 "$TEMP_DIR/test_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -30 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

# Create input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Project Statistics:
- Source files: $SOURCE_COUNT
- Test files: $TEST_COUNT
- Test-to-source ratio: $(echo "scale=2; $TEST_COUNT / $SOURCE_COUNT" | bc 2>/dev/null || echo "N/A")

Current Coverage Report:
$COVERAGE_REPORT

Sample Source Files (first 20):
$SOURCE_SAMPLES

Sample Test Files (first 10):
$TEST_SAMPLES

Source Files List:
$(head -50 "$TEMP_DIR/source_files.txt")

Test Files List:
$(cat "$TEMP_DIR/test_files.txt")
EOF

echo "🤖 Analyzing coverage with Claude..."

# Analyze with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_analysis.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_analysis.json" ]]; then
    echo "❌ Error: Claude did not generate any analysis"
    exit 1
fi

echo "✅ Claude coverage analysis complete"

# Extract analysis from Claude's response
ANALYSIS_CONTENT=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_analysis.json")
RECOMMENDATIONS=$(echo "$ANALYSIS_CONTENT" | grep -A 20 -i "recommend" | head -20 || echo "No specific recommendations extracted")

# Create analysis report
cat > "$TEMP_DIR/coverage_analysis_report.md" << EOF
# Test Coverage Analysis Report

## Summary
- **Analyzed at**: $(date)
- **Source files**: $SOURCE_COUNT
- **Test files**: $TEST_COUNT
- **Test-to-source ratio**: $(echo "scale=2; $TEST_COUNT / $SOURCE_COUNT" | bc 2>/dev/null || echo "N/A")

## Coverage Targets
- **Unit tests**: ${UNIT_TARGET}%
- **Integration tests**: ${INTEGRATION_TARGET}%
- **End-to-end tests**: ${E2E_TARGET}%

## Current Coverage
\`\`\`
$COVERAGE_REPORT
\`\`\`

## Claude Analysis
$ANALYSIS_CONTENT

## Key Recommendations
$RECOMMENDATIONS

## Files Analyzed
### Source Files (Sample)
\`\`\`
$(head -20 "$TEMP_DIR/source_files.txt")
\`\`\`

### Test Files
\`\`\`
$(cat "$TEMP_DIR/test_files.txt")
\`\`\`
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../test_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/coverage_analysis_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_analysis.json" "$RESULTS_DIR/"

echo "📄 Analysis report saved to: $RESULTS_DIR/coverage_analysis_report.md"
echo "✨ Coverage analysis complete!"

# Calculate basic coverage metrics for GitHub Actions output
COVERAGE_PERCENTAGE="0"
if echo "$COVERAGE_REPORT" | grep -q "TOTAL"; then
    COVERAGE_PERCENTAGE=$(echo "$COVERAGE_REPORT" | grep "TOTAL" | awk '{print $4}' | sed 's/%//' || echo "0")
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "analysis_complete=true" >> "$GITHUB_OUTPUT"
    echo "source_files=$SOURCE_COUNT" >> "$GITHUB_OUTPUT"
    echo "test_files=$TEST_COUNT" >> "$GITHUB_OUTPUT"
    echo "coverage_percentage=$COVERAGE_PERCENTAGE" >> "$GITHUB_OUTPUT"
    echo "coverage_target=$UNIT_TARGET" >> "$GITHUB_OUTPUT"
    echo "analysis_report_path=$RESULTS_DIR/coverage_analysis_report.md" >> "$GITHUB_OUTPUT"
fi