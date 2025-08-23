# Framework v3.7 Session Management Protocols

## Universal Cross-Project Session Management System

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
- **Complete Lifecycle Support**: Init → Development → Deployment → Operations workflow

### **Core Session Management Components**

1. **TodoWrite Tool**: Real-time session task management across all frameworks
2. **.ai_context/framework_progress.md**: Master state file (single source of truth)
3. **TODOS.md**: Session-specific tracking (optional project-level)
4. **framework_tasks.md**: Project-specific phase tracking (optional)
5. **Git Integration**: Immutable session evidence and audit trail
6. **Framework-Specific Guides**: AI startup guides for each framework phase

---

## 🎯 **Framework v3.7 Complete Lifecycle Integration**

### **Init → Development → Deployment → Operations Workflow**

Framework v3.7 now provides complete lifecycle coverage with specialized session management for each phase:

```
🎯 Init Framework      → 🔨 Development Framework → 🚀 Deployment Framework → ⚙️ Operations Framework
   (Phase -1 & 0)           (Phases 1-6)              (Phase 7)                (Phase 8)
      ↓                        ↓                         ↓                        ↓
  Project Safety        Requirements → Code       Production Deploy       AI-Autonomous Ops
```

### **Session Management Across Framework Phases**

Each framework phase has its own specialized startup guide and context, but **universal session management protocols apply across all phases**:

- **Init Framework**: Session management for pre-work and project initialization
- **Development Framework**: Session management for requirements through testing
- **Deployment Framework**: Session management for production deployment  
- **Operations Framework**: Session management for post-deployment operations

### **Master State Management**

The `.ai_context/framework_progress.md` serves as the **single source of truth** for:
- Current framework phase and status
- Completed phases and achievements  
- Next phase readiness and prerequisites
- Framework compliance validation
- Human approval tracking

Session management **complements** this by providing:
- Real-time task management within each phase
- Session-specific progress tracking
- TodoWrite tool integration
- Cross-session continuity

---

## 📋 **Universal Session Protocols**

### **🚀 Session Start Protocol (Every Session)**

#### **Step 1: Context Loading**
```markdown
AI Assistant Actions:
1. Load .ai_context/framework_progress.md as authoritative state source
2. Determine current framework phase (Init/Development/Deployment/Operations)
3. Load appropriate framework-specific context and startup guide
4. Review session history and previous achievements
5. Understand current phase priorities and next actions
6. Load project-specific context and goals
```

#### **Step 2: Session Archiving**
```markdown
AI Assistant Actions:
1. Move all completed tasks from "CURRENT SESSION TODOS" to "SESSION ARCHIVE"
2. Create new session archive section: "Session N Archive (YYYY-MM-DD HH:MM AM/PM) - COMPLETED ✅"
3. Add session summary with achievements, duration, deliverables
4. Update session timeline in SESSION HISTORY with precise datetime format
5. Archive any IN_PROGRESS tasks with handoff notes
```

#### **Step 3: Current Session Reset**
```markdown
AI Assistant Actions:
1. Clear "CURRENT SESSION TODOS" section completely
2. Increment session number in header
3. Update date and timestamp using format: "Session N - YYYY-MM-DD HH:MM EST"
4. Reset "Active Tasks (In Progress)" to empty
5. Reset "Pending Tasks (Next Up)" to empty
6. Define new "Session Goals" based on framework priorities
```

#### **Step 4: Priority Setting**
```markdown
AI Assistant Actions:
1. Review framework_tasks.md for current phase priorities
2. Identify next critical tasks from Framework v3.7 methodology
3. Set session-specific goals aligned with project objectives
4. Populate "Pending Tasks (Next Up)" with immediate priorities
5. Ensure alignment with human checkpoints and approval requirements
```

### **⚡ During Session Protocol (Continuous)**

#### **Single Focus Discipline**
```markdown
AI Assistant Rules:
1. **ONE TASK RULE**: Only ONE task can be "IN_PROGRESS" at any time
2. **Status Updates**: Use TodoWrite tool for immediate status changes
3. **Focus Maintenance**: Complete current task before starting next
4. **Quality Gates**: Validate deliverables before marking completed
5. **Documentation**: Maintain session notes and progress tracking
```

#### **Real-Time Task Management**
```markdown
AI Assistant Workflow:
1. **Task Selection**: Choose next task from "Pending Tasks (Next Up)"
2. **Status Change**: Update task to "IN_PROGRESS" via TodoWrite
3. **Work Execution**: Perform task with quality focus
4. **Completion Validation**: Ensure deliverables meet requirements
5. **Status Update**: Mark completed and select next task
```

#### **Cross-Reference Validation**
```markdown
AI Assistant Checks:
1. **Framework Alignment**: Ensure session tasks align with current framework phase
2. **State Management**: Update .ai_context/framework_progress.md with progress
3. **Quality Standards**: Validate Framework v3.7 compliance
4. **Human Checkpoints**: Prepare for required human approvals
5. **Framework Transition**: Prepare for handoffs between framework phases
```

### **🏁 Session End Protocol (Every Session)**

#### **Step 1: Task Completion**
```markdown
AI Assistant Actions:
1. Complete all IN_PROGRESS tasks or document handoff
2. Update all pending tasks with current status
3. Ensure no abandoned or incomplete work
4. Document any blocked tasks with resolution notes
5. Prepare clear handoff for next session
```

#### **Step 2: Session Archiving**
```markdown
AI Assistant Actions:
1. Move all completed session work to SESSION ARCHIVE
2. Create comprehensive session summary with:
   - Duration and timeline
   - Major deliverables and achievements
   - Files created or modified
   - Git commits with descriptions
   - Framework progress made
   - Next session priorities
```

#### **Step 3: Metrics Update**
```markdown
AI Assistant Actions:
1. Update "Overall Progress Summary" with session achievements
2. Refresh "Framework Compliance Status" with current metrics
3. Update project-specific status indicators
4. Calculate development velocity metrics
5. Update cumulative achievement counters
```

#### **Step 4: Next Session Preparation**
```markdown
AI Assistant Actions:
1. Update .ai_context/framework_progress.md with session achievements
2. Identify next session priorities based on current framework phase
3. Prepare goals for subsequent session or framework transition
4. Document any human interaction requirements
5. Set up context for seamless session or framework transition
6. Update AI context files for continuity
```

#### **Step 5: Git Commitment**
```markdown
AI Assistant Actions:
1. Add all session changes to git
2. Create comprehensive commit message with session summary
3. Include session number, achievements, and deliverables
4. Maintain immutable audit trail of session work
5. Ensure clean working directory for next session
```

---

## 📊 **Universal TODOS.md Template**

### **Required Structure for All Framework v3.7 Projects**

```markdown
# [Project Name] - Project TODOs

## AI Assistant Hybrid Session Management System

**Version:** 3.7 - Hybrid Session Management Edition  
**Date:** [Current Date]  
**Session:** [Current Session Number]  
**Purpose:** Project-specific TODO tracking with session lifecycle management  
**Framework Integration:** Designed for Framework v3.7 compliance and cross-session continuity

---

## 🎯 **CURRENT SESSION TODOS** (Session N - Date)

### **Active Tasks (In Progress)**
[Only ONE task allowed - enforced by TodoWrite tool]

### **Pending Tasks (Next Up)**  
[Next immediate priorities aligned with framework_tasks.md]

### **Session Goals**
[Specific objectives for current session]

---

## 📋 **PHASE TRACKING** (Cumulative Progress)

### **✅ COMPLETED PHASES**
[Historical record of completed framework phases with session references]

### **🚀 CURRENT PHASE**
[Current framework phase with detailed task breakdown]

### **⏳ NEXT MAJOR PHASE**
[Upcoming framework phase with readiness indicators]

---

## 📊 **PROGRESS TRACKING** (Cumulative Metrics)

### **Overall Progress Summary**
[Session count, phase completion, overall project percentage]

### **Framework Compliance Status**
[Structure compliance, quality gates, validation criteria]

### **[Project-Specific] Status**
[Domain-specific metrics and indicators]

---

## 🔄 **SESSION HISTORY** (Cumulative Record)

### **Session Timeline**
[Chronological list of all sessions with precise datetime format: "Session N (YYYY-MM-DD HH:MM AM/PM): Focus area"]

### **Key Achievements by Session**
[Detailed session-by-session achievement tracking]

### **Development Velocity Metrics**
[Velocity improvement tracking across sessions]

---

## 📜 **SESSION ARCHIVE** (Historical Tasks)

### **Session N Archive (YYYY-MM-DD HH:MM AM/PM) - COMPLETED ✅**
[Complete record of each session's tasks and achievements with precise timestamps]

---

## 🎯 **SESSION MANAGEMENT PROTOCOLS**

### **Session Lifecycle Rules**
[Standard protocols as defined in this document]

### **TODO Status Definitions**
[PENDING, IN_PROGRESS, COMPLETED, BLOCKED, ON_HOLD, ARCHIVED]

### **Priority Levels**
[CRITICAL, HIGH, MEDIUM, LOW with project-specific criteria]

---

## 🚨 **CRITICAL TRACKING NOTES**

### **Framework Requirements**
[Hybrid session management, TodoWrite integration, triple tracking system]

### **AI Assistant Guidelines**
[Status update discipline, single focus rule, session protocols]

### **Cross-Session Continuity**
[Context loading, progress awareness, framework alignment]

---

## 📁 **INTEGRATION WITH FRAMEWORK FILES**

### **File Hierarchy**
[Session, project, and framework level file relationships]

### **Cross-Reference Integration**
[Bidirectional updates and tool integration]

### **Session Management Benefits**
[Clean focus, historical record, continuity, compliance]
```

---

## 🔧 **TodoWrite Tool Integration Standards**

### **Required TodoWrite Behaviors for Framework v3.7**

#### **Status Management**
```markdown
TodoWrite Tool Requirements:
1. **Single Focus Enforcement**: Prevent multiple IN_PROGRESS tasks
2. **Real-Time Updates**: Immediate status reflection in TODOS.md
3. **Cross-Reference Validation**: Check alignment with framework_tasks.md
4. **Session Boundary Support**: Handle session start/end protocols
5. **Status Validation**: Ensure proper status transitions
```

#### **Integration with TODOS.md**
```markdown
TodoWrite Tool Integration:
1. **Auto-Update**: Changes immediately reflected in CURRENT SESSION TODOS
2. **Status Sync**: Bidirectional synchronization with file content
3. **Session Context**: Tool understands current session number and phase
4. **Priority Tracking**: Maintains priority levels and categories
5. **Archive Support**: Assists with session archiving workflow
```

#### **Framework Compliance Support**
```markdown
TodoWrite Tool Framework Support:
1. **Phase Alignment**: Validates tasks align with current framework phase
2. **Quality Gates**: Enforces quality validation before completion
3. **Human Checkpoints**: Identifies required human approval points
4. **Progress Metrics**: Contributes to cumulative progress tracking
5. **Audit Trail**: Maintains complete task lifecycle documentation
```

---

## 🎯 **Project Initialization Checklist**

### **Framework v3.7 Project Setup Requirements**

#### **Required Files (Mandatory)**
- [ ] **.ai_context/framework_progress.md**: Master state file (single source of truth)
- [ ] **init/**: Complete init framework methodology directory
- [ ] **development/**: Complete development framework methodology directory  
- [ ] **deployment/**: Complete deployment framework methodology directory
- [ ] **operations/**: Complete operations framework methodology directory
- [ ] **TODOS.md**: Optional project-level session tracking
- [ ] **framework_tasks.md**: Optional project-specific phase tracking
- [ ] **tasks.md**: Optional technical implementation roadmap

#### **Session Management Setup**
- [ ] **Master State Integration**: .ai_context/framework_progress.md configured as single source of truth
- [ ] **TodoWrite Integration**: Tool configured for real-time task management across all framework phases
- [ ] **Framework Phase Awareness**: Session management understands current framework phase
- [ ] **Git Integration**: Session archiving and commit protocols established
- [ ] **Cross-Reference**: Integration between state management and session tracking

#### **Quality Assurance Setup**
- [ ] **Framework Compliance**: Structure validation against Framework v3.7 requirements
- [ ] **Quality Gates**: Phase gate requirements defined and trackable
- [ ] **Human Checkpoints**: Approval workflow integrated into session management
- [ ] **Audit Trail**: Complete documentation and evidence tracking established

---

## 🚀 **Benefits of Universal Session Management**

### **For AI Assistants**
- **Consistent Experience**: Same session management across all Framework v3.7 projects
- **Context Continuity**: Complete understanding of project history and current state
- **Quality Assurance**: Standardized validation and compliance tracking built-in
- **Focus Discipline**: Single-task focus maintained across all development work
- **Framework Alignment**: Automatic alignment with Framework v3.7 methodology

### **For Human Developers**
- **Project Visibility**: Clear, real-time understanding of AI assistant progress
- **Session Transparency**: Complete view of what was accomplished in each session
- **Historical Tracking**: Full archive of all development sessions across projects
- **Framework Compliance**: Guaranteed adherence to Framework v3.7 across portfolio
- **Quality Control**: Built-in quality gates and validation checkpoints

### **For Project Management**
- **Portfolio Metrics**: Standardized progress tracking across all Framework v3.7 projects
- **Resource Planning**: Understanding of AI assistant utilization and development velocity
- **Quality Validation**: Consistent framework compliance and deliverable quality
- **Audit Trails**: Complete documentation for compliance, review, and improvement
- **Cross-Project Learning**: Standardized metrics enable cross-project optimization

---

## 📝 **Implementation Guidelines**

### **New Project Implementation**
1. **Copy Universal Template**: Use TODOS.md template with project-specific adaptations
2. **Configure TodoWrite**: Set up tool integration for session management
3. **Initialize Session**: Start with Session 1 following session start protocol
4. **Establish Metrics**: Define project-specific progress indicators
5. **Validate Integration**: Ensure all components work together correctly

### **Existing Project Migration**
1. **Assess Current State**: Analyze existing task tracking and session management
2. **Archive Current Work**: Preserve existing progress and achievements
3. **Implement Hybrid Model**: Transition to universal session management structure
4. **Update Framework Files**: Integrate session management into framework files
5. **Validate Migration**: Ensure seamless transition with no lost context

### **Quality Assurance**
1. **Structure Validation**: Verify TODOS.md follows universal template exactly
2. **Integration Testing**: Confirm TodoWrite tool works with session protocols
3. **Cross-Reference Check**: Validate bidirectional updates between tracking files
4. **Framework Compliance**: Ensure 100% adherence to Framework v3.7 methodology
5. **Human Approval**: Obtain approval for session management implementation

---

*Framework v3.7 Session Management Protocols*  
*Created: 2025-08-17*  
*Purpose: Universal session management for all Framework v3.7 projects*  
*Scope: Cross-project compatibility and AI assistant workflow optimization*