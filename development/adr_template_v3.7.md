# ADR-XXXX: [Title - Brief noun phrase]

**Document Type:** Architecture Decision Record  
**Status:** [Proposed | Accepted | Deprecated | Superseded]  
**Date:** YYYY-MM-DD  
**Framework Version:** v3.7  
**Deciders:** [List of people involved in the decision]  
**Technical Story:** [Link to relevant issue/story/ticket]  
**Related Requirements:** [REQ-XXX references from requirements.md]  
**Supersedes:** [ADR-XXXX if applicable]  
**Superseded by:** [ADR-XXXX if applicable]  

---

## Context and Problem Statement

### Current Situation
[Describe the architectural or technical context that necessitated this decision. Include:]
- What forces are at play (technological, political, social, project constraints)
- What problem we are trying to solve
- Current state and limitations
- Why this decision is needed now

### Framework Integration Context
[How this decision aligns with Framework v3.7 principles:]
- **AI-First Development Impact:** [How this affects AI assistant effectiveness]
- **Deployment Strategy Impact:** [How this affects AI-first deployment]
- **Security-by-Design Alignment:** [How this implements security principles]
- **Framework Compliance:** [Adherence to framework standards]

### Problem Details
- **Primary Issue:** [Specific technical or business problem to solve]
- **Constraints:** [Technical, business, regulatory, or framework constraints]
- **Requirements Traceability:** [Link to specific EARS requirements this addresses]

---

## Decision Drivers

### Technical Drivers
- [Driver 1: e.g., Performance requirements, Scalability needs]
- [Driver 2: e.g., Security requirements, Compliance needs]
- [Driver 3: e.g., Maintainability, Team expertise]

### Framework Drivers (v3.7 Specific)
- **AI Context Optimization:** [Impact on AI assistant performance and context loading]
- **Deployment Automation:** [Effect on AI-first deployment capabilities]
- **Quality Gates:** [Alignment with framework quality requirements]
- **Pattern Consistency:** [Adherence to established team patterns]

### Business Drivers
- [Business impact, cost considerations, timeline requirements]
- [Stakeholder requirements and strategic alignment]

---

## Considered Options

### Option 1: [Option Name]
**Description:** [Brief description of this option]

**Framework Alignment:**
- **AI Assistant Impact:** [How this affects AI development efficiency]
- **Deployment Impact:** [Effect on deployment automation and strategy]
- **Security Impact:** [Security-by-design implications]

**Pros:**
- [Advantage 1]
- [Advantage 2]
- [Framework-specific advantages]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]
- [Framework-specific disadvantages]

**Implementation Effort:** [High/Medium/Low]  
**Risk Level:** [High/Medium/Low]  
**Framework Compliance:** [Full/Partial/Requires Changes]

### Option 2: [Option Name]
[Same structure as Option 1]

### Option 3: [Option Name]
[Same structure as Option 1]

---

## Decision Outcome

**Chosen option:** "[Option Name]"

**Rationale:** [Detailed explanation of why this option was selected, including framework considerations]

### Framework Integration Strategy
- **AI Context Updates Required:**
  - [ ] Update .ai_context/current_context.md
  - [ ] Update .ai_context/team_patterns.md
  - [ ] Update .ai_context/domain_context.md
  - [ ] Update .ai_context/deployment_context.md (if applicable)

- **Framework Documentation Updates:**
  - [ ] Update requirements.md with new constraints
  - [ ] Update design.md with architectural changes
  - [ ] Update deployment.md with infrastructure changes
  - [ ] Create/update BDD scenarios for validation

### Implementation Strategy
- **Phase 1:** [Initial implementation steps]
- **Phase 2:** [Follow-up implementation steps]
- **Phase 3:** [Integration and validation steps]
- **Timeline:** [Expected implementation timeline]
- **Framework Validation:** [How compliance will be verified]

### Success Criteria
- [Measurable criteria 1]
- [Measurable criteria 2]
- [Framework-specific success metrics]
- **AI Assistant Performance:** [Target improvements in context loading, code accuracy]
- **Deployment Metrics:** [Target improvements in deployment success, automation]

---

## Consequences

### Positive Consequences
- [Positive impact 1]
- [Positive impact 2]
- **Framework Benefits:**
  - [AI development acceleration]
  - [Deployment automation improvement]
  - [Security enhancement]
  - [Quality improvement]

### Negative Consequences
- [Negative impact 1]
- [Negative impact 2]
- **Framework Trade-offs:**
  - [AI context complexity increase]
  - [Deployment process changes]
  - [Team training requirements]

### Neutral Consequences
- [Neutral impact 1]
- [Things that might change but aren't clearly positive or negative]

---

## Risk Assessment & Mitigation

### Technical Risks
| Risk | Probability | Impact | Framework Impact | Mitigation Strategy |
|------|-------------|--------|------------------|-------------------|
| [Risk 1] | [High/Med/Low] | [High/Med/Low] | [AI/Deployment/Security] | [How to mitigate] |
| [Risk 2] | [High/Med/Low] | [High/Med/Low] | [AI/Deployment/Security] | [How to mitigate] |

### Framework-Specific Risks
- **AI Context Degradation:** [Risk of reduced AI effectiveness] → [Mitigation strategy]
- **Deployment Complexity:** [Risk of deployment automation issues] → [Mitigation strategy]
- **Pattern Inconsistency:** [Risk of breaking established patterns] → [Mitigation strategy]

### Rollback Strategy
- **Rollback Triggers:** [Conditions that would require reverting this decision]
- **Rollback Process:** [Step-by-step rollback procedure]
- **Framework Restoration:** [How to restore previous framework state]

---

## Implementation Guidance

### Technical Implementation Details
[Specific technical guidance for implementing this decision:]
- Configuration changes needed
- Code patterns to follow
- Tools or libraries required
- Migration steps if applicable

### Framework Implementation Requirements
- **AI Context Integration:**
  ```markdown
  # Required updates to AI context files
  - current_context.md: [Specific changes needed]
  - team_patterns.md: [New patterns to document]
  - deployment_context.md: [Infrastructure changes to record]
  ```

- **Quality Gates:**
  - [ ] Security validation requirements
  - [ ] Performance benchmarks to meet
  - [ ] Integration test requirements
  - [ ] Documentation standards compliance

### Deployment Considerations
- **Infrastructure Changes:** [Required infrastructure modifications]
- **Deployment Pipeline Updates:** [CI/CD pipeline changes needed]
- **Monitoring Requirements:** [New monitoring or alerting needed]
- **Security Controls:** [Additional security measures required]

---

## Compliance and Validation

### Framework Compliance Checklist
- [ ] **EARS Requirements Alignment:** Traced to specific requirements
- [ ] **BDD Scenario Coverage:** Behavioral scenarios created/updated
- [ ] **Security-by-Design:** Security implications analyzed and addressed
- [ ] **AI Context Optimization:** AI assistant guidance provided
- [ ] **Deployment Integration:** Deployment impact assessed and planned

### Quality Assurance
- **Testing Strategy:** [How this decision will be validated]
- **Monitoring Requirements:** [Metrics to track implementation success]
- **Performance Validation:** [Performance benchmarks and targets]
- **Security Validation:** [Security testing and validation approach]

### BDD Scenario Requirements
[Behavioral scenarios needed to validate this decision:]
```gherkin
Feature: [Feature name related to this decision]
Scenario: [Key scenario that validates the decision implementation]
Given [precondition]
When [action]
Then [expected outcome validating the decision]
```

---

## References and Dependencies

### Framework References
- [Link to related framework requirements](../requirements.md#section)
- [Link to related BDD scenarios](../docs/bdd/scenario-name.md)
- [Link to related design patterns](../design.md#section)

### External References
- [External documentation and research]
- [Industry standards or best practices]
- [Vendor documentation]

### Related ADRs
- [ADR-XXXX: Related Decision Title](./XXXX-title.md)
- [PRD-XXX: Related Product Requirement](../docs/prd/PRD-XXX.md)

### Dependency Analysis
**Upstream Dependencies:** [What this decision depends on]
**Downstream Impact:** [What this decision affects]
**Framework Dependencies:** [Framework components this decision affects]

---

## AI Assistant Integration

### **🤖 AI AUTONOMOUS Operations for This ADR:**
- Technical implementation of architectural decision
- Code generation following decision patterns
- Security control implementation from decision
- Framework compliance validation and testing
- Documentation updates and maintenance
- Performance optimization according to decision

### **👤 HUMAN SUPERVISION REQUIRED for This ADR:**
- Architectural decision approval and rationale validation
- Business impact assessment and acceptance
- Security architecture review and approval
- Technology choice validation and risk acceptance
- Production deployment authorization for changes

### AI Context Updates Required
**Immediate Updates:**
- Update AI context files with new patterns and considerations
- Document new coding standards or architectural patterns
- Update deployment context with infrastructure changes
- Add decision rationale to team knowledge base

**AI Assistant Guidance:**
[Specific guidance for AI assistants when implementing this decision:]
- Code generation patterns to follow
- Security considerations to maintain
- Performance optimizations to apply
- Integration approaches to use
- Framework compliance requirements to enforce

### Implementation Prompts
[Ready-to-use prompts for AI assistants implementing this decision:]
```bash
# AI autonomous implementation
"coder-agent + security-auditor: Using architectural decision ADR-XXXX, implement [specific functionality] following the chosen [option] approach while maintaining security, performance, and framework compliance requirements"

# Human supervision checkpoint  
"Human review required: Validate architectural decision implementation aligns with business objectives before production deployment"
```

---

## Review and Maintenance

### Review Schedule
**Next Review:** [Date - typically 6-12 months from acceptance]  
**Review Frequency:** [How often to review - based on decision impact]  
**Review Criteria:** [What factors would trigger a review of this decision]

### Framework Evolution Impact
**Version Compatibility:** [Framework versions this decision is compatible with]
**Evolution Path:** [How this decision might need to change with framework updates]
**Deprecation Criteria:** [Conditions that would lead to deprecating this decision]

### Success Metrics Tracking
**Measurable Outcomes:**
- [Metric 1]: [Current baseline] → [Target improvement]
- [Metric 2]: [Current baseline] → [Target improvement]
- **AI Assistant Efficiency:** [Current performance] → [Target performance]
- **Deployment Success Rate:** [Current rate] → [Target rate]

**Review Questions:**
- Is this decision still aligned with framework principles?
- Are the expected benefits being realized?
- Have any negative consequences materialized?
- Does this decision need updating for new framework versions?

---

## Approval and Sign-off

### Review Process
1. **Technical Review:** [Engineering lead review and approval]
2. **Framework Compliance Review:** [Framework adherence validation]
3. **Security Review:** [Security team approval if applicable]
4. **Business Review:** [Product/business stakeholder approval]
5. **Final Approval:** [Executive sponsor sign-off]

### Sign-off
| Role | Name | Date | Signature/Approval |
|------|------|------|--------------------|
| Technical Lead | [Name] | [Date] | [ ] Approved |
| Framework Architect | [Name] | [Date] | [ ] Approved |
| Security Lead | [Name] | [Date] | [ ] Approved |
| Product Owner | [Name] | [Date] | [ ] Approved |

---

## Notes and Assumptions

### Assumptions Made
[Key assumptions underlying this decision]
- Technical assumptions
- Business assumptions  
- Framework assumptions
- External dependencies

### Future Considerations
[Factors that might affect this decision in the future]
- Technology evolution
- Framework updates
- Business changes
- Regulatory changes

### Additional Context
[Any other relevant information, lessons learned, or considerations]

---

*Created: YYYY-MM-DD | Last Updated: YYYY-MM-DD | Version: 1.0*  
*Framework: AI Agent Development Framework v3.7*  
*Template Version: v3.7 - Production Ready with AI-First Integration*