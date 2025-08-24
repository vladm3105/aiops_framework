# Automated State Updates Protocol
## .ai_context Single Source of Truth Maintenance

**Version:** 3.7 - Automated State Management Edition  
**Date:** 2025-08-23  
**Purpose:** Complete automated state update protocol for AI assistant operations  

---

## 🎯 **AUTOMATED STATE UPDATE REQUIREMENTS**

### **MANDATORY: Every Task Completion**

**All AI agents MUST update the master state after completing ANY task:**

```bash
# MANDATORY after every task completion
"general-purpose: Update .ai_context/framework_progress.md with task completion including:
1. Update current task status to 'completed'
2. Update phase deliverables status if applicable
3. Update next_action field with immediate next step
4. Update timestamp and update_by fields
5. Validate JSON integrity after update"
```

### **MANDATORY: Every Phase Transition**

**All AI agents MUST update master state when transitioning between phases:**

```bash
# MANDATORY for phase transitions
"project-manager: Update .ai_context/framework_progress.md with phase transition including:
1. Mark completed phase status as 'completed': true
2. Update all deliverables to 'completed' status
3. Set next phase status to 'ready' or 'in_progress'
4. Update overall framework status
5. Log phase transition in update history"
```

### **MANDATORY: Every Human Approval**

**All AI agents MUST update master state when receiving human approval:**

```bash
# MANDATORY for human approvals
"project-manager: Update .ai_context/framework_progress.md with human approval including:
1. Add human approval timestamp
2. Update phase approval status to 'approved'
3. Enable next phase transition capability
4. Update approval gate status
5. Log human interaction history"
```

---

## 🔄 **STATE UPDATE AUTOMATION COMMANDS**

### **Task-Level State Updates**

#### **Starting a New Task**
```bash
# When beginning any new task
"general-purpose: Update .ai_context/framework_progress.md active task to 'in_progress' with task details: [task_name], estimated completion: [time], assigned agent: [agent_name]"
```

#### **Task Progress Updates**
```bash
# For long-running tasks with milestones
"general-purpose: Update .ai_context/framework_progress.md task progress: [task_name] - milestone [X] of [Y] completed, estimated remaining: [time]"
```

#### **Task Completion**
```bash
# When completing any task
"general-purpose: Update .ai_context/framework_progress.md task completion: [task_name] status changed to 'completed', deliverables: [list], next_action: [immediate_next_step]"
```

#### **Task Error/Retry**
```bash
# When task encounters errors
"general-purpose: Update .ai_context/framework_progress.md task error: [task_name] encountered [error_type], retry attempt [X], recovery action: [action]"
```

### **Phase-Level State Updates**

#### **Phase Initiation**
```bash
# When starting a new phase
"project-manager: Update .ai_context/framework_progress.md phase initiation: Phase [X] status changed to 'in_progress', estimated duration: [time], dependencies verified"
```

#### **Phase Milestone Completion**
```bash
# When completing major phase milestones
"project-manager: Update .ai_context/framework_progress.md phase milestone: Phase [X] - [milestone_name] completed, remaining deliverables: [list]"
```

#### **Phase Completion**
```bash
# When completing entire phase
"project-manager: Update .ai_context/framework_progress.md phase completion: Phase [X] status changed to 'completed', all deliverables validated, ready for human approval"
```

#### **Phase Validation**
```bash
# After phase validation
"project-manager: Update .ai_context/framework_progress.md phase validation: Phase [X] validation completed, quality gates passed, framework compliance verified"
```

---

## 📊 **SPECIALIZED STATE UPDATES**

### **Framework Compliance Updates**

#### **Structure Compliance**
```bash
# Framework structure validation updates
"project-manager: Update .ai_context/framework_progress.md framework compliance: structure validation [passed/failed], compliance percentage: [X%], gaps identified: [list]"
```

#### **Quality Gate Updates**
```bash
# Quality gate validation updates
"project-manager: Update .ai_context/framework_progress.md quality gates: [gate_name] status [passed/failed], success rate: [X%], issues resolved: [count]"
```

### **Multi-Agent Coordination Updates**

#### **Agent Handoff**
```bash
# When handing off between agents
"[source_agent]: Update .ai_context/framework_progress.md agent handoff: [source_agent] completed [task], handing off to [target_agent] for [next_task]"
```

#### **Multi-Agent Task Completion**
```bash
# When multiple agents complete coordinated task
"project-manager: Update .ai_context/framework_progress.md multi-agent completion: [task_name] completed by [agent_list], coordination successful, deliverables: [list]"
```

### **Human Interaction Updates**

#### **Human Checkpoint Preparation**
```bash
# When preparing human checkpoint
"project-manager: Update .ai_context/framework_progress.md human checkpoint: Phase [X] prepared for human review, deliverables ready: [list], approval required for progression"
```

#### **Human Approval Received**
```bash
# When receiving human approval
"project-manager: Update .ai_context/framework_progress.md human approval: Phase [X] approved by human developer, progression authorized to Phase [Y], approval timestamp: [time]"
```

#### **Human Feedback Integration**
```bash
# When integrating human feedback
"general-purpose: Update .ai_context/framework_progress.md human feedback: feedback received for [item], changes required: [list], integration status: [in_progress/completed]"
```

---

## 🛡️ **STATE VALIDATION AND INTEGRITY**

### **Pre-Update Validation**

**MANDATORY before every state update:**
```bash
# Validate before updating
"general-purpose: Validate .ai_context/framework_progress.md before update including:
1. JSON syntax validation
2. State consistency verification
3. Backup creation of current state
4. Update permission validation
5. Conflict detection and resolution"
```

### **Post-Update Validation**

**MANDATORY after every state update:**
```bash
# Validate after updating
"general-purpose: Validate .ai_context/framework_progress.md after update including:
1. JSON syntax correctness verification
2. State consistency across all phases
3. Update integrity confirmation
4. Dependency relationship validation
5. State checksum update for integrity verification"
```

### **Error Recovery Updates**

#### **State Corruption Detection**
```bash
# When state corruption detected
"project-manager: Update .ai_context/framework_progress.md corruption event: corruption detected at [timestamp], backup restored from [backup_timestamp], recovery action: [action]"
```

#### **Recovery Completion**
```bash
# When recovery completed
"project-manager: Update .ai_context/framework_progress.md recovery completion: state recovered successfully, integrity verified, resuming from [recovery_point]"
```

---

## 📋 **UPDATE TEMPLATES AND EXAMPLES**

### **Standard Update Template**
```json
{
  "timestamp": "2025-08-22T[HH:MM:SS]",
  "updated_by": "ai_assistant_[agent_name]",
  "update_type": "[task_completion|phase_transition|human_approval|error_recovery]",
  "phase": "[current_phase_number]",
  "task": "[current_task_name]",
  "changes": {
    "status_changed": "[old_status] -> [new_status]",
    "deliverables_updated": "[deliverable_list]",
    "next_action": "[immediate_next_step]"
  },
  "validation": {
    "json_valid": true,
    "consistency_check": "passed",
    "integrity_verified": true
  }
}
```

### **Example Updates**

#### **Task Completion Example**
```bash
"general-purpose: Update .ai_context/framework_progress.md task completion: 'Create EARS requirements' status changed to 'completed', deliverables: ['docs/ears/core_requirements.md', 'docs/ears/performance_requirements.md'], next_action: 'Begin BDD scenario development'"
```

#### **Phase Transition Example**
```bash
"project-manager: Update .ai_context/framework_progress.md phase transition: Phase 1 'Requirements Analysis' status changed to 'completed', all deliverables validated, Phase 2 'BDD Development' status changed to 'ready', awaiting human approval"
```

#### **Human Approval Example**
```bash
"project-manager: Update .ai_context/framework_progress.md human approval: Phase 1 approved by human developer at 2025-08-22T14:30:00, progression authorized to Phase 2, approval gate passed"
```

---

## 🎯 **UPDATE SUCCESS CRITERIA**

### **Update Performance Targets**
- **Update Speed**: <5 seconds for state update completion
- **Accuracy**: 100% accurate state reflection
- **Integrity**: 100% JSON syntax and consistency validation
- **Reliability**: >99.9% successful update rate
- **Recovery**: <30 seconds for error recovery and rollback

### **Quality Assurance**
- **Validation**: Every update must pass pre/post validation
- **Backup**: Previous state backed up before every update
- **Audit Trail**: Complete update history maintained
- **Error Handling**: Automatic error detection and recovery
- **Human Visibility**: Critical updates require human notification

---

*Automated State Updates Protocol - Single Source of Truth Maintenance*  
*Version: v3.7 - Complete State Management Automation*  
*Created: 2025-08-22*  
*Purpose: Comprehensive automated state maintenance for AI assistant operations*