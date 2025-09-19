#!/bin/bash

# Generate PR Comment Script
# Creates a comprehensive PR comment based on all Claude testing results

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$CLAUDE_DIR/../../../test_results"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
TEMP_DIR="/tmp/claude-pr-comment-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📝 Generating PR comment from Claude testing results..."

# Check if we have results to work with
if [[ ! -d "$RESULTS_DIR" ]]; then
    echo "⚠️  No results directory found, creating minimal comment"
    mkdir -p "$RESULTS_DIR"
fi

# Initialize variables with defaults
TESTS_GENERATED="false"
CHANGED_FILES="0"
SOURCE_FILES="0"
TEST_FILES="0"
COVERAGE_PERCENTAGE="N/A"
COVERAGE_TARGET="95"
TESTS_RUN="0"
TESTS_PASSED="0"
TESTS_FAILED="0"
SUCCESS_RATE="N/A"
OVERALL_STATUS="unknown"
QUALITY_SCORE="N/A"
REVIEW_STATUS="unknown"

# Extract data from GitHub Actions outputs if available
if [[ -n "$GITHUB_OUTPUT" && -f "$GITHUB_OUTPUT" ]]; then
    # Read previous step outputs
    while IFS='=' read -r key value; do
        case $key in
            tests_generated) TESTS_GENERATED="$value" ;;
            changed_files) CHANGED_FILES="$value" ;;
            source_files) SOURCE_FILES="$value" ;;
            test_files) TEST_FILES="$value" ;;
            coverage_percentage) COVERAGE_PERCENTAGE="$value" ;;
            coverage_target) COVERAGE_TARGET="$value" ;;
            tests_run) TESTS_RUN="$value" ;;
            tests_passed) TESTS_PASSED="$value" ;;
            tests_failed) TESTS_FAILED="$value" ;;
            success_rate) SUCCESS_RATE="$value" ;;
            overall_status) OVERALL_STATUS="$value" ;;
            quality_score) QUALITY_SCORE="$value" ;;
            review_status) REVIEW_STATUS="$value" ;;
        esac
    done < "$GITHUB_OUTPUT"
fi

# Determine overall status emoji and message
STATUS_EMOJI="🤖"
STATUS_MESSAGE="Analysis Complete"

case $OVERALL_STATUS in
    "success")
        STATUS_EMOJI="✅"
        STATUS_MESSAGE="All Tests Passed"
        ;;
    "failure")
        STATUS_EMOJI="❌"
        STATUS_MESSAGE="Some Tests Failed"
        ;;
    "no_tests")
        STATUS_EMOJI="⚠️"
        STATUS_MESSAGE="No Tests Found"
        ;;
esac

# Determine coverage status
COVERAGE_STATUS="✅"
if [[ "$COVERAGE_PERCENTAGE" != "N/A" ]] && [[ "$COVERAGE_PERCENTAGE" != "" ]]; then
    if (( $(echo "$COVERAGE_PERCENTAGE < $COVERAGE_TARGET" | bc -l 2>/dev/null || echo "0") )); then
        COVERAGE_STATUS="⚠️"
    fi
fi

# Determine quality status
QUALITY_STATUS="✅"
case $REVIEW_STATUS in
    "needs_improvement")
        QUALITY_STATUS="❌"
        ;;
    "fair")
        QUALITY_STATUS="⚠️"
        ;;
    "good"|"excellent")
        QUALITY_STATUS="✅"
        ;;
esac

# Read report summaries
GENERATION_SUMMARY=""
if [[ -f "$RESULTS_DIR/generation_report.md" ]]; then
    GENERATION_SUMMARY=$(head -20 "$RESULTS_DIR/generation_report.md" | tail -15)
fi

COVERAGE_SUMMARY=""
if [[ -f "$RESULTS_DIR/coverage_analysis_report.md" ]]; then
    COVERAGE_SUMMARY=$(grep -A 5 "## Claude Analysis" "$RESULTS_DIR/coverage_analysis_report.md" | head -10 | tail -8 || echo "See full coverage report")
fi

EXECUTION_SUMMARY=""
if [[ -f "$RESULTS_DIR/test_execution_report.md" ]]; then
    EXECUTION_SUMMARY=$(grep -A 3 "## Summary" "$RESULTS_DIR/test_execution_report.md" | tail -3 || echo "See full execution report")
fi

REVIEW_SUMMARY=""
if [[ -f "$RESULTS_DIR/test_review_report.md" ]]; then
    REVIEW_SUMMARY=$(grep -A 5 "## Key Recommendations" "$RESULTS_DIR/test_review_report.md" | head -10 | tail -8 || echo "See full review report")
fi

# Create detailed report content
DETAILED_REPORT=""
if [[ -f "$RESULTS_DIR/generation_report.md" ]]; then
    DETAILED_REPORT="$DETAILED_REPORT\n### 🔧 Test Generation Report\n$(cat "$RESULTS_DIR/generation_report.md")\n"
fi
if [[ -f "$RESULTS_DIR/coverage_analysis_report.md" ]]; then
    DETAILED_REPORT="$DETAILED_REPORT\n### 📊 Coverage Analysis Report\n$(cat "$RESULTS_DIR/coverage_analysis_report.md")\n"
fi
if [[ -f "$RESULTS_DIR/test_execution_report.md" ]]; then
    DETAILED_REPORT="$DETAILED_REPORT\n### 🧪 Test Execution Report\n$(cat "$RESULTS_DIR/test_execution_report.md")\n"
fi
if [[ -f "$RESULTS_DIR/test_review_report.md" ]]; then
    DETAILED_REPORT="$DETAILED_REPORT\n### 🔍 Test Quality Review\n$(cat "$RESULTS_DIR/test_review_report.md")\n"
fi

# Load PR comment template
PR_TEMPLATE=""
if [[ -f "$TEMPLATES_DIR/pr-comment-template.md" ]]; then
    PR_TEMPLATE=$(cat "$TEMPLATES_DIR/pr-comment-template.md")
else
    # Fallback template
    PR_TEMPLATE='## 🤖 Claude Code Testing Results

**Status**: {status_emoji} {status_message}
**Test Coverage**: {coverage_status} {coverage}% (Target: {target}%)
**Tests Executed**: {tests_run} ({tests_passed} passed, {tests_failed} failed)
**Quality Score**: {quality_status} {quality_score}/100

### 📊 Analysis Summary
{test_analysis_summary}

### ✅ Key Findings
{key_findings}

### 🎯 Recommendations
{recommendations}

<details>
<summary>📝 Full Reports</summary>

{detailed_report}
</details>

---
*Generated by Claude Code Testing Framework*'
fi

# Prepare analysis summary
ANALYSIS_SUMMARY="- **Files analyzed**: $CHANGED_FILES changed, $SOURCE_FILES source files, $TEST_FILES test files
- **Test generation**: $(if [[ "$TESTS_GENERATED" == "true" ]]; then echo "✅ New tests generated"; else echo "ℹ️ No new tests generated"; fi)
- **Test execution**: $TESTS_RUN tests run with ${SUCCESS_RATE}% success rate
- **Quality assessment**: $REVIEW_STATUS quality rating"

# Prepare key findings
KEY_FINDINGS=""
if [[ "$TESTS_FAILED" -gt 0 ]]; then
    KEY_FINDINGS="$KEY_FINDINGS\n- ❌ $TESTS_FAILED test(s) are currently failing"
fi
if [[ "$COVERAGE_PERCENTAGE" != "N/A" && "$COVERAGE_PERCENTAGE" != "" ]]; then
    if (( $(echo "$COVERAGE_PERCENTAGE < $COVERAGE_TARGET" | bc -l 2>/dev/null || echo "0") )); then
        KEY_FINDINGS="$KEY_FINDINGS\n- ⚠️ Test coverage (${COVERAGE_PERCENTAGE}%) is below target (${COVERAGE_TARGET}%)"
    else
        KEY_FINDINGS="$KEY_FINDINGS\n- ✅ Test coverage meets target requirements"
    fi
fi
if [[ "$REVIEW_STATUS" == "needs_improvement" ]]; then
    KEY_FINDINGS="$KEY_FINDINGS\n- 🔧 Test quality needs improvement (score: ${QUALITY_SCORE}/100)"
elif [[ "$REVIEW_STATUS" == "excellent" ]]; then
    KEY_FINDINGS="$KEY_FINDINGS\n- 🌟 Excellent test quality detected"
fi

if [[ -z "$KEY_FINDINGS" ]]; then
    KEY_FINDINGS="- ✅ All metrics look good"
fi

# Prepare recommendations
RECOMMENDATIONS=""
if [[ "$TESTS_FAILED" -gt 0 ]]; then
    RECOMMENDATIONS="$RECOMMENDATIONS\n- 🔧 Fix failing tests before merging"
fi
if [[ "$COVERAGE_PERCENTAGE" != "N/A" && "$COVERAGE_PERCENTAGE" != "" ]]; then
    if (( $(echo "$COVERAGE_PERCENTAGE < $COVERAGE_TARGET" | bc -l 2>/dev/null || echo "0") )); then
        RECOMMENDATIONS="$RECOMMENDATIONS\n- 📈 Add more tests to improve coverage"
    fi
fi
if [[ "$REVIEW_STATUS" == "needs_improvement" ]]; then
    RECOMMENDATIONS="$RECOMMENDATIONS\n- 🎯 Review Claude's suggestions for test quality improvements"
fi
if [[ "$TESTS_GENERATED" == "true" ]]; then
    RECOMMENDATIONS="$RECOMMENDATIONS\n- 📝 Review and integrate generated tests"
fi

if [[ -z "$RECOMMENDATIONS" ]]; then
    RECOMMENDATIONS="- ✅ No immediate action required - tests look good!"
fi

# Substitute variables in template
PR_COMMENT=$(echo "$PR_TEMPLATE" | \
    sed "s/{status_emoji}/$STATUS_EMOJI/g" | \
    sed "s/{status_message}/$STATUS_MESSAGE/g" | \
    sed "s/{coverage_status}/$COVERAGE_STATUS/g" | \
    sed "s/{coverage}/$COVERAGE_PERCENTAGE/g" | \
    sed "s/{target}/$COVERAGE_TARGET/g" | \
    sed "s/{tests_run}/$TESTS_RUN/g" | \
    sed "s/{tests_passed}/$TESTS_PASSED/g" | \
    sed "s/{tests_failed}/$TESTS_FAILED/g" | \
    sed "s/{quality_status}/$QUALITY_STATUS/g" | \
    sed "s/{quality_score}/$QUALITY_SCORE/g" | \
    sed "s/{test_analysis_summary}/$ANALYSIS_SUMMARY/g" | \
    sed "s/{key_findings}/$(echo -e "$KEY_FINDINGS")/g" | \
    sed "s/{recommendations}/$(echo -e "$RECOMMENDATIONS")/g" | \
    sed "s/{detailed_report}/$(echo -e "$DETAILED_REPORT")/g")

# Save PR comment to file
echo "$PR_COMMENT" > "$TEMP_DIR/pr_comment.md"
cp "$TEMP_DIR/pr_comment.md" "$RESULTS_DIR/"

echo "📝 PR comment generated: $RESULTS_DIR/pr_comment.md"

# Post comment to PR if GitHub CLI is available and we're in a PR context
if command -v gh &> /dev/null && [[ -n "$GITHUB_TOKEN" ]]; then
    if [[ -n "$GITHUB_HEAD_REF" ]]; then
        echo "💬 Posting comment to PR..."
        
        # Try to post the comment
        if gh pr comment --body-file "$TEMP_DIR/pr_comment.md" 2>/dev/null; then
            echo "✅ Successfully posted comment to PR"
        else
            echo "⚠️  Failed to post comment to PR, but comment file is available"
        fi
    else
        echo "ℹ️  Not in PR context, comment saved to file only"
    fi
else
    echo "ℹ️  GitHub CLI not available or token not set, comment saved to file only"
fi

echo "✨ PR comment generation complete!"