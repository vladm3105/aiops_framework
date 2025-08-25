# BDD Scenario Template
# AI Agent Development Framework v3.7
#
# Behavior-Driven Development scenarios using Gherkin syntax
# Links directly to EARS requirements for full traceability

## Document Information
- **Document ID**: BDD-{{ SCENARIO_ID | format: "%04d" }}
- **Feature**: {{ FEATURE_NAME }}
- **Version**: {{ VERSION | default: 1.0 }}
- **Date**: {{ DATE | format: "YYYY-MM-DD" }}
- **Author**: {{ AUTHOR }}
- **Status**: {{ STATUS | default: Draft }}

## Related Requirements
- **EARS Reference**: EARS-{{ EARS_ID }}
- **User Story**: {{ USER_STORY_ID }}
- **Epic**: {{ EPIC_ID }}

## Feature Definition

```gherkin
Feature: {{ FEATURE_NAME }}
  As a {{ USER_ROLE | placeholder: "type of user" }}
  I want {{ USER_GOAL | placeholder: "to achieve some goal" }}
  So that {{ BUSINESS_VALUE | placeholder: "I can realize some business value" }}

  Background:
    Given {{ BACKGROUND_CONTEXT | placeholder: "the system is in a known state" }}
    And {{ BACKGROUND_SETUP | placeholder: "required setup conditions exist" }}
```

## Scenarios

### Scenario 1: {{ SCENARIO_1_NAME | placeholder: "Happy Path" }}

```gherkin
  Scenario: {{ SCENARIO_1_NAME }}
    Given {{ GIVEN_1_1 | placeholder: "initial state or precondition" }}
    And {{ GIVEN_1_2 | placeholder: "additional context if needed" }}
    When {{ WHEN_1 | placeholder: "the user performs an action" }}
    Then {{ THEN_1_1 | placeholder: "expected outcome" }}
    And {{ THEN_1_2 | placeholder: "additional expected results" }}
```

**Business Rules**:
- {{ BUSINESS_RULE_1_1 | placeholder: "Specific business rule enforced" }}
- {{ BUSINESS_RULE_1_2 | placeholder: "Additional business rules" }}

**Acceptance Criteria**:
- {{ ACCEPTANCE_1_1 | placeholder: "Measurable success criteria" }}
- {{ ACCEPTANCE_1_2 | placeholder: "Additional criteria" }}

### Scenario 2: {{ SCENARIO_2_NAME | placeholder: "Alternative Path" }}

```gherkin
  Scenario: {{ SCENARIO_2_NAME }}
    Given {{ GIVEN_2_1 | placeholder: "initial state or precondition" }}
    When {{ WHEN_2 | placeholder: "alternative user action" }}
    Then {{ THEN_2_1 | placeholder: "expected alternative outcome" }}
```

**Business Rules**:
- {{ BUSINESS_RULE_2_1 | placeholder: "Specific business rule enforced" }}

**Acceptance Criteria**:
- {{ ACCEPTANCE_2_1 | placeholder: "Measurable success criteria" }}

### Scenario 3: {{ SCENARIO_3_NAME | placeholder: "Error Handling" }}

```gherkin
  Scenario: {{ SCENARIO_3_NAME }}
    Given {{ GIVEN_3_1 | placeholder: "initial state with error conditions" }}
    When {{ WHEN_3 | placeholder: "user action that triggers error" }}
    Then {{ THEN_3_1 | placeholder: "appropriate error response" }}
    And {{ THEN_3_2 | placeholder: "system remains stable" }}
```

**Error Handling Rules**:
- {{ ERROR_RULE_1 | placeholder: "How system handles specific errors" }}
- {{ ERROR_RULE_2 | placeholder: "Recovery mechanisms" }}

### Scenario Outline: {{ SCENARIO_OUTLINE_NAME | placeholder: "Data-Driven Testing" }}

```gherkin
  Scenario Outline: {{ SCENARIO_OUTLINE_NAME }}
    Given {{ GIVEN_OUTLINE | placeholder: "parameterized initial state" }}
    When {{ WHEN_OUTLINE | placeholder: "parameterized action with <parameter>" }}
    Then {{ THEN_OUTLINE | placeholder: "parameterized expected outcome" }}

  Examples:
    | {{ PARAMETER_1_NAME | default: "input" }} | {{ PARAMETER_2_NAME | default: "expected_output" }} | {{ PARAMETER_3_NAME | default: "description" }} |
    | {{ EXAMPLE_1_1 | default: "value1" }} | {{ EXAMPLE_1_2 | default: "result1" }} | {{ EXAMPLE_1_3 | default: "case1" }} |
    | {{ EXAMPLE_2_1 | default: "value2" }} | {{ EXAMPLE_2_2 | default: "result2" }} | {{ EXAMPLE_2_3 | default: "case2" }} |
    | {{ EXAMPLE_3_1 | default: "value3" }} | {{ EXAMPLE_3_2 | default: "result3" }} | {{ EXAMPLE_3_3 | default: "case3" }} |
```

## Non-Functional Scenarios

### Performance Scenario

```gherkin
  Scenario: {{ PERFORMANCE_SCENARIO_NAME | placeholder: "Performance Requirements" }}
    Given {{ PERFORMANCE_GIVEN | placeholder: "system under expected load" }}
    When {{ PERFORMANCE_WHEN | placeholder: "performance-critical action occurs" }}
    Then {{ PERFORMANCE_THEN | placeholder: "response time meets SLA" }}
    And {{ PERFORMANCE_AND | placeholder: "system resources remain within limits" }}
```

**Performance Criteria**:
- **Response Time**: {{ RESPONSE_TIME_SLA | default: "< 2 seconds" }}
- **Throughput**: {{ THROUGHPUT_SLA | default: "100 requests/second" }}
- **Resource Usage**: {{ RESOURCE_USAGE_SLA | default: "< 80% CPU, < 70% memory" }}

### Security Scenario

```gherkin
  Scenario: {{ SECURITY_SCENARIO_NAME | placeholder: "Security Requirements" }}
    Given {{ SECURITY_GIVEN | placeholder: "security context established" }}
    When {{ SECURITY_WHEN | placeholder: "security-sensitive action attempted" }}
    Then {{ SECURITY_THEN | placeholder: "appropriate security response" }}
    And {{ SECURITY_AND | placeholder: "security measures enforced" }}
```

**Security Criteria**:
- **Authentication**: {{ AUTH_REQUIREMENTS | placeholder: "Authentication requirements" }}
- **Authorization**: {{ AUTHZ_REQUIREMENTS | placeholder: "Authorization requirements" }}
- **Data Protection**: {{ DATA_PROTECTION | placeholder: "Data protection measures" }}

## Test Implementation

### Step Definitions (Python/pytest-bdd)

```python
# BDD Step Definitions for {{ FEATURE_NAME }}

from pytest_bdd import given, when, then, scenarios
from {{ APPLICATION_MODULE }} import {{ APPLICATION_CLASS }}

# Load scenarios from this feature file
scenarios('{{ FEATURE_FILE_PATH }}.feature')

@given('{{ GIVEN_STEP_PATTERN }}')
def {{ GIVEN_STEP_FUNCTION }}({{ STEP_PARAMETERS }}):
    """{{ GIVEN_STEP_DESCRIPTION }}"""
    # Implementation
    {{ GIVEN_IMPLEMENTATION | placeholder: "# Setup initial state" }}

@when('{{ WHEN_STEP_PATTERN }}')
def {{ WHEN_STEP_FUNCTION }}({{ STEP_PARAMETERS }}):
    """{{ WHEN_STEP_DESCRIPTION }}"""
    # Implementation
    {{ WHEN_IMPLEMENTATION | placeholder: "# Execute action" }}

@then('{{ THEN_STEP_PATTERN }}')
def {{ THEN_STEP_FUNCTION }}({{ STEP_PARAMETERS }}):
    """{{ THEN_STEP_DESCRIPTION }}"""
    # Implementation
    {{ THEN_IMPLEMENTATION | placeholder: "# Verify outcome" }}
```

### Test Data

```yaml
# Test data for {{ FEATURE_NAME }} scenarios
test_data:
  {{ DATA_SET_1_NAME | default: "valid_inputs" }}:
    {{ DATA_FIELD_1 | default: "field1" }}: {{ DATA_VALUE_1 | default: "value1" }}
    {{ DATA_FIELD_2 | default: "field2" }}: {{ DATA_VALUE_2 | default: "value2" }}
    
  {{ DATA_SET_2_NAME | default: "edge_cases" }}:
    {{ DATA_FIELD_1 | default: "field1" }}: {{ EDGE_VALUE_1 | default: "edge_value1" }}
    {{ DATA_FIELD_2 | default: "field2" }}: {{ EDGE_VALUE_2 | default: "edge_value2" }}
    
  {{ DATA_SET_3_NAME | default: "error_cases" }}:
    {{ DATA_FIELD_1 | default: "field1" }}: {{ ERROR_VALUE_1 | default: "invalid_value1" }}
    {{ DATA_FIELD_2 | default: "field2" }}: {{ ERROR_VALUE_2 | default: "invalid_value2" }}
```

## AI Agent Integration

### AI-Assisted Scenario Generation
- **Natural Language Processing**: Convert requirements to BDD scenarios
- **Edge Case Detection**: AI identification of missing test scenarios
- **Data Generation**: AI-generated comprehensive test data sets

### Automated Test Creation
- **Step Definition Generation**: AI-generated step definitions from scenarios
- **Test Data Creation**: AI-generated realistic test data
- **Mock Service Generation**: AI-created service mocks for testing

### Continuous Validation
- **Scenario Maintenance**: AI detection of outdated scenarios
- **Coverage Analysis**: AI analysis of scenario coverage gaps
- **Performance Optimization**: AI-suggested scenario performance improvements

## Traceability Links

| BDD Scenario | EARS Requirement | ADR Decision | Test Implementation | Status |
|--------------|------------------|--------------|-------------------|---------|
| {{ SCENARIO_1_NAME }} | EARS-{{ EARS_ID }}-001 | ADR-{{ ADR_ID_1 }} | {{ TEST_FILE_1 }} | {{ TEST_STATUS_1 | default: "Pending" }} |
| {{ SCENARIO_2_NAME }} | EARS-{{ EARS_ID }}-002 | ADR-{{ ADR_ID_2 }} | {{ TEST_FILE_2 }} | {{ TEST_STATUS_2 | default: "Pending" }} |

## Validation Checklist

### BDD Format Compliance
- [ ] Scenarios follow Given-When-Then structure
- [ ] Feature has clear user story format
- [ ] Background context provided where appropriate
- [ ] Scenario outlines used for data-driven tests

### Completeness Check
- [ ] Happy path scenarios covered
- [ ] Alternative paths included
- [ ] Error conditions addressed
- [ ] Non-functional requirements included

### Quality Assurance
- [ ] Scenarios are readable and understandable
- [ ] Business rules clearly expressed
- [ ] Acceptance criteria measurable
- [ ] Step definitions implementable

### Framework Integration
- [ ] Links to EARS requirements established
- [ ] ADR decisions referenced
- [ ] Test implementation planned
- [ ] AI agent integration identified

## Review and Approval

| Role | Reviewer | Status | Date | Comments |
|------|----------|--------|------|----------|
| Product Owner | {{ PO_NAME }} | {{ PO_STATUS | default: "Pending" }} | {{ PO_DATE }} | {{ PO_COMMENTS }} |
| Business Analyst | {{ BA_NAME }} | {{ BA_STATUS | default: "Pending" }} | {{ BA_DATE }} | {{ BA_COMMENTS }} |
| Developer | {{ DEV_NAME }} | {{ DEV_STATUS | default: "Pending" }} | {{ DEV_DATE }} | {{ DEV_COMMENTS }} |
| QA Engineer | {{ QA_NAME }} | {{ QA_STATUS | default: "Pending" }} | {{ QA_DATE }} | {{ QA_COMMENTS }} |

---

*BDD Scenario Document - AI Agent Development Framework v3.7*  
*Template Version: 1.0*  
*Created: {{ CREATION_DATE }}*