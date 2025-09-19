#!/bin/bash

# Claude Test Reviewer Script
# Reviews generated tests for quality and completeness using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/testing-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-review-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🔍 Claude Test Reviewer - Starting test quality review..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    TEST_FRAMEWORKS=$(jq -r '.test_frameworks[]' "$CONFIG_FILE" 2>/dev/null || echo "pytest")
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
else
    echo "⚠️  Warning: Config file not found, using defaults"
    TEST_FRAMEWORKS="pytest"
    CLAUDE_MAX_TURNS="3"
fi

# Look for generated tests from previous steps
RESULTS_DIR="$CLAUDE_DIR/../../../test_results"
GENERATED_TESTS=""
TEST_FILES_TO_REVIEW=""

# Check if there are generated tests to review
if [[ -f "$RESULTS_DIR/test_content.txt" ]]; then
    GENERATED_TESTS=$(cat "$RESULTS_DIR/test_content.txt")
    echo "📝 Found generated tests to review"
else
    echo "ℹ️  No generated tests found, reviewing existing test files"
fi

# Find existing test files for review
find . -name "*test*.py" -o -name "test_*.py" > "$TEMP_DIR/python_test_files.txt" 2>/dev/null || true
find . -name "*test*.js" -o -name "*.test.js" -o -name "*spec*.js" > "$TEMP_DIR/js_test_files.txt" 2>/dev/null || true
find . -name "*test*.ts" -o -name "*.test.ts" -o -name "*spec*.ts" > "$TEMP_DIR/ts_test_files.txt" 2>/dev/null || true

# Combine all test files
cat "$TEMP_DIR/python_test_files.txt" "$TEMP_DIR/js_test_files.txt" "$TEMP_DIR/ts_test_files.txt" 2>/dev/null | sort | uniq > "$TEMP_DIR/all_test_files.txt"

TEST_FILE_COUNT=$(wc -l < "$TEMP_DIR/all_test_files.txt" 2>/dev/null || echo "0")
echo "🧪 Found $TEST_FILE_COUNT test files to review"

# Collect test content for review (limit to avoid token limits)
TEST_CONTENT_SAMPLE=""
if [[ -s "$TEMP_DIR/all_test_files.txt" ]]; then
    TEST_CONTENT_SAMPLE=$(head -10 "$TEMP_DIR/all_test_files.txt" | while read -r file; do
        if [[ -f "$file" && -s "$file" ]]; then
            echo "=== $file ==="
            head -100 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

# Prepare review prompt
REVIEW_PROMPT="You are a senior test engineer reviewing test code for quality, completeness, and best practices. 

Please analyze the following test code and provide:
1. **Quality Assessment**: Code structure, readability, maintainability
2. **Coverage Analysis**: Are all important scenarios tested?
3. **Best Practices**: Adherence to testing conventions and patterns
4. **Specific Improvements**: Actionable suggestions for enhancement
5. **Risk Assessment**: Potential issues or gaps in the test suite

Focus on:
- Test organization and naming
- Assertion quality and specificity
- Mock/stub usage appropriateness
- Edge case coverage
- Error handling tests
- Performance considerations
- Maintainability and DRY principles"

# Load custom review prompt if available
if [[ -f "$PROMPTS_DIR/test-review.txt" ]]; then
    REVIEW_PROMPT=$(cat "$PROMPTS_DIR/test-review.txt")
fi

# Prepare project context
PROJECT_CONTEXT=""
if [[ -f "CLAUDE.md" ]]; then
    PROJECT_CONTEXT=$(head -50 "CLAUDE.md")
fi

# Create input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$REVIEW_PROMPT

Test Framework: $TEST_FRAMEWORKS
Total Test Files: $TEST_FILE_COUNT

Project Context:
$PROJECT_CONTEXT

Generated Tests (if any):
$GENERATED_TESTS

Existing Test Files Sample (first 10 files):
$TEST_CONTENT_SAMPLE

Test Files List:
$(head -20 "$TEMP_DIR/all_test_files.txt")
EOF

echo "🤖 Reviewing tests with Claude..."

# Review tests with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_review.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_review.json" ]]; then
    echo "❌ Error: Claude did not generate any review"
    exit 1
fi

echo "✅ Claude test review complete"

# Extract review content
REVIEW_CONTENT=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_review.json")

# Extract specific sections if possible
QUALITY_ASSESSMENT=$(echo "$REVIEW_CONTENT" | sed -n '/Quality Assessment/,/Coverage Analysis/p' | head -n -1 || echo "See full review below")
COVERAGE_ANALYSIS=$(echo "$REVIEW_CONTENT" | sed -n '/Coverage Analysis/,/Best Practices/p' | head -n -1 || echo "See full review below")
RECOMMENDATIONS=$(echo "$REVIEW_CONTENT" | grep -A 10 -i "recommend\|improve\|suggest" | head -20 || echo "See full review for recommendations")

# Analyze test metrics
TOTAL_ASSERTIONS=$(grep -r "assert\|expect\|should" . --include="*test*" --include="*spec*" 2>/dev/null | wc -l || echo "0")
MOCK_USAGE=$(grep -r "mock\|stub\|spy" . --include="*test*" --include="*spec*" 2>/dev/null | wc -l || echo "0")
SETUP_TEARDOWN=$(grep -r "setUp\|tearDown\|beforeEach\|afterEach\|before\|after" . --include="*test*" --include="*spec*" 2>/dev/null | wc -l || echo "0")

# Calculate basic quality metrics
TEST_QUALITY_SCORE=0
if [[ $TEST_FILE_COUNT -gt 0 ]]; then
    # Basic scoring: files, assertions, setup/teardown usage
    ASSERTIONS_PER_FILE=$(echo "scale=1; $TOTAL_ASSERTIONS / $TEST_FILE_COUNT" | bc 2>/dev/null || echo "0")
    SETUP_RATIO=$(echo "scale=2; $SETUP_TEARDOWN / $TEST_FILE_COUNT" | bc 2>/dev/null || echo "0")
    
    # Simple quality score (0-100)
    TEST_QUALITY_SCORE=$(echo "scale=0; ($ASSERTIONS_PER_FILE * 2) + ($SETUP_RATIO * 10) + ($MOCK_USAGE / 10)" | bc 2>/dev/null || echo "50")
    
    # Cap at 100
    if [[ $TEST_QUALITY_SCORE -gt 100 ]]; then
        TEST_QUALITY_SCORE=100
    fi
fi

# Create review report
cat > "$TEMP_DIR/test_review_report.md" << EOF
# Test Quality Review Report

## Summary
- **Reviewed at**: $(date)
- **Test files analyzed**: $TEST_FILE_COUNT
- **Total assertions**: $TOTAL_ASSERTIONS
- **Mock/stub usage**: $MOCK_USAGE instances
- **Setup/teardown patterns**: $SETUP_TEARDOWN instances
- **Quality score**: ${TEST_QUALITY_SCORE}/100

## Test Metrics
- **Assertions per file**: $(echo "scale=1; $TOTAL_ASSERTIONS / $TEST_FILE_COUNT" | bc 2>/dev/null || echo "N/A")
- **Setup/teardown ratio**: $(echo "scale=2; $SETUP_TEARDOWN / $TEST_FILE_COUNT" | bc 2>/dev/null || echo "N/A")
- **Test frameworks**: $TEST_FRAMEWORKS

## Claude Quality Assessment
$QUALITY_ASSESSMENT

## Coverage Analysis
$COVERAGE_ANALYSIS

## Key Recommendations
$RECOMMENDATIONS

## Full Claude Review
$REVIEW_CONTENT

## Test Files Analyzed
\`\`\`
$(head -30 "$TEMP_DIR/all_test_files.txt")
$(if [[ $TEST_FILE_COUNT -gt 30 ]]; then echo "... and $((TEST_FILE_COUNT - 30)) more files"; fi)
\`\`\`

## Action Items
Based on the review, consider:
1. Implementing any specific improvements suggested by Claude
2. Adding missing test scenarios identified in the analysis
3. Improving test organization and naming conventions
4. Enhancing assertion specificity and error messages
5. Adding more edge case and error handling tests
EOF

# Save outputs to shared location
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/test_review_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_review.json" "$RESULTS_DIR/"

echo "📄 Review report saved to: $RESULTS_DIR/test_review_report.md"
echo "✨ Test review complete!"

# Determine review status
REVIEW_STATUS="good"
if [[ $TEST_QUALITY_SCORE -lt 30 ]]; then
    REVIEW_STATUS="needs_improvement"
elif [[ $TEST_QUALITY_SCORE -lt 60 ]]; then
    REVIEW_STATUS="fair"
elif [[ $TEST_QUALITY_SCORE -ge 80 ]]; then
    REVIEW_STATUS="excellent"
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "review_complete=true" >> "$GITHUB_OUTPUT"
    echo "test_files_count=$TEST_FILE_COUNT" >> "$GITHUB_OUTPUT"
    echo "total_assertions=$TOTAL_ASSERTIONS" >> "$GITHUB_OUTPUT"
    echo "quality_score=$TEST_QUALITY_SCORE" >> "$GITHUB_OUTPUT"
    echo "review_status=$REVIEW_STATUS" >> "$GITHUB_OUTPUT"
    echo "review_report_path=$RESULTS_DIR/test_review_report.md" >> "$GITHUB_OUTPUT"
fi