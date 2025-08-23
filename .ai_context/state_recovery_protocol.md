# AI Assistant State Recovery Protocol
## .ai_context Single Source of Truth System

**Version:** 3.7 - Authoritative State Management Edition  
**Date:** 2025-08-22  
**Purpose:** Complete AI assistant state recovery using .ai_context as single source of truth  

---

## 🎯 **SINGLE SOURCE OF TRUTH PRINCIPLE**

### **Primary State Authority: .ai_context/framework_progress.md**

**CRITICAL RULE**: All AI assistant state recovery MUST use `.ai_context/framework_progress.md` as the **authoritative source**. No other files, directories, or systems override this master state file.

```bash
# MANDATORY first action on AI assistant restart
"general-purpose: Load .ai_context/framework_progress.md as authoritative state source and execute complete state recovery protocol"
```

---

## 🔄 **STATE RECOVERY PROTOCOL**

### **Step 1: Load Master State (MANDATORY)**
```bash
# Primary state loading command
"general-purpose: Read .ai_context/framework_progress.md completely and parse current framework implementation status including:
1. Current overall status and active phase
2. All phase completion status with JSON validation
3. Current task execution state
4. Framework compliance status
5. AI assistant configuration state"
```

### **Step 2: Validate State Integrity**
```bash
# State validation commands
"project-manager: Validate .ai_context/framework_progress.md state integrity including:
1. JSON syntax validation for all phase status blocks
2. State consistency validation across all phases
3. Task queue validation and dependency verification
4. Framework compliance status validation
5. AI context configuration validation"
```

### **Step 3: Determine Recovery Action**
```bash
# Recovery decision based on master state
"project-manager: Based on .ai_context/framework_progress.md state, determine recovery action:

IF current_phase == 'ready' AND active_task == null:
  ACTION: 'Begin Phase -1 pre-work when project initiated'
  
IF current_phase == 'in_progress' AND active_task != null:
  ACTION: 'Resume active task: [task_name] in [current_phase]'
  
IF current_phase == 'completed' AND next_phase == 'ready':
  ACTION: 'Await human approval to proceed to [next_phase]'
  
IF framework_status == 'complete':
  ACTION: 'Execute maintenance and optimization mode'"
```

### **Step 4: Execute Recovery**
```bash
# Execute determined recovery action
"general-purpose: Execute recovery action determined from .ai_context/framework_progress.md state analysis and proceed with framework implementation from correct resumption point"
```

---

## 📊 **STATE UPDATE AUTOMATION**

### **Continuous State Maintenance**

**Every Task Completion:**
```bash
# Automated state update command
"general-purpose: Update .ai_context/framework_progress.md with task completion:
1. Update current task status to 'completed'
2. Update phase deliverables status 
3. Update next_action field
4. Update timestamp and update_by fields
5. Validate JSON integrity after update"
```

**Every Phase Transition:**
```bash
# Phase transition state update
"project-manager: Update .ai_context/framework_progress.md with phase transition:
1. Mark completed phase status as 'completed': true
2. Update all deliverables to 'completed' status
3. Set next phase status to 'ready' or 'in_progress'
4. Update overall framework status
5. Log phase transition in update history"
```

**Every Human Approval:**
```bash
# Human approval state update
"project-manager: Update .ai_context/framework_progress.md with human approval:
1. Add human approval timestamp
2. Update phase approval status
3. Enable next phase transition
4. Update approval gate status
5. Log human interaction history"
```

---

## 🛡️ **STATE INTEGRITY PROTECTION**

### **Automated Validation Rules**

**Before Every Update:**
```bash
# Pre-update validation
"general-purpose: Before updating .ai_context/framework_progress.md:
1. Validate current JSON structure integrity
2. Create backup of current state
3. Verify update permissions and authority
4. Validate update against framework rules
5. Ensure no conflicting state changes"
```

**After Every Update:**
```bash
# Post-update validation
"general-purpose: After updating .ai_context/framework_progress.md:
1. Validate JSON syntax correctness
2. Verify state consistency across all phases
3. Confirm update integrity and completeness
4. Validate dependency relationships
5. Update state checksum for integrity verification"
```

### **Error Recovery and Rollback**

**State Corruption Detection:**
```bash
# Corruption detection and recovery
"project-manager: If .ai_context/framework_progress.md corruption detected:
1. Log corruption event with timestamp
2. Restore from most recent valid backup
3. Validate restored state integrity
4. Identify corruption cause and prevention
5. Resume framework implementation from validated state"
```

---

## 🤖 **AI ASSISTANT RESTART SCENARIOS**

### **Scenario 1: Fresh Framework Start**
```json
{
  "framework_progress_state": "all_phases_ready_not_started",
  "recovery_action": "begin_phase_minus_1_preWork",
  "expected_duration": "5_minutes_setup",
  "human_interaction": "required_for_project_choice"
}
```

### **Scenario 2: Mid-Phase Recovery**
```json
{
  "framework_progress_state": "phase_3_architecture_50_percent_complete",
  "recovery_action": "resume_adr_development_from_security_architecture",
  "expected_duration": "immediate_resumption",
  "human_interaction": "not_required_unless_critical_decision"
}
```

### **Scenario 3: Human Approval Pending**
```json
{
  "framework_progress_state": "phase_5_implementation_complete_awaiting_approval",
  "recovery_action": "prepare_human_checkpoint_for_phase_6_approval", 
  "expected_duration": "immediate_preparation",
  "human_interaction": "required_for_phase_transition_approval"
}
```

### **Scenario 4: Framework Complete**
```json
{
  "framework_progress_state": "all_phases_complete_production_operational",
  "recovery_action": "enter_maintenance_and_optimization_mode",
  "expected_duration": "immediate_transition",
  "human_interaction": "periodic_strategic_oversight"
}
```

---

## 📋 **STATE QUERY COMMANDS**

### **Quick State Assessment**
```bash
# Rapid state check commands
"general-purpose: Quick framework state check - read current phase and active task from .ai_context/framework_progress.md"

"project-manager: Framework compliance check - validate all phase status and framework compliance metrics from master state file"

"project-manager: Next action determination - identify immediate next required action based on current state"
```

### **Detailed State Analysis**
```bash
# Comprehensive state analysis
"project-manager: Complete framework state analysis including:
1. All phase completion status and deliverables
2. Current task execution state and dependencies  
3. Human approval status and pending decisions
4. Framework compliance and quality metrics
5. AI assistant performance and optimization status"
```

---

## 🔧 **STATE MANAGEMENT BEST PRACTICES**

### **Update Principles**
1. **Atomic Updates**: All state changes must be complete and consistent
2. **Immediate Updates**: State changes recorded immediately upon completion
3. **Validation Required**: Every update must pass integrity validation
4. **Backup Protection**: Previous state backed up before changes
5. **Human Visibility**: Critical state changes require human notification

### **Recovery Principles**
1. **Master State Authority**: .ai_context/framework_progress.md is definitive
2. **Fast Recovery**: <2 minutes from restart to operational
3. **Accurate Resumption**: Exact continuation from interruption point
4. **Human Confirmation**: Critical recovery decisions confirmed with human
5. **Error Resilience**: Multiple recovery methods and rollback capability

### **Maintenance Principles**
1. **Continuous Validation**: Regular state integrity verification
2. **Performance Optimization**: State access and updates optimized for speed
3. **Documentation**: All state changes logged and documented
4. **Evolution**: State management system continuously improved
5. **Security**: State management protected from unauthorized access

---

## 🎯 **STATE RECOVERY SUCCESS CRITERIA**

### **Recovery Performance Targets**
- **Recovery Time**: <2 minutes from restart to operational
- **Accuracy**: 100% accurate state determination
- **Continuity**: Seamless resumption without duplicate work
- **Integrity**: 100% state consistency maintained
- **Human Interaction**: Minimal human intervention required

### **Quality Assurance**
- **State Validation**: 100% automated validation before recovery
- **Error Detection**: Immediate corruption or inconsistency detection
- **Recovery Testing**: Regular recovery scenario testing and validation
- **Documentation**: Complete state management documentation maintained
- **Performance Monitoring**: State management performance continuously tracked

---

*AI Assistant State Recovery Protocol - Single Source of Truth*  
*Version: v3.7 - Authoritative State Management*  
*Created: 2025-08-22*  
*Purpose: Complete state recovery using .ai_context as definitive authority*