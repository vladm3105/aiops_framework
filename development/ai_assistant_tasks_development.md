# AI Assistant Development Tasks - Framework v3.7
## Development Phases: Pre-Work through Implementation (Phases -1 to 6)

**Version:** 3.7 - AI Development Task Automation Edition  
**Date:** 2025-08-22  
**Framework:** AI Agent Development Framework v3.7  
**Purpose:** Complete AI Assistant task automation for development lifecycle  
**Scope:** Phase -1 (Pre-Work) through Phase 6 (Testing & QA)  

---

## 🚨 **CRITICAL: MANDATORY PRE-WORK REQUIREMENTS (PHASE -1)**

### **AI Assistant Commands for Pre-Work**

#### **-1.1 Initial Project Migration Assessment (First Run Only)**
```bash
# Project Analysis and Migration Planning
"general-purpose: Review all existing project files, analyze directory structure, create detailed migration plan with specific actionable tasks, and document migration risks with mitigation strategies"
```

#### **-1.2 Version Control Preparation (Every Run)**
```bash
# Mandatory Project Structure Analysis
"general-purpose: Check git/GitHub availability, verify Framework v3.7 root files exist, validate framework directories structure, and identify missing framework files requiring creation"

# Framework Compliance Validation
"project-manager: Execute comprehensive framework compliance validation including root files check, documentation structure verification, and gap remediation planning"

# MANDATORY HUMAN INTERACTION REQUIRED
# AI Assistant MUST ask: "Human Developer: Before I can proceed with Framework v3.7 implementation, I need your explicit choice: Option A: Modify existing files in current project OR Option B: Copy project to separated folder and create new version. Please respond with: 'I choose Option A' or 'I choose Option B'"
```

#### **-1.3 Change Submission Protocol (Every Run)**
```bash
# Git Status and Clean Working Directory
"general-purpose: Execute comprehensive git status check, commit ALL existing changes to version control, and verify git working directory is completely clean before proceeding"
```

#### **-1.4 Pre-Work Completion Validation**
```bash
# Validate All Pre-Work Requirements
"project-manager: Validate ALL three mandatory pre-work requirements completed (migration assessment, version control preparation, change submission) and confirm ready to proceed to Phase 0"
```

---

## 🚀 **PHASE 0: FRAMEWORK INITIALIZATION & SETUP**

### **AI Assistant Commands for Framework Setup**

#### **0.1 Framework Structure Setup**
```bash
# Execute Migration Plan or Initialize Structure
"general-purpose: Execute migration plan or initialize Framework v3.7 structure based on developer choice, create all required directories per development_framework_v3.7.md, and validate complete structure compliance"
```

#### **0.2 Project-Specific Instructions Review**
```bash
# Integrate Project-Specific Guidance
"general-purpose: Check for .instructions/ directory, review project-specific guidance, and integrate with Framework v3.7 methodology ensuring compatibility and compliance"
```

#### **0.3 AI Context Initialization**
```bash
# Create AI Context Files
"general-purpose: Create .ai_context/ files (current_context.md, team_patterns.md, domain_context.md, deployment_context.md) and initialize AI assistant with Framework v3.7 system prompt for optimal performance"
```

#### **0.4 IDE Configuration & Development Environment**
```bash
# Development Environment Setup
"general-purpose: Analyze project structure to determine IDE, create IDE-specific configuration optimized for Framework v3.7, and configure development environment including file associations, build tasks, and debugging"
```

#### **0.5 Security-by-Design Foundation**
```bash
# Security Foundation with Multi-Agent Coordination
"gcp-ai-architect: Work with security-auditor to create comprehensive threat model and security-by-design architecture"
"security-auditor: Establish security requirements in EARS format and validate threat model completeness"
```

#### **0.6 Phase 0 Validation**
```bash
# Phase 0 Completion Validation
"project-manager: Validate Framework v3.7 structure 100% compliance, AI context optimization ready, development environment configured, security foundation established, and create Phase 0 validation report in docs/validation/phase_0_completion_report.md"
```

---

## 📋 **PHASE 1: REQUIREMENTS ANALYSIS & SPECIFICATION**

### **AI Assistant Commands for Requirements Development**

#### **1.1 Business Vision & Product Definition**
```bash
# Business Vision and PRD Creation
"api-design-architect: Work with project-manager to create product.md.template with business vision, system capabilities, and stakeholder needs"
"project-manager: Create comprehensive PRD using prd_template_v3.7.md with business objectives, user stories, and stakeholder requirements"
```

#### **1.2 EARS Requirements Development**
```bash
# Core System Requirements
"api-design-architect: Work with security-auditor to create docs/ears/core_requirements.md using EARS format with comprehensive system requirements"

# Performance Requirements
"performance-optimizer: Work with api-design-architect to create docs/ears/performance_requirements.md with measurable performance criteria and targets"

# Security Requirements  
"security-auditor: Create docs/ears/security_requirements.md covering authentication, authorization, data protection, and compliance requirements"

# Integration Requirements
"api-design-architect: Create docs/ears/integration_requirements.md covering external systems, APIs, data exchange, and interoperability requirements"
```

#### **1.3 Requirements Validation & Traceability**
```bash
# EARS Compliance and Traceability
"project-manager: Validate EARS compliance for all requirements documents and create comprehensive traceability matrix mapping business objectives to EARS requirements"
```

#### **1.4 Phase 1 Human Checkpoint and Validation**
```bash
# Phase 1 Completion Validation
"project-manager: Create Phase 1 validation report in docs/validation/phase_1_completion_report.md and prepare human checkpoint review including product vision, PRD documents, EARS requirements, and traceability matrix"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 1 requirements analysis. Please review: 1. Product vision and PRD documents in docs/prd/ 2. EARS requirements in docs/ears/ 3. Requirements traceability matrix. Do you approve these requirements to proceed to Phase 2 BDD development?"
```

---

## 🧪 **PHASE 2: BEHAVIORAL SPECIFICATION & BDD DEVELOPMENT**

### **AI Assistant Commands for BDD Development**

#### **2.1 Core System BDD Scenarios**
```bash
# Comprehensive BDD Scenario Development
"test-engineer: Create comprehensive BDD scenarios in docs/bdd/core_system_bdd.md covering all core system functionality"
"test-engineer: Create integration BDD scenarios in docs/bdd/integration_bdd.md covering all external system integrations"
```

#### **2.2 Performance & Security BDD Scenarios**
```bash
# Performance BDD Development
"test-engineer: Work with performance-optimizer to create docs/bdd/performance_bdd.md validating response times, throughput, scalability, and performance targets"

# Security BDD Development
"test-engineer: Work with security-auditor to create docs/bdd/security_bdd.md validating authentication, authorization, data protection, and security controls"
```

#### **2.3 BDD Validation & Coverage Analysis**
```bash
# BDD Coverage and Execution Framework
"project-manager: Execute comprehensive BDD coverage analysis ensuring 100% EARS requirements validation"
"test-engineer: Create BDD execution framework for automated scenario testing and continuous validation"
```

#### **2.4 Phase 2 Human Checkpoint and Validation**
```bash
# Phase 2 Completion Validation
"project-manager: Create Phase 2 validation report in docs/validation/phase_2_completion_report.md and prepare human checkpoint review including BDD scenarios coverage and execution framework"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 2 BDD scenario development. Please review: 1. BDD scenarios in docs/bdd/ covering all requirements 2. BDD coverage analysis and validation framework. Do you approve these BDD scenarios to proceed to Phase 3 architecture?"
```

---

## 🏗️ **PHASE 3: ARCHITECTURE & ADR DEVELOPMENT**

### **AI Assistant Commands for Architecture Development**

#### **3.1 System Architecture Design**
```bash
# System Architecture and ADR Foundation
"gcp-ai-architect: Create or update design.md.template with comprehensive technical architecture including system overview, component interactions, and technology stack"
"gcp-ai-architect: Create foundational ADRs using adr_template_v3.7.md for core architectural decisions"
```

#### **3.2 Security & Performance Architecture**
```bash
# Security Architecture Development
"security-auditor: Work with gcp-ai-architect to create security architecture ADRs covering authentication mechanisms, data protection, access controls, and security patterns"

# Performance Architecture Development
"performance-optimizer: Work with gcp-ai-architect to create performance architecture ADRs covering scalability patterns, caching strategies, optimization techniques, and performance targets"
```

#### **3.3 Integration & Deployment Architecture**
```bash
# Integration Architecture Development
"api-design-architect: Work with gcp-ai-architect to create integration ADRs covering API design, external system integration, data flow, and communication patterns"

# Deployment Architecture Development
"cloud-devops-expert: Work with gcp-ai-architect to create deployment architecture ADRs covering infrastructure patterns, deployment strategies, scaling approaches, and operational requirements"
```

#### **3.4 Phase 3 Human Checkpoint and Validation**
```bash
# Validated Architecture Document Creation
"gcp-ai-architect: Create docs/validation/validated_architecture.md consolidating all architectural decisions, ADRs, and design components into single implementation-ready specification with complete technical guidance"

# Phase 3 Completion Validation
"project-manager: Create Phase 3 validation report in docs/validation/phase_3_completion_report.md and prepare human checkpoint review including system architecture, ADR decisions, and validated architecture document"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 3 architecture and ADR development. Please review: 1. System architecture in design.md.template 2. ADR decisions in docs/adr/ with complete rationale 3. Security, performance, integration, and deployment architecture. Do you approve this architecture to proceed to Phase 4 specifications?"
```

---

## 📋 **PHASE 4: TECHNICAL SPECIFICATIONS & DEPLOYMENT STRATEGY**

### **AI Assistant Commands for Technical Specifications**

#### **4.1 Architectural Component Mapping (PRE-STEP)**
```bash
# Component Identification and Mapping
"system-architect: Create docs/specs/ARCHITECTURAL_COMPONENT_MAPPING.md identifying ALL architectural components from Phase 3 with individual component analysis and one-to-one SPECS assignment"

# SPECS Document Master Plan
"project-manager: Create docs/specs/SPECS_DOCUMENT_LIST.md with complete master plan for Phase 4 including component prioritization by product phases (MVP, V1, V2, V3) and sequential SPECS numbering"
```

#### **4.2 Technical Specifications Development**
```bash
# Product Phase Component Specifications
"project-manager: Create component specifications for selected Product Phase with each architectural component having dedicated SPECS-NNNN file based on ARCHITECTURAL_COMPONENT_MAPPING.md and product phase selection"

# HUMAN DECISION REQUIRED: Product Phase Selection
# Options: MVP (20 components), V1 (44 components), V2 (12 components), V3 (3 components)
```

#### **4.3 Agent-Specialized Implementation Assignments**
```bash
# API & Security Specifications
"api-design-architect: Work with security-auditor to create API and security specifications for selected product phase components"

# Data & Performance Specifications
"database-specialist: Work with performance-optimizer to create data and performance specifications for selected product phase components"

# Integration & Deployment Specifications
"cloud-devops-expert: Create integration and deployment specifications for selected product phase components"

# Testing & Operations Specifications
"test-engineer: Create testing and operations specifications for selected product phase components"
```

#### **4.4 Phase 4 Human Checkpoint and Validation**
```bash
# Phase 4 Completion Validation
"project-manager: Create Phase 4 validation report in docs/validation/phase_4_completion_report.md and prepare human checkpoint review including architectural component mapping, technical specifications, and product phase selection"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 4 technical specifications for the selected Product Phase. Please review: 1. ARCHITECTURAL_COMPONENT_MAPPING.md with 79 total components mapped to Product Phases 2. Technical specifications in docs/specs/ for selected Product Phase components 3. All components for the chosen Product Phase have dedicated SPECS-NNNN files 4. Product Phase implementation strategy defined. CRITICAL DECISION REQUIRED: Which Product Phase should we implement in Phase 5?"
```

---

## 💻 **PHASE 5: IMPLEMENTATION & CODING**

### **AI Assistant Commands for Implementation**

#### **5.1 Core System Implementation**
```bash
# Core System Development
"coder-agent: Implement core system functionality following technical specifications from selected product phase with Framework v3.7 compliance"

# Data Layer Implementation
"database-specialist: Work with coder-agent to implement data layer including database schema, data access patterns, and data validation following technical specifications"

# API Layer Implementation
"api-design-architect: Work with coder-agent to implement API endpoints following API specifications with proper error handling and validation"
```

#### **5.2 Security & Performance Implementation**
```bash
# Security Controls Implementation
"security-auditor: Work with coder-agent to implement security controls including authentication, authorization, access controls, and security validation following security specifications"

# Performance Optimizations Implementation
"performance-optimizer: Work with coder-agent to implement performance optimizations including caching, optimization patterns, and performance monitoring following performance specifications"
```

#### **5.3 Integration & Error Handling**
```bash
# External Integrations Implementation
"coder-agent: Implement external system integrations following integration specifications with proper error handling and fallback mechanisms"

# Comprehensive Error Handling
"coder-agent: Implement comprehensive error handling, logging, monitoring integration, and operational instrumentation throughout the system"
```

#### **5.4 Phase 5 Human Checkpoint and Validation**
```bash
# Phase 5 Completion Validation
"project-manager: Create Phase 5 validation report in docs/validation/phase_5_completion_report.md and prepare human checkpoint review including core system implementation, security controls, performance optimizations, and integration completeness"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 5 implementation. Please review: 1. Core system implementation with all functionality 2. Security controls and performance optimizations 3. External integrations and error handling. Do you approve this implementation to proceed to Phase 6 testing?"
```

---

## 🧪 **PHASE 6: TESTING & QUALITY ASSURANCE**

### **AI Assistant Commands for Testing & QA**

#### **6.1 BDD Scenario Testing**
```bash
# BDD Scenario Execution
"test-engineer: Execute all BDD scenarios created in Phase 2 against implemented code with comprehensive validation and reporting"

# Automated Testing Framework
"test-engineer: Create automated test framework for continuous BDD scenario execution with integration into development workflow"
```

#### **6.2 Security & Performance Testing**
```bash
# Security Testing Execution
"security-auditor: Execute comprehensive security testing including vulnerability scanning, penetration testing, and security validation against security requirements"

# Performance Testing Execution
"performance-optimizer: Execute performance testing including load testing, stress testing, and performance validation against performance targets"
```

#### **6.3 Integration & System Testing**
```bash
# Integration Testing Execution
"test-engineer: Execute integration testing validating external system connections, data flow, and integration requirements"

# System Testing Coordination
"project-manager: Execute comprehensive system testing including end-to-end workflows, user scenarios, and complete system validation"
```

#### **6.4 Phase 6 Human Checkpoint and Validation**
```bash
# Phase 6 Completion Validation
"project-manager: Create Phase 6 validation report in docs/validation/phase_6_completion_report.md and prepare human checkpoint review including BDD test results, security testing, performance testing, and system testing outcomes"

# HUMAN CHECKPOINT REQUIRED: "Human Developer: I have completed Phase 6 testing and quality assurance. Please review: 1. BDD scenario test results with all scenarios passing 2. Security testing results with vulnerability assessment 3. Performance testing results meeting all targets. Do you approve this testing to proceed to Phase 7 deployment preparation?"
```

---

## 📊 **Development Framework Success Metrics**

### **Target Performance Indicators for Development Phases**

**Framework Compliance:**
- 100% Framework v3.7 structure compliance achieved
- 100% EARS requirements traceability maintained
- 100% BDD scenario coverage for all requirements
- 100% security-by-design implementation

**Quality Assurance:**
- >95% BDD scenario pass rate
- >95% security testing validation
- >95% performance target achievement
- >95% integration testing success

**Development Acceleration:**
- 2-3x development velocity improvement
- <5 second AI context loading time
- >90% AI code generation accuracy
- >95% first-time implementation success

---

## 🎯 **Development Framework Completion Validation**

### **Essential Checkpoints for Development Success**

```bash
# Complete Development Framework Validation
"project-manager: Execute complete development framework validation including all phases (-1 through 6), human approvals, validation reports, requirements traceability, BDD coverage, architecture validation, implementation completeness, and testing success before handoff to deployment framework"
```

**Development Framework Output for Deployment Handoff:**
- ✅ Complete Framework v3.7 structure with full compliance
- ✅ Validated requirements (EARS format) with complete traceability
- ✅ Architecture documentation (ADRs) with implementation guidance
- ✅ Production-ready code with comprehensive testing validation
- ✅ Security-by-design integration throughout development lifecycle
- ✅ Deployment preparation materials ready for Deployment Framework

---

*AI Assistant Development Tasks Version: v3.7 - Complete Development Automation*  
*Framework: AI Agent Development Framework v3.7*  
*Created: 2025-08-22*  
*Purpose: Complete AI Assistant task automation for development lifecycle phases*