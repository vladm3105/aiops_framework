# Universal Session Management Protocols

**Version:** 3.7 - Universal Session Management Edition
**Date:** 2025-08-22
**Purpose:** Standardized session management protocols for all Framework v3.7 projects
**Scope:** Cross-project compatibility and AI assistant workflow optimization

---

## 🎯 **Session Management Overview**

### **Framework v3.7 Session Management Philosophy**

The Framework v3.7 implements a **Hybrid Session Management System** that combines:
- **Clean Session Focus**: Each session starts with clear, prioritized tasks
- **Cumulative Progress Tracking**: Complete historical record of all achievements
- **Cross-Session Continuity**: Seamless context preservation across sessions
- **Framework Compliance**: Maintained quality gates and methodology adherence
- **Universal Compatibility**: Consistent experience across all framework phases
- **Complete Lifecycle Support**: Init → Development → Deployment → Validation → Operations workflow

### **Core Session Management Components**

1. **TodoWrite Tool**: Real-time session task management across all frameworks
2. **.ai_context/framework_progress.md**: Master state file (single source of truth)
3. **Framework-Specific Protocols**: Specialized session management for each phase
4. **Git Integration**: Immutable session evidence and audit trail
5. **Human Oversight**: Strategic decision points and approval requirements

### **TodoWrite Tool Integration Standards**

#### **Required TodoWrite Behaviors**
```markdown
TodoWrite Tool Requirements:
1. **Single Focus Enforcement**: Prevent multiple IN_PROGRESS tasks
2. **Real-Time Updates**: Immediate status reflection and state management
3. **Framework Phase Alignment**: Validates tasks align with current framework phase
4. **Quality Gates**: Enforces quality validation before task completion
5. **Human Checkpoints**: Identifies required human approval points
```

#### **Session Management Rules**
```markdown
Universal Session Rules:
1. **ONE TASK RULE**: Only ONE task can be "IN_PROGRESS" at any time
2. **Status Updates**: Use TodoWrite tool for immediate status changes
3. **Framework Alignment**: Ensure session tasks align with current framework phase
4. **Quality Validation**: Validate deliverables before marking completed
5. **Human Approval**: Required at designated framework checkpoints
```

### **Framework-Specific Session Management**

Each framework phase has specialized session management protocols:

- **Init Framework**: [Safety-First Session Management](init/session_management_protocols_init.md)
- **Development Framework**: [Quality-Driven Session Management](development/session_management_protocols_development.md)
- **Deployment Framework**: [Production-Ready Session Management](deployment/session_management_protocols_deployment.md)
- **Validation Framework**: [Post-Deployment Validation Session Management](validation/session_management_protocols_validation.md)
- **Operations Framework**: [Autonomous Operations Session Management](operations/session_management_protocols_operations.md)

### **Session Lifecycle Protocol**

#### **Session Start (Every Session)**
1. **Context Loading**: Load .ai_context/framework_progress.md as authoritative state
2. **Phase Determination**: Identify current framework phase and requirements
3. **Priority Setting**: Set session goals based on framework phase objectives
4. **Environment Validation**: Ensure all prerequisites satisfied for current phase

#### **Session Work (Continuous)**
1. **Single Focus Discipline**: Only ONE task IN_PROGRESS at any time
2. **Real-Time Updates**: Immediate status changes via TodoWrite tool
3. **Quality Gates**: Comprehensive validation before task completion
4. **Framework Compliance**: Maintain adherence to Framework v3.7 methodology

#### **Session End (Every Session)**
1. **Task Completion**: Complete all IN_PROGRESS tasks or document handoff
2. **State Updates**: Update .ai_context/framework_progress.md with achievements
3. **Git Commitment**: Commit all session work with comprehensive messages
4. **Next Session Preparation**: Prepare context for seamless continuation
