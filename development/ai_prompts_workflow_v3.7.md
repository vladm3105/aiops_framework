# AI Assistant Workflow Prompts for Framework v3.7
## Complete Development Lifecycle Prompts from Initial Setup to Production Deployment

**Version:** 3.7 - Complete Workflow Edition  
**Date:** 2025-08-16  
**Framework:** AI Agent Development Framework v3.7  
**Purpose:** Systematic AI assistant prompts for complete development lifecycle  

---

## ⚠️ **CRITICAL: MANDATORY PRE-WORK REQUIREMENTS SUMMARY**

**🚨 BEFORE ANY FRAMEWORK WORK: These requirements are NON-NEGOTIABLE and MUST be completed first:**

1. **📋 Migration Assessment (First Run)**: Analyze existing project, create migration plan
2. **🛡️ Version Control Preparation (Every Run)**: Ask developer choice, get confirmation 
3. **✅ Change Submission (Every Run)**: Commit all changes, ensure clean working directory

**❌ FRAMEWORK WORK IS FORBIDDEN WITHOUT COMPLETING ALL THREE REQUIREMENTS**

**✅ Only proceed to Phase 0 after 100% completion of Phase -1 mandatory pre-work**

---

## ⚠️ **Phase -1: MANDATORY PRE-WORK REQUIREMENTS (CRITICAL)**

### **⚠️ CRITICAL WARNING: These Requirements CANNOT be Skipped**

**Before ANY framework work begins, ALL three mandatory requirements must be completed:**

### **-1.1 Initial Project Migration Assessment (First Run Only)**
```bash
# Analyze existing project structure and create migration plan
"general-purpose: Review all existing project files and directory structure, analyze against Framework v3.7 requirements from development_framework_v3.7.md, identify gaps, dependencies, and risks, then create detailed migration plan with specific actionable tasks for transitioning to framework structure"

# Document migration risks and mitigation strategies  
"general-purpose: Document potential migration risks including data loss, structure conflicts, dependency issues, and create specific mitigation strategies for each identified risk during framework migration"

# Create step-by-step migration tasks
"general-purpose: Generate specific, actionable migration tasks in priority order including file moves, directory creation, template application, and validation steps to achieve 100% framework v3.7 compliance"
```

### **-1.2 Version Control Preparation (Every Single Run)**
```bash
# Check version control system availability
"general-purpose: Verify git, GitHub, or other version control system is available and properly configured, check current repository status and branch information"

# Ask developer for backup/versioning approach - MANDATORY HUMAN INTERACTION
"Ask human developer: Choose your preferred approach for framework implementation:
  Option A: Modify existing files in current project (requires git backup confirmation)
  Option B: Copy entire project to separated folder and create new framework version
  
  Please confirm your choice and any specific requirements before proceeding."

# Confirm developer choice and document approach
"general-purpose: Document developer's chosen approach (Option A or B), confirm backup strategy is understood and acceptable, and ensure all requirements are met before proceeding with any framework work"

# STOP POINT: Do not proceed without explicit developer confirmation
"MANDATORY STOP: Do NOT proceed with ANY framework work until developer has explicitly confirmed their choice and backup strategy. Framework work is FORBIDDEN without this confirmation."
```

### **-1.3 Change Submission Protocol (Every Single Run)**
```bash
# Check current git status and uncommitted changes
"general-purpose: Execute 'git status' to check for any uncommitted changes, untracked files, or staging area content in the current repository"

# Commit all existing changes before framework work
"general-purpose: If any uncommitted changes exist, submit ALL changes to version control system using appropriate commit messages, ensure clean working directory before framework work begins"

# Verify clean working state
"general-purpose: Verify git working directory is clean with no uncommitted changes, confirm current branch is appropriate for framework changes, document current state for rollback purposes"

# STOP POINT: Do not proceed with dirty working directory
"MANDATORY STOP: Do NOT proceed with ANY framework work if there are uncommitted changes. Framework work is FORBIDDEN with a dirty working directory."
```

### **-1.4 Pre-Work Completion Validation**
```bash
# Validate all mandatory pre-work requirements are complete
"project-manager: Validate that ALL three mandatory pre-work requirements are completed:
  ✓ Migration assessment and plan created (first run)
  ✓ Developer choice confirmed and documented  
  ✓ All changes committed to version control
  ✓ Clean working directory verified
  Report PASS/FAIL status for each requirement."

# Final safety check before framework work
"FINAL CHECKPOINT: Confirm all pre-work requirements are COMPLETE before proceeding to Phase 0. Framework work is FORBIDDEN if any pre-work requirement is incomplete."
```

---

## 🚀 **Phase 0: Framework Initialization & Setup**

**Note: Phase 0 can only begin AFTER successful completion of Phase -1 mandatory pre-work requirements.**

### **0.1 Framework Structure Setup**
```bash
# Execute migration plan from Phase -1 (first run) or validate existing structure
"general-purpose: If this is first run, execute the migration plan created in Phase -1.1 to transition existing project to Framework v3.7 structure. If framework already exists, validate structure compliance against development_framework_v3.7.md specification"

# Initialize complete framework structure (new projects) or complete migration (existing projects)
"general-purpose: Complete Framework v3.7 structure setup including product.md, requirements.md, design.md, tasks.md, deployment.md, docs/ears/, docs/bdd/, docs/adr/, docs/specs/, .ai_context/, and deployment/ directories with proper framework v3.7 compliance"

# Validate framework structure compliance and migration success
"general-purpose: Validate framework v3.7 structure compliance by checking all required files and directories exist according to development_framework_v3.7.md specification, verify migration completion if applicable, report any missing components"
```

### **0.2 Project-Specific Instructions Review (Optional)**

```bash
# Check for optional project-specific instructions
"general-purpose: Check for .instructions/ directory and review any project-specific instructions, guidance, or constraints that supplement framework v3.7 methodology, noting that this directory is optional and may not exist"

# Integrate project instructions with framework methodology
"general-purpose: If .instructions/ exists, integrate project-specific guidance with framework methodology ensuring compatibility and complementary application, updating AI context accordingly"
```

### **0.3 AI Context Initialization**

```bash
# Create optimized AI context files
"general-purpose: Create AI context optimization files in .ai_context/ including current_context.md with project overview, team_patterns.md with coding standards, domain_context.md with domain knowledge, and deployment_context.md with infrastructure requirements following framework v3.7 patterns"

# Initialize AI assistant system prompt integration
"general-purpose: Initialize AI assistant with framework v3.7 system prompt from .framework/ai_system_prompt_v3.7.md ensuring complete framework integration and performance target understanding"
```

### **0.4 IDE Configuration & Development Environment**

```bash
# Detect IDE and create project configuration
"general-purpose: Analyze project structure, file types, and existing configuration files to determine the IDE being used (VS Code, IntelliJ, PyCharm, etc.). If unable to determine IDE, ask the human developer what IDE will be used for this project"

# Create IDE-specific configuration for framework v3.7
"general-purpose: Create IDE-specific configuration files for [detected/specified IDE] including settings optimized for the project using framework v3.7 for code formatting, linting, debugging, testing, and AI assistant integration following framework v3.7 development patterns"

# Setup development environment integration
"general-purpose: Configure development environment settings including file associations, build tasks, debugging configurations, and framework compliance validation tools for optimal framework v3.7 development experience"
```

### **0.5 Security-by-Design Foundation**

```bash
# Create initial threat model and security architecture
"gcp-ai-architect + security-auditor: Create comprehensive threat model and security-by-design architecture for [project name] following framework v3.7 security principles, including attack surface analysis, security controls specification, and threat mitigation strategies"

# Establish security requirements in EARS format
"security-auditor: Create security requirements in EARS format covering authentication, authorization, data protection, and compliance following REQ-SEC-XXX numbering scheme and framework v3.7 security patterns"
```

---

## 📋 **Phase 1: Requirements Analysis & Specification**

### **1.1 Business Vision & Product Definition**
```bash
# Create comprehensive product vision
"api-design-architect + project-manager: Create product.md with comprehensive business vision, system capabilities, stakeholder needs, and success criteria following framework v3.7 product specification format"

# Create Product Requirements Document (PRD)
"api-design-architect: Create PRD using prd_template_v3.7.md for [feature/system] including business objectives, user stories, functional requirements, and framework compliance specifications"
```

### **1.2 EARS Requirements Development**
```bash
# Create core system requirements
"api-design-architect + security-auditor: Create core system requirements in docs/ears/core_requirements.md using EARS format (WHEN-THE-SHALL-WITHIN) covering all primary system behaviors with complete requirement traceability"

# Create performance requirements
"performance-optimizer + api-design-architect: Create performance requirements in docs/ears/performance_requirements.md specifying response times, throughput, scalability, and availability targets in EARS format with measurable criteria"

# Create security requirements
"security-auditor: Create security requirements in docs/ears/security_requirements.md covering authentication, authorization, data protection, compliance, and threat mitigation in EARS format with security controls specification"

# Create integration requirements
"api-design-architect: Create integration requirements in docs/ears/integration_requirements.md covering external system integration, API specifications, data exchange, and interoperability in EARS format"
```

### **1.3 Requirements Validation & Traceability**
```bash
# Validate EARS requirements compliance
"project-manager: Validate all EARS requirements in docs/ears/ for format compliance, completeness, testability, and traceability ensuring 100% framework v3.7 compliance"

# Create requirements traceability matrix
"project-manager: Create comprehensive requirements traceability matrix mapping business objectives to EARS requirements to BDD scenarios ensuring complete coverage and framework compliance"
```

---

## 🧪 **Phase 2: Behavioral Specification & BDD Development**

### **2.1 Core BDD Scenario Development**
```bash
# Create core system behavior scenarios
"test-engineer: Create core system BDD scenarios in docs/bdd/core_scenarios.md validating EARS requirements from docs/ears/core_requirements.md using Given-When-Then format with complete behavioral coverage"

# Create security validation scenarios
"security-auditor + test-engineer: Create security BDD scenarios in docs/bdd/security_scenarios.md validating security requirements and threat model controls with penetration testing and security validation approaches"

# Create performance validation scenarios
"performance-optimizer + test-engineer: Create performance BDD scenarios in docs/bdd/performance_scenarios.md validating performance requirements including load testing, stress testing, and scalability validation"
```

### **2.2 Integration & Error Handling Scenarios**
```bash
# Create integration validation scenarios
"test-engineer + api-design-architect: Create integration BDD scenarios in docs/bdd/integration_scenarios.md validating external system integration, API behavior, and data exchange requirements"

# Create error handling and resilience scenarios
"test-engineer: Create error handling BDD scenarios in docs/bdd/error_handling_scenarios.md covering failure modes, recovery behaviors, graceful degradation, and system resilience validation"
```

### **2.3 BDD Scenario Validation**
```bash
# Validate BDD scenario coverage
"test-engineer + project-manager: Validate BDD scenario coverage ensuring all EARS requirements have corresponding behavioral scenarios with >95% coverage target and framework v3.7 compliance"
```

---

## 🏛️ **Phase 3: Architecture Decisions & Technical Design**

### **3.1 Architecture Decision Records (ADRs)**
```bash
# Create foundational ADRs
"gcp-ai-architect: Create foundational ADRs using adr_template_v3.7.md including ADR-0001 for framework adoption, ADR-0002 for technology stack selection, and ADR-0003 for architecture patterns with complete framework integration"

# Create security architecture ADRs
"gcp-ai-architect + security-auditor: Create security architecture ADRs covering authentication strategy, authorization patterns, data protection approach, and security controls implementation with threat model integration"

# Create deployment architecture ADRs
"gcp-ai-architect + cloud-devops-expert: Create deployment architecture ADRs covering cloud platform selection, infrastructure patterns, CI/CD strategy, and monitoring approach with AI-first deployment considerations"
```

### **3.2 Technical Design Specification**
```bash
# Create comprehensive technical design
"gcp-ai-architect: Create design.md with comprehensive technical architecture including system components, data flow, integration patterns, security architecture, and ADR references following framework v3.7 design specifications"

# Validate ADR decisions against requirements
"project-manager: Validate ADR decisions ensure alignment with EARS requirements, BDD scenarios, and framework v3.7 compliance with complete architectural traceability"
```

---

## 🤖 **Phase 4: AI-Optimized Implementation**

### **4.1 AI Context Optimization for Development**
```bash
# Optimize AI context for implementation phase
"general-purpose: Update .ai_context/ files with implementation context including current development priorities in current_context.md, established coding patterns in team_patterns.md, and domain-specific implementation guidance"

# Validate AI context effectiveness
"general-purpose: Validate AI context effectiveness by testing context loading speed (<5 seconds target), pattern recognition accuracy (>90% target), and development acceleration potential"
```

### **4.2 Core System Implementation**
```bash
# Implement core system features
"coder-agent: Implement core system features following EARS requirements REQ-CORE-XXX using framework patterns from .ai_context/team_patterns.md, ensuring BDD scenario validation and security-by-design principles"

# Implement API layer with security integration
"coder-agent + security-auditor: Implement API layer following EARS requirements REQ-API-XXX with integrated authentication, authorization, input validation, and security controls from threat model"

# Implement data layer with performance optimization
"coder-agent + database-specialist + performance-optimizer: Implement data layer following EARS requirements REQ-DATA-XXX with optimized queries, proper indexing, and performance targets from requirements"
```

### **4.3 Security Implementation**
```bash
# Implement security controls
"security-auditor + coder-agent: Implement security controls from threat model following security EARS requirements, ensuring authentication, authorization, data protection, and audit logging with framework security patterns"

# Security validation and testing
"security-auditor: Perform comprehensive security validation including vulnerability scanning, penetration testing, and security control verification against threat model and security requirements"
```

### **4.4 Integration Implementation**
```bash
# Implement external system integration
"coder-agent + api-design-architect: Implement external system integration following EARS requirements REQ-INT-XXX with proper error handling, retry logic, and integration patterns from design.md"

# Validate integration scenarios
"test-engineer: Execute integration BDD scenarios validating external system integration, API behavior, data exchange, and error handling according to docs/bdd/integration_scenarios.md"
```

---

## 🧪 **Phase 5: Testing & Quality Assurance**

### **5.1 BDD Scenario Execution**
```bash
# Execute core system BDD scenarios
"test-engineer: Execute core system BDD scenarios from docs/bdd/core_scenarios.md validating all implemented features against EARS requirements with automated test execution and results reporting"

# Execute security BDD scenarios
"security-auditor + test-engineer: Execute security BDD scenarios from docs/bdd/security_scenarios.md validating security controls, threat mitigation, and compliance requirements with security test automation"

# Execute performance BDD scenarios
"performance-optimizer + test-engineer: Execute performance BDD scenarios from docs/bdd/performance_scenarios.md validating performance requirements including load testing, stress testing, and performance benchmarks"
```

### **5.2 Comprehensive Quality Gates**
```bash
# Framework compliance validation
"project-manager: Execute comprehensive framework v3.7 compliance validation including structure compliance, requirements traceability, BDD coverage, ADR completeness, and quality gate satisfaction"

# Code quality and security review
"code-reviewer + security-auditor + performance-optimizer: Perform comprehensive code review including code quality, security compliance, performance optimization, and framework pattern adherence"

# Integration and system testing
"test-engineer: Execute comprehensive system testing including unit tests, integration tests, end-to-end tests, and system validation ensuring >95% test coverage and framework quality standards"
```

### **5.3 Performance & Security Validation**
```bash
# Performance testing and optimization
"performance-optimizer: Execute comprehensive performance testing including load testing, stress testing, scalability testing, and performance profiling ensuring all performance requirements are met"

# Security penetration testing
"security-auditor: Execute comprehensive security testing including vulnerability scanning, penetration testing, security control validation, and compliance verification against threat model"
```

---

## 🚀 **Phase 6: AI-First Deployment Preparation**

### **6.1 Deployment Context Optimization**
```bash
# Optimize deployment context for AI-first deployment
"cloud-devops-expert: Update .ai_context/deployment_context.md with complete infrastructure requirements, deployment procedures, monitoring configuration, and AI-first deployment patterns"

# Create infrastructure-as-code
"cloud-devops-expert: Create comprehensive infrastructure-as-code in deployment/terraform/ including main.tf, variables.tf, outputs.tf, and modules following framework v3.7 infrastructure patterns"
```

### **6.2 Deployment Automation Setup**
```bash
# Create Kubernetes deployment manifests
"cloud-devops-expert: Create Kubernetes deployment manifests in deployment/k8s/ including namespace.yaml, deployments.yaml, services.yaml, and ingress.yaml with security and performance optimization"

# Create deployment automation scripts
"cloud-devops-expert: Create deployment automation scripts in deployment/scripts/ including deploy.sh, rollback.sh, and validate.sh with comprehensive error handling and validation"

# Setup monitoring and observability
"cloud-devops-expert: Create monitoring configuration in deployment/monitoring/ including prometheus.yaml, grafana.yaml, and alerts.yaml with comprehensive system and business metrics"
```

### **6.3 Deployment Validation & Testing**
```bash
# Validate deployment automation
"cloud-devops-expert: Validate deployment automation by executing complete deployment cycle in staging environment including infrastructure provisioning, application deployment, and monitoring setup"

# Create deployment BDD scenarios
"cloud-devops-expert + test-engineer: Create deployment BDD scenarios validating infrastructure provisioning, application deployment, health checks, and monitoring configuration"
```

---

## 🌐 **Phase 7: Production Deployment & Validation**

### **7.1 Pre-Production Validation**
```bash
# Execute comprehensive pre-production validation
"project-manager: Execute comprehensive pre-production validation including framework compliance verification, security validation, performance testing, and deployment readiness assessment"

# Final security and compliance review
"security-auditor: Execute final security review including security control validation, compliance verification, penetration testing results review, and production security readiness assessment"

# Performance and scalability validation
"performance-optimizer: Execute final performance validation including load testing, scalability testing, performance benchmarks, and production readiness assessment"
```

### **7.2 Production Deployment Execution**
```bash
# Execute AI-first production deployment
"cloud-devops-expert: Execute AI-first production deployment following deployment.md strategy using deployment automation from deployment/scripts/ with comprehensive monitoring and validation"

# Validate production deployment
"cloud-devops-expert + test-engineer: Validate production deployment by executing deployment BDD scenarios, health checks, monitoring validation, and system functionality verification"

# Production smoke testing
"test-engineer: Execute production smoke testing including critical path validation, integration testing, security verification, and performance baseline establishment"
```

### **7.3 Post-Deployment Validation**
```bash
# Monitor system performance and security
"cloud-devops-expert + security-auditor: Monitor production system including performance metrics, security monitoring, error rates, and system health with automated alerting and reporting"

# Validate framework effectiveness
"project-manager: Measure framework effectiveness including development velocity improvement, quality metrics, deployment success rate, and framework compliance achievement"
```

---

## 📊 **Phase 8: Production Operations & Optimization**

### **8.1 Operational Monitoring**
```bash
# Setup comprehensive monitoring
"cloud-ops-engineer: Configure comprehensive production monitoring including application metrics, infrastructure monitoring, security monitoring, and business metrics with automated alerting"

# Performance optimization monitoring
"performance-optimizer + cloud-ops-engineer: Setup performance monitoring including response times, throughput, resource utilization, and scalability metrics with optimization recommendations"
```

### **8.2 Continuous Improvement**
```bash
# Framework effectiveness measurement
"project-manager: Measure framework v3.7 effectiveness including development velocity (target: 2-3x improvement), quality metrics (target: >95% defect reduction), deployment success (target: >95%), and AI optimization (target: <5s context loading)"

# AI context optimization
"general-purpose: Optimize AI context based on production learnings by updating .ai_context/ files with new patterns, lessons learned, and optimization opportunities for continuous improvement"

# Security posture review
"security-auditor: Conduct security posture review including threat model updates, security control effectiveness, compliance status, and security optimization opportunities"
```

### **8.3 Framework Evolution & Optimization**
```bash
# Document lessons learned and patterns
"refactoring-specialist + project-manager: Document lessons learned, new patterns, and optimization opportunities in .ai_context/team_patterns.md for framework improvement and knowledge sharing"

# Plan framework evolution
"project-manager: Plan framework evolution including identified improvements, optimization opportunities, pattern enhancements, and framework version planning for continuous advancement"
```

---

## 🎯 **Emergency & Troubleshooting Prompts**

### **Issue Resolution**
```bash
# Framework compliance troubleshooting
"project-manager: Analyze framework compliance issues including structure violations, requirements gaps, BDD coverage issues, or quality gate failures with systematic resolution planning"

# Performance issue resolution
"performance-optimizer + cloud-ops-engineer: Analyze performance issues including response time degradation, throughput problems, resource constraints, or scalability bottlenecks with optimization solutions"

# Security incident response
"security-auditor: Analyze security incidents including vulnerability detection, security control failures, compliance violations, or threat detection with immediate remediation actions"

# Deployment issue resolution
"cloud-devops-expert: Analyze deployment issues including infrastructure failures, application deployment problems, monitoring issues, or rollback requirements with rapid resolution strategies"
```

---

## 📚 **Quick Reference: Essential Workflow Commands**

### **🚨 MANDATORY PRE-WORK (Phase -1) - ALWAYS FIRST**
```bash
# 1. Migration Assessment (First Run Only)
"general-purpose: Review existing project structure against Framework v3.7, create migration plan"

# 2. Version Control Preparation (Every Run)
"Ask developer: Choose Option A (modify existing) or Option B (copy to new folder)"

# 3. Change Submission (Every Run) 
"general-purpose: Check git status, commit all changes, ensure clean working directory"

# 4. Pre-Work Validation (Every Run)
"project-manager: Validate ALL pre-work requirements complete before proceeding"
```

### **Framework Initialization (Phase 0) - Only After Pre-Work**
```bash
"general-purpose: Initialize Framework v3.7 with complete structure and AI context optimization"
```

### **Requirements & BDD Development**
```bash
"api-design-architect + test-engineer: Create EARS requirements and BDD scenarios for [functionality] with framework compliance"
```

### **Implementation with Quality Gates**
```bash
"coder-agent + security-auditor + test-engineer: Implement [functionality] with security integration and BDD validation"
```

### **Quality Assurance & Validation**
```bash
"project-manager: Execute comprehensive quality validation including framework compliance and all quality gates"
```

### **AI-First Deployment**
```bash
"cloud-devops-expert: Execute AI-first deployment with infrastructure automation and comprehensive validation"
```

---

## 🎯 **Success Metrics & Validation**

### **Framework Effectiveness Targets**

- **Development Velocity**: 2-3x improvement over traditional development
- **Quality Assurance**: >95% defect reduction and quality gate success
- **Security Integration**: >95% security-by-design implementation
- **Deployment Success**: >95% automated deployment success rate
- **AI Optimization**: <5 second context loading, >90% code accuracy
- **Framework Compliance**: 100% structure compliance, >95% implementation adherence

### **Continuous Measurement**

```bash
# Measure framework effectiveness
"project-manager: Measure and report framework v3.7 effectiveness including all success metrics, compliance rates, and optimization opportunities with monthly framework performance review"
```

---

*Workflow Prompts Version: v3.7 - Complete Development Lifecycle*  
*Framework: AI Agent Development Framework v3.7*  
*Created: 2025-08-16*

*Purpose: Systematic AI assistant guidance from initialization to production excellence*