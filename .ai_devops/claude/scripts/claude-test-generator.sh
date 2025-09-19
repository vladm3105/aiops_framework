#!/bin/bash

# Claude Test Generator Script
# Analyzes git diff and generates unit tests using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/testing-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-testing-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🚀 Claude Test Generator - Starting analysis..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    TEST_FRAMEWORKS=$(jq -r '.test_frameworks[]' "$CONFIG_FILE" 2>/dev/null || echo "pytest")
    COVERAGE_TARGET=$(jq -r '.coverage_targets.unit' "$CONFIG_FILE" 2>/dev/null || echo "95")
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
    CLAUDE_OUTPUT_FORMAT=$(jq -r '.claude_settings.output_format' "$CONFIG_FILE" 2>/dev/null || echo "json")
else
    echo "⚠️  Warning: Config file not found, using defaults"
    TEST_FRAMEWORKS="pytest"
    COVERAGE_TARGET="95"
    CLAUDE_MAX_TURNS="3"
    CLAUDE_OUTPUT_FORMAT="json"
fi

# Get the base branch (default to main if not specified)
BASE_BRANCH="${GITHUB_BASE_REF:-main}"
echo "📊 Analyzing changes against base branch: $BASE_BRANCH"

# Generate git diff
git diff origin/$BASE_BRANCH...HEAD > "$TEMP_DIR/git_diff.txt"

if [[ ! -s "$TEMP_DIR/git_diff.txt" ]]; then
    echo "ℹ️  No changes detected. Exiting."
    exit 0
fi

# Get list of changed files
git diff --name-only origin/$BASE_BRANCH...HEAD | grep -E '\.(py|js|ts|jsx|tsx)$' > "$TEMP_DIR/changed_files.txt" || true

if [[ ! -s "$TEMP_DIR/changed_files.txt" ]]; then
    echo "ℹ️  No relevant code files changed. Exiting."
    exit 0
fi

echo "📁 Changed files:"
cat "$TEMP_DIR/changed_files.txt"

# Load unit test generation prompt
UNIT_TEST_PROMPT=""
if [[ -f "$PROMPTS_DIR/unit-test-generation.txt" ]]; then
    UNIT_TEST_PROMPT=$(cat "$PROMPTS_DIR/unit-test-generation.txt")
else
    # Fallback prompt
    UNIT_TEST_PROMPT="You are a senior test engineer. Analyze these code changes and generate comprehensive unit tests. Include happy path scenarios, edge cases, error conditions, and proper assertions. Follow project testing conventions."
fi

# Prepare context for Claude
PROJECT_CONTEXT=""
if [[ -f "CLAUDE.md" ]]; then
    PROJECT_CONTEXT=$(head -50 "CLAUDE.md")
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$UNIT_TEST_PROMPT" | \
    sed "s/{test_framework}/$TEST_FRAMEWORKS/g" | \
    sed "s/{coverage_target}/$COVERAGE_TARGET/g")

# Create input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Code changes to analyze:
$(cat "$TEMP_DIR/git_diff.txt")

Project context:
$PROJECT_CONTEXT

Changed files:
$(cat "$TEMP_DIR/changed_files.txt")
EOF

echo "🤖 Generating tests with Claude..."

# Generate tests using Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "$CLAUDE_OUTPUT_FORMAT" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_output.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_output.json" ]]; then
    echo "❌ Error: Claude did not generate any output"
    exit 1
fi

echo "✅ Claude analysis complete"

# Parse Claude output and create test files
OUTPUT_DIR="$TEMP_DIR/generated_tests"
mkdir -p "$OUTPUT_DIR"

# Extract test content from Claude's JSON response
if [[ "$CLAUDE_OUTPUT_FORMAT" == "json" ]]; then
    # Parse JSON response and extract test code
    jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_output.json" > "$TEMP_DIR/test_content.txt"
else
    cp "$TEMP_DIR/claude_output.json" "$TEMP_DIR/test_content.txt"
fi

# Create summary report
cat > "$TEMP_DIR/generation_report.md" << EOF
# Test Generation Report

## Summary
- **Generated at**: $(date)
- **Base branch**: $BASE_BRANCH
- **Files analyzed**: $(wc -l < "$TEMP_DIR/changed_files.txt")
- **Test framework**: $TEST_FRAMEWORKS
- **Coverage target**: ${COVERAGE_TARGET}%

## Changed Files
\`\`\`
$(cat "$TEMP_DIR/changed_files.txt")
\`\`\`

## Generated Tests
\`\`\`
$(head -100 "$TEMP_DIR/test_content.txt")
\`\`\`

## Claude Analysis
$(if [[ "$CLAUDE_OUTPUT_FORMAT" == "json" ]]; then jq -r '.analysis // .reasoning // "Analysis not available"' "$TEMP_DIR/claude_output.json" 2>/dev/null || echo "Analysis not available"; else echo "Raw output format used"; fi)
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../test_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/generation_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/test_content.txt" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_output.json" "$RESULTS_DIR/"

echo "📄 Reports saved to: $RESULTS_DIR"
echo "✨ Test generation complete!"

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "tests_generated=true" >> "$GITHUB_OUTPUT"
    echo "changed_files=$(wc -l < "$TEMP_DIR/changed_files.txt")" >> "$GITHUB_OUTPUT"
    echo "report_path=$RESULTS_DIR/generation_report.md" >> "$GITHUB_OUTPUT"
fi