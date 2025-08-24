# Architecture Decision Record (ADR) Template
# AI Agent Development Framework v3.7
#
# Documents architectural decisions with context, options, and consequences
# Links to requirements and BDD scenarios for full traceability

## Document Information
- **ADR Number**: ADR-{{ ADR_NUMBER | format: "%04d" }}
- **Title**: {{ ADR_TITLE }}
- **Status**: {{ STATUS | default: "Proposed" }} <!-- Proposed | Accepted | Deprecated | Superseded -->
- **Date**: {{ DATE | format: "YYYY-MM-DD" }}
- **Author(s)**: {{ AUTHORS }}
- **Reviewers**: {{ REVIEWERS }}

## Status
{{ STATUS_DESCRIPTION | default: "Proposed for review and decision" }}

{{ SUPERSEDES_TEXT | placeholder: "If superseded: Supersedes ADR-XXXX" }}
{{ SUPERSEDED_BY_TEXT | placeholder: "If superseded: Superseded by ADR-XXXX" }}

## Context

### Business Context
{{ BUSINESS_CONTEXT | placeholder: "Business drivers and requirements that led to this decision" }}

### Technical Context
{{ TECHNICAL_CONTEXT | placeholder: "Current technical situation and constraints" }}

### Problem Statement
{{ PROBLEM_STATEMENT | placeholder: "Clear description of the architectural problem to be solved" }}

### Requirements Impact
- **EARS Requirements**: {{ EARS_REFERENCES | placeholder: "EARS-XXXX, EARS-YYYY" }}
- **BDD Scenarios**: {{ BDD_REFERENCES | placeholder: "BDD-XXXX, BDD-YYYY" }}
- **User Stories**: {{ USER_STORY_REFERENCES | placeholder: "US-XXXX, US-YYYY" }}

### Constraints
{{ CONSTRAINTS | placeholder: "Technical, business, legal, or regulatory constraints" }}
- {{ CONSTRAINT_1 | placeholder: "Technical constraint 1" }}
- {{ CONSTRAINT_2 | placeholder: "Business constraint 1" }}
- {{ CONSTRAINT_3 | placeholder: "Regulatory constraint 1" }}

## Decision

### Selected Option
**Option {{ SELECTED_OPTION_NUMBER | default: "1" }}**: {{ SELECTED_OPTION_NAME }}

{{ DECISION_RATIONALE | placeholder: "Clear statement of the architectural decision and reasoning" }}

### Key Decision Points
1. {{ DECISION_POINT_1 | placeholder: "Primary architectural decision" }}
2. {{ DECISION_POINT_2 | placeholder: "Secondary architectural decision" }}
3. {{ DECISION_POINT_3 | placeholder: "Implementation decision" }}

## Options Considered

### Option 1: {{ OPTION_1_NAME | placeholder: "First Option" }}

**Description**: {{ OPTION_1_DESCRIPTION | placeholder: "Detailed description of the first option" }}

**Pros**:
- {{ OPTION_1_PRO_1 | placeholder: "Advantage 1" }}
- {{ OPTION_1_PRO_2 | placeholder: "Advantage 2" }}
- {{ OPTION_1_PRO_3 | placeholder: "Advantage 3" }}

**Cons**:
- {{ OPTION_1_CON_1 | placeholder: "Disadvantage 1" }}
- {{ OPTION_1_CON_2 | placeholder: "Disadvantage 2" }}
- {{ OPTION_1_CON_3 | placeholder: "Disadvantage 3" }}

**Cost/Effort**: {{ OPTION_1_COST | placeholder: "High/Medium/Low - Implementation effort and cost" }}
**Risk Level**: {{ OPTION_1_RISK | placeholder: "High/Medium/Low - Technical and business risk" }}
**Alignment**: {{ OPTION_1_ALIGNMENT | placeholder: "How well this aligns with framework v3.7 principles" }}

### Option 2: {{ OPTION_2_NAME | placeholder: "Second Option" }}

**Description**: {{ OPTION_2_DESCRIPTION | placeholder: "Detailed description of the second option" }}

**Pros**:
- {{ OPTION_2_PRO_1 | placeholder: "Advantage 1" }}
- {{ OPTION_2_PRO_2 | placeholder: "Advantage 2" }}
- {{ OPTION_2_PRO_3 | placeholder: "Advantage 3" }}

**Cons**:
- {{ OPTION_2_CON_1 | placeholder: "Disadvantage 1" }}
- {{ OPTION_2_CON_2 | placeholder: "Disadvantage 2" }}
- {{ OPTION_2_CON_3 | placeholder: "Disadvantage 3" }}

**Cost/Effort**: {{ OPTION_2_COST | placeholder: "High/Medium/Low - Implementation effort and cost" }}
**Risk Level**: {{ OPTION_2_RISK | placeholder: "High/Medium/Low - Technical and business risk" }}
**Alignment**: {{ OPTION_2_ALIGNMENT | placeholder: "How well this aligns with framework v3.7 principles" }}

### Option 3: {{ OPTION_3_NAME | placeholder: "Third Option" }}

**Description**: {{ OPTION_3_DESCRIPTION | placeholder: "Detailed description of the third option" }}

**Pros**:
- {{ OPTION_3_PRO_1 | placeholder: "Advantage 1" }}
- {{ OPTION_3_PRO_2 | placeholder: "Advantage 2" }}

**Cons**:
- {{ OPTION_3_CON_1 | placeholder: "Disadvantage 1" }}
- {{ OPTION_3_CON_2 | placeholder: "Disadvantage 2" }}

**Cost/Effort**: {{ OPTION_3_COST | placeholder: "High/Medium/Low - Implementation effort and cost" }}
**Risk Level**: {{ OPTION_3_RISK | placeholder: "High/Medium/Low - Technical and business risk" }}
**Alignment**: {{ OPTION_3_ALIGNMENT | placeholder: "How well this aligns with framework v3.7 principles" }}

## Decision Matrix

| Criteria | Weight | Option 1 | Option 2 | Option 3 | 
|----------|---------|----------|----------|----------|
| {{ CRITERIA_1 | default: "Technical Feasibility" }} | {{ WEIGHT_1 | default: "30%" }} | {{ SCORE_1_1 | default: "7/10" }} | {{ SCORE_1_2 | default: "8/10" }} | {{ SCORE_1_3 | default: "6/10" }} |
| {{ CRITERIA_2 | default: "Implementation Cost" }} | {{ WEIGHT_2 | default: "25%" }} | {{ SCORE_2_1 | default: "6/10" }} | {{ SCORE_2_2 | default: "5/10" }} | {{ SCORE_2_3 | default: "8/10" }} |
| {{ CRITERIA_3 | default: "Framework Alignment" }} | {{ WEIGHT_3 | default: "20%" }} | {{ SCORE_3_1 | default: "8/10" }} | {{ SCORE_3_2 | default: "9/10" }} | {{ SCORE_3_3 | default: "7/10" }} |
| {{ CRITERIA_4 | default: "Maintainability" }} | {{ WEIGHT_4 | default: "15%" }} | {{ SCORE_4_1 | default: "7/10" }} | {{ SCORE_4_2 | default: "8/10" }} | {{ SCORE_4_3 | default: "6/10" }} |
| {{ CRITERIA_5 | default: "Risk Level" }} | {{ WEIGHT_5 | default: "10%" }} | {{ SCORE_5_1 | default: "6/10" }} | {{ SCORE_5_2 | default: "7/10" }} | {{ SCORE_5_3 | default: "8/10" }} |
| **Total Weighted Score** |  | {{ TOTAL_SCORE_1 | default: "6.8/10" }} | {{ TOTAL_SCORE_2 | default: "7.4/10" }} | {{ TOTAL_SCORE_3 | default: "6.9/10" }} |

**Decision Rationale**: {{ DECISION_MATRIX_RATIONALE | placeholder: "Based on the weighted analysis, Option X provides the best balance of..." }}

## Consequences

### Positive Consequences
- {{ POSITIVE_CONSEQUENCE_1 | placeholder: "Positive outcome from this decision" }}
- {{ POSITIVE_CONSEQUENCE_2 | placeholder: "Another positive outcome" }}
- {{ POSITIVE_CONSEQUENCE_3 | placeholder: "Third positive outcome" }}

### Negative Consequences
- {{ NEGATIVE_CONSEQUENCE_1 | placeholder: "Negative outcome or trade-off" }}
- {{ NEGATIVE_CONSEQUENCE_2 | placeholder: "Another negative outcome" }}
- {{ NEGATIVE_CONSEQUENCE_3 | placeholder: "Third negative outcome" }}

### Neutral Consequences
- {{ NEUTRAL_CONSEQUENCE_1 | placeholder: "Neutral outcome or change" }}
- {{ NEUTRAL_CONSEQUENCE_2 | placeholder: "Another neutral consequence" }}

### Risk Mitigation
| Risk | Impact | Probability | Mitigation Strategy |
|------|---------|-------------|-------------------|
| {{ RISK_1 | placeholder: "Technical risk" }} | {{ RISK_1_IMPACT | default: "Medium" }} | {{ RISK_1_PROBABILITY | default: "Low" }} | {{ RISK_1_MITIGATION | placeholder: "Mitigation approach" }} |
| {{ RISK_2 | placeholder: "Business risk" }} | {{ RISK_2_IMPACT | default: "High" }} | {{ RISK_2_PROBABILITY | default: "Low" }} | {{ RISK_2_MITIGATION | placeholder: "Mitigation approach" }} |

## Implementation

### Implementation Plan
1. **Phase 1**: {{ PHASE_1_DESCRIPTION | placeholder: "Initial implementation phase" }}
   - {{ PHASE_1_TASK_1 | placeholder: "Task 1" }}
   - {{ PHASE_1_TASK_2 | placeholder: "Task 2" }}
   - **Timeline**: {{ PHASE_1_TIMELINE | default: "2 weeks" }}

2. **Phase 2**: {{ PHASE_2_DESCRIPTION | placeholder: "Second implementation phase" }}
   - {{ PHASE_2_TASK_1 | placeholder: "Task 1" }}
   - {{ PHASE_2_TASK_2 | placeholder: "Task 2" }}
   - **Timeline**: {{ PHASE_2_TIMELINE | default: "3 weeks" }}

3. **Phase 3**: {{ PHASE_3_DESCRIPTION | placeholder: "Final implementation phase" }}
   - {{ PHASE_3_TASK_1 | placeholder: "Task 1" }}
   - {{ PHASE_3_TASK_2 | placeholder: "Task 2" }}
   - **Timeline**: {{ PHASE_3_TIMELINE | default: "1 week" }}

### Success Criteria
- [ ] {{ SUCCESS_CRITERIA_1 | placeholder: "Measurable success criteria 1" }}
- [ ] {{ SUCCESS_CRITERIA_2 | placeholder: "Measurable success criteria 2" }}
- [ ] {{ SUCCESS_CRITERIA_3 | placeholder: "Measurable success criteria 3" }}

### Monitoring and Validation
- **Performance Metrics**: {{ PERFORMANCE_METRICS | placeholder: "How performance will be measured" }}
- **Quality Metrics**: {{ QUALITY_METRICS | placeholder: "How quality will be measured" }}
- **Business Metrics**: {{ BUSINESS_METRICS | placeholder: "How business impact will be measured" }}

### Rollback Plan
{{ ROLLBACK_PLAN | placeholder: "Plan for reverting the decision if implementation fails" }}

## Framework v3.7 Alignment

### AI-First Principles
- **AI Integration**: {{ AI_INTEGRATION | placeholder: "How this decision supports AI-first development" }}
- **Automation Potential**: {{ AUTOMATION_POTENTIAL | placeholder: "Opportunities for automation this enables" }}
- **Human Supervision**: {{ HUMAN_SUPERVISION | placeholder: "Required human oversight points" }}

### Quality Standards
- **Testing Impact**: {{ TESTING_IMPACT | placeholder: "How this affects testing strategy" }}
- **Security Impact**: {{ SECURITY_IMPACT | placeholder: "Security implications of this decision" }}
- **Performance Impact**: {{ PERFORMANCE_IMPACT | placeholder: "Performance implications" }}

### Operational Excellence
- **Monitoring**: {{ MONITORING_IMPACT | placeholder: "How this affects monitoring and observability" }}
- **Deployment**: {{ DEPLOYMENT_IMPACT | placeholder: "Impact on deployment strategies" }}
- **Maintenance**: {{ MAINTENANCE_IMPACT | placeholder: "Long-term maintenance implications" }}

## Related Documents

### Framework Documents
- **Requirements**: {{ RELATED_EARS | placeholder: "EARS-XXXX: Related requirements" }}
- **BDD Scenarios**: {{ RELATED_BDD | placeholder: "BDD-XXXX: Related scenarios" }}
- **Other ADRs**: {{ RELATED_ADRS | placeholder: "ADR-XXXX: Related architecture decisions" }}

### External References
- {{ EXTERNAL_REF_1 | placeholder: "Link to external documentation or standards" }}
- {{ EXTERNAL_REF_2 | placeholder: "Link to vendor documentation" }}
- {{ EXTERNAL_REF_3 | placeholder: "Link to industry best practices" }}

## AI Agent Integration

### AI-Assisted Decision Making
- **Option Analysis**: AI analysis of architectural options and trade-offs
- **Risk Assessment**: AI-powered risk identification and mitigation suggestions
- **Impact Analysis**: AI evaluation of decision consequences

### Automated Validation
- **Compliance Checking**: AI validation against framework standards
- **Consistency Verification**: AI detection of conflicts with existing ADRs
- **Quality Assessment**: AI analysis of decision quality and completeness

### Continuous Monitoring
- **Implementation Tracking**: AI monitoring of implementation progress
- **Success Measurement**: AI evaluation of success criteria achievement
- **Adaptation Recommendations**: AI suggestions for decision refinement

## Review and Approval

| Role | Name | Status | Date | Comments |
|------|------|--------|------|----------|
| **Architect** | {{ ARCHITECT_NAME }} | {{ ARCHITECT_STATUS | default: "Pending" }} | {{ ARCHITECT_DATE }} | {{ ARCHITECT_COMMENTS }} |
| **Tech Lead** | {{ TECH_LEAD_NAME }} | {{ TECH_LEAD_STATUS | default: "Pending" }} | {{ TECH_LEAD_DATE }} | {{ TECH_LEAD_COMMENTS }} |
| **Product Owner** | {{ PO_NAME }} | {{ PO_STATUS | default: "Pending" }} | {{ PO_DATE }} | {{ PO_COMMENTS }} |
| **Security Lead** | {{ SECURITY_NAME }} | {{ SECURITY_STATUS | default: "Pending" }} | {{ SECURITY_DATE }} | {{ SECURITY_COMMENTS }} |
| **DevOps Lead** | {{ DEVOPS_NAME }} | {{ DEVOPS_STATUS | default: "Pending" }} | {{ DEVOPS_DATE }} | {{ DEVOPS_COMMENTS }} |

## Change History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| {{ VERSION_1 | default: "1.0" }} | {{ DATE_1 | default: "YYYY-MM-DD" }} | {{ AUTHOR_1 }} | {{ CHANGES_1 | default: "Initial version" }} |
| {{ VERSION_2 | placeholder: "1.1" }} | {{ DATE_2 | placeholder: "YYYY-MM-DD" }} | {{ AUTHOR_2 }} | {{ CHANGES_2 | placeholder: "Updated based on review feedback" }} |

---

*Architecture Decision Record - AI Agent Development Framework v3.7*  
*Template Version: 1.0*  
*Created: {{ CREATION_DATE }}*