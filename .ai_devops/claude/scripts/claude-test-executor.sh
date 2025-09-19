#!/bin/bash

# Claude Test Executor Script
# Runs tests and analyzes failures using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/testing-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-execution-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🧪 Claude Test Executor - Starting test execution..."

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

# Initialize test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_OUTPUT=""
FAILURE_DETAILS=""

# Run Python tests with pytest
if echo "$TEST_FRAMEWORKS" | grep -q "pytest" && command -v pytest &> /dev/null; then
    echo "🐍 Running Python tests with pytest..."
    
    if pytest --tb=short --json-report --json-report-file="$TEMP_DIR/pytest-report.json" > "$TEMP_DIR/pytest-output.txt" 2>&1; then
        echo "✅ All Python tests passed"
        PYTEST_EXIT_CODE=0
    else
        echo "❌ Some Python tests failed"
        PYTEST_EXIT_CODE=$?
    fi
    
    # Extract test metrics from pytest JSON report
    if [[ -f "$TEMP_DIR/pytest-report.json" ]]; then
        PYTEST_TOTAL=$(jq -r '.summary.total // 0' "$TEMP_DIR/pytest-report.json")
        PYTEST_PASSED=$(jq -r '.summary.passed // 0' "$TEMP_DIR/pytest-report.json")
        PYTEST_FAILED=$(jq -r '.summary.failed // 0' "$TEMP_DIR/pytest-report.json")
        
        TESTS_RUN=$((TESTS_RUN + PYTEST_TOTAL))
        TESTS_PASSED=$((TESTS_PASSED + PYTEST_PASSED))
        TESTS_FAILED=$((TESTS_FAILED + PYTEST_FAILED))
    fi
    
    TEST_OUTPUT="$TEST_OUTPUT\n=== Python Test Results ===\n$(cat "$TEMP_DIR/pytest-output.txt")\n"
    
    # Extract failure details
    if [[ $PYTEST_EXIT_CODE -ne 0 ]]; then
        PYTEST_FAILURES=$(grep -A 10 -B 2 "FAILED\|ERROR" "$TEMP_DIR/pytest-output.txt" || echo "No specific failure details found")
        FAILURE_DETAILS="$FAILURE_DETAILS\n=== Python Test Failures ===\n$PYTEST_FAILURES\n"
    fi
fi

# Run JavaScript/TypeScript tests with npm
if [[ -f "package.json" ]] && command -v npm &> /dev/null; then
    echo "📜 Running JavaScript/TypeScript tests with npm..."
    
    if npm test > "$TEMP_DIR/npm-test-output.txt" 2>&1; then
        echo "✅ All JavaScript/TypeScript tests passed"
        NPM_EXIT_CODE=0
    else
        echo "❌ Some JavaScript/TypeScript tests failed"
        NPM_EXIT_CODE=$?
    fi
    
    # Extract basic metrics from npm test output
    NPM_OUTPUT=$(cat "$TEMP_DIR/npm-test-output.txt")
    NPM_TOTAL=$(echo "$NPM_OUTPUT" | grep -oE '[0-9]+ (passing|failing|test)' | head -1 | grep -oE '[0-9]+' || echo "0")
    NPM_PASSED=$(echo "$NPM_OUTPUT" | grep -oE '[0-9]+ passing' | grep -oE '[0-9]+' || echo "0")
    NPM_FAILED=$(echo "$NPM_OUTPUT" | grep -oE '[0-9]+ failing' | grep -oE '[0-9]+' || echo "0")
    
    TESTS_RUN=$((TESTS_RUN + NPM_TOTAL))
    TESTS_PASSED=$((TESTS_PASSED + NPM_PASSED))
    TESTS_FAILED=$((TESTS_FAILED + NPM_FAILED))
    
    TEST_OUTPUT="$TEST_OUTPUT\n=== JavaScript/TypeScript Test Results ===\n$NPM_OUTPUT\n"
    
    # Extract failure details
    if [[ $NPM_EXIT_CODE -ne 0 ]]; then
        NPM_FAILURES=$(echo "$NPM_OUTPUT" | grep -A 5 -B 5 "failing\|error\|✗" || echo "No specific failure details found")
        FAILURE_DETAILS="$FAILURE_DETAILS\n=== JavaScript/TypeScript Test Failures ===\n$NPM_FAILURES\n"
    fi
fi

# Run any additional test commands
if [[ -f "Makefile" ]] && grep -q "test" "Makefile"; then
    echo "🔨 Running Makefile tests..."
    if make test > "$TEMP_DIR/make-test-output.txt" 2>&1; then
        echo "✅ Makefile tests passed"
    else
        echo "❌ Makefile tests failed"
        MAKE_OUTPUT=$(cat "$TEMP_DIR/make-test-output.txt")
        TEST_OUTPUT="$TEST_OUTPUT\n=== Makefile Test Results ===\n$MAKE_OUTPUT\n"
    fi
fi

# Calculate success rate
SUCCESS_RATE=0
if [[ $TESTS_RUN -gt 0 ]]; then
    SUCCESS_RATE=$(echo "scale=2; $TESTS_PASSED * 100 / $TESTS_RUN" | bc 2>/dev/null || echo "0")
fi

echo "📊 Test Execution Summary:"
echo "   Total tests: $TESTS_RUN"
echo "   Passed: $TESTS_PASSED"
echo "   Failed: $TESTS_FAILED"
echo "   Success rate: ${SUCCESS_RATE}%"

# Analyze failures with Claude if there are any
CLAUDE_ANALYSIS=""
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo "🤖 Analyzing test failures with Claude..."
    
    # Load failure analysis prompt
    FAILURE_PROMPT=""
    if [[ -f "$PROMPTS_DIR/failure-analysis.txt" ]]; then
        FAILURE_PROMPT=$(cat "$PROMPTS_DIR/failure-analysis.txt")
    else
        # Fallback prompt
        FAILURE_PROMPT="Analyze these test failures and provide actionable fixes. For each failure, provide root cause analysis, specific code correction suggestions, test improvement recommendations, and prevention strategies."
    fi
    
    # Prepare input for Claude
    cat > "$TEMP_DIR/claude_input.txt" << EOF
$FAILURE_PROMPT

Test Execution Summary:
- Total tests: $TESTS_RUN
- Passed: $TESTS_PASSED
- Failed: $TESTS_FAILED
- Success rate: ${SUCCESS_RATE}%

Test Output:
$(echo -e "$TEST_OUTPUT" | tail -1000)

Failure Details:
$(echo -e "$FAILURE_DETAILS" | tail -500)

Project Context:
$(if [[ -f "CLAUDE.md" ]]; then head -30 "CLAUDE.md"; fi)
EOF
    
    # Analyze failures with Claude CLI
    claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
        --output-format "json" \
        --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_failure_analysis.json"
    
    if [[ -s "$TEMP_DIR/claude_failure_analysis.json" ]]; then
        CLAUDE_ANALYSIS=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_failure_analysis.json")
        echo "✅ Claude failure analysis complete"
    else
        echo "⚠️  Claude failure analysis did not produce output"
        CLAUDE_ANALYSIS="Claude analysis failed to generate output"
    fi
else
    echo "🎉 All tests passed - no failure analysis needed"
    CLAUDE_ANALYSIS="All tests passed successfully. No failures to analyze."
fi

# Create execution report
cat > "$TEMP_DIR/test_execution_report.md" << EOF
# Test Execution Report

## Summary
- **Executed at**: $(date)
- **Total tests**: $TESTS_RUN
- **Passed**: $TESTS_PASSED
- **Failed**: $TESTS_FAILED
- **Success rate**: ${SUCCESS_RATE}%
- **Test frameworks**: $TEST_FRAMEWORKS

## Test Results
$(echo -e "$TEST_OUTPUT")

## Failure Analysis
$(if [[ $TESTS_FAILED -gt 0 ]]; then echo -e "$FAILURE_DETAILS"; else echo "No failures to report"; fi)

## Claude Analysis
$CLAUDE_ANALYSIS

## Recommendations
$(if [[ $TESTS_FAILED -gt 0 ]]; then echo "See Claude analysis above for specific recommendations"; else echo "Continue maintaining good test coverage and consider adding more edge case tests"; fi)
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../test_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/test_execution_report.md" "$RESULTS_DIR/"
if [[ -f "$TEMP_DIR/claude_failure_analysis.json" ]]; then
    cp "$TEMP_DIR/claude_failure_analysis.json" "$RESULTS_DIR/"
fi

echo "📄 Execution report saved to: $RESULTS_DIR/test_execution_report.md"
echo "✨ Test execution complete!"

# Determine overall status
OVERALL_STATUS="success"
if [[ $TESTS_FAILED -gt 0 ]]; then
    OVERALL_STATUS="failure"
elif [[ $TESTS_RUN -eq 0 ]]; then
    OVERALL_STATUS="no_tests"
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "execution_complete=true" >> "$GITHUB_OUTPUT"
    echo "tests_run=$TESTS_RUN" >> "$GITHUB_OUTPUT"
    echo "tests_passed=$TESTS_PASSED" >> "$GITHUB_OUTPUT"
    echo "tests_failed=$TESTS_FAILED" >> "$GITHUB_OUTPUT"
    echo "success_rate=$SUCCESS_RATE" >> "$GITHUB_OUTPUT"
    echo "overall_status=$OVERALL_STATUS" >> "$GITHUB_OUTPUT"
    echo "execution_report_path=$RESULTS_DIR/test_execution_report.md" >> "$GITHUB_OUTPUT"
fi

# Exit with appropriate code
if [[ "$OVERALL_STATUS" == "failure" ]]; then
    exit 1
else
    exit 0
fi