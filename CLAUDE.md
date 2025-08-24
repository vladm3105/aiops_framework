# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **AI Agent Development Framework v3.7** - a production-ready development methodology that delivers 10x development acceleration through AI-first development, complete specification-driven processes, and integrated quality assurance.

## Architecture & Development Framework

### Framework Structure
The project implements a complete development lifecycle framework with two main phases:

1. **Development Framework** (`development/`): Product requirements → deployment scripts preparation
2. **Deployment Framework** (`deployment/`): Artifact validation → enhancement → deployment
3. **Operations Framework** (`operations/`): Production operations → monitoring → optimization

### Core Components
- **Business Vision**: `product.md.template` + `docs/prd/` (Product Requirements Documents)
- **Requirements**: `requirements.md.template` + `docs/ears/` (EARS format) + `docs/bdd/` (BDD scenarios)
- **Architecture**: `design.md.template` + `docs/adr/` (Architecture Decision Records)
- **Specifications**: `docs/specs/` (SPECS-NNNN format technical specifications)
- **Implementation**: `tasks.md.template` + AI assistant code implementation
- **Deployment**: `deployment.md.template` + infrastructure automation

### AI-First Development Patterns
- **Context Optimization**: Files in `.ai_context/` for development acceleration (target: <5 second context loading)
- **Framework Compliance**: Target full structure compliance with v3.7 specification
- **Quality Gates**: Target >95% quality validation success at each phase
- **BDD Integration**: Validate requirements through behavioral scenarios

## Development Commands

### Framework Initialization
```bash
# Initialize new framework project (MANDATORY PRE-WORK FIRST)
"Read and integrate the complete AI system prompt from development/ai_system_prompt_v3.7.md ensuring full understanding of mandatory pre-work requirements, framework compliance standards, and human interaction protocols. Then begin Phase -1 mandatory pre-work requirements."
```

### Phase-Based Development
The framework follows an 8-phase methodology:
- **Phase -1**: Mandatory pre-work (migration assessment, version control prep, change submission)
- **Phase 0**: Framework initialization & setup
- **Phase 1**: Requirements analysis & specification (EARS + BDD)
- **Phase 2**: Behavioral specification & BDD development
- **Phase 3**: Architecture & ADR development
- **Phase 4**: Technical specifications (SPECS-NNNN format)
- **Phase 5**: Implementation & coding
- **Phase 6**: Testing & quality assurance
- **Phase 7**: AI-first deployment preparation
- **Phase 8**: Production deployment & operations

### Agent-Specialized Commands
The framework uses specialized AI agents for different tasks:
- `api-design-architect`: API design and requirements
- `security-auditor`: Security analysis and compliance
- `test-engineer`: BDD scenarios and testing
- `cloud-devops-expert`: Infrastructure and deployment
- `performance-optimizer`: Performance analysis and optimization
- `database-specialist`: Data architecture and specifications

## Session Management

### Universal Session Protocols
The framework implements hybrid session management:
- **TODOS.md**: Session + cumulative tracking with TodoWrite tool integration
- **framework_tasks.md**: Project-specific phase tracking
- **Session Lifecycle**: Start → Archive → Reset → Priority Setting → Work → End → Commit

### Session Management Rules
1. **ONE TASK RULE**: Only ONE task can be "IN_PROGRESS" at any time
2. **Status Updates**: Use TodoWrite tool for immediate status changes
3. **Phase Alignment**: Ensure session tasks align with current framework phase
4. **Human Checkpoints**: Required human approval at end of each major phase

## Quality Assurance & Compliance

### Mandatory Requirements
- **Pre-Work Compliance**: Complete Phase -1 requirements before any framework work
- **Framework Structure**: Ensure required directories and files per v3.7 specification
- **EARS Requirements**: Formal technical requirements in WHEN–THE–SHALL–WITHIN format
- **BDD Coverage**: Target full requirements validation through Given–When–Then scenarios
- **ADR Documentation**: Document architectural decisions with rationale
- **Validation Reports**: Produce reports in `docs/validation/` for each phase

### Security Integration
- **Security-by-Design**: Integrated throughout development lifecycle
- **Threat Modeling**: Comprehensive security architecture required
- **Compliance**: Built-in compliance and audit capabilities
- **Security Validation**: Behavioral security scenario testing

## Testing Strategy

### BDD-Driven Testing
All testing follows Behavior-Driven Development patterns:
- Core system BDD scenarios in `docs/bdd/core_system_bdd.md`
- Security BDD scenarios in `docs/bdd/security_bdd.md`
- Performance BDD scenarios in `docs/bdd/performance_bdd.md`
- Integration BDD scenarios in `docs/bdd/integration_bdd.md`

### Test Execution
Testing integrated into framework phases:
- Phase 2: BDD scenario development
- Phase 6: Comprehensive testing & quality assurance
- Automated BDD scenario execution with reporting

## Deployment & Operations

### AI-First Deployment
- **Infrastructure-as-Code**: Complete automation in `deployment/` directory
- **Deployment Intelligence**: AI-driven orchestration with 99.9% reliability target
- **Monitoring**: Comprehensive observability with predictive incident prevention
- **Zero-Downtime**: Automated rollback and self-healing capabilities

### Deployment & Operations Integration
The Deployment and Operations frameworks provide:

**Deployment Framework (`deployment/`):**
- Infrastructure automation across multi-cloud environments
- AI-first CI/CD pipelines with comprehensive automation
- Zero-downtime production deployment strategies
- Security-integrated deployment validation

**Operations Framework (`operations/`):**
- AI-autonomous observability and monitoring
- Predictive incident response and resolution
- Performance optimization and cost management
- Government-grade security and compliance operations

## Important Framework Rules

1. **Mandatory Pre-Work**: Always complete Phase -1 requirements before any framework work
2. **Human Interaction**: Required approval at end of each major phase
3. **Framework Compliance**: 100% adherence to v3.7 structure and methodology
4. **Single Focus**: Only one task in progress at any time via TodoWrite tool
5. **Quality Gates**: Comprehensive validation before phase progression
6. **Documentation**: Maintain complete traceability from requirements to implementation

## 🚨 Archive Directories - DO NOT ANALYZE

**CRITICAL**: The following directories contain ARCHIVED LEGACY FILES and must NOT be analyzed or referenced:

- `.archive_devops_legacy_files/` - Legacy DevOps files (deprecated)
- `devops_archive_not_used/` - Old archive directory (if exists)
- Any directory matching `*_archive_not_used/` or `.archive_*/`

**Why these are archived:**
- All valuable content has been migrated to active framework structure
- Files are outdated and may contain incorrect information
- Framework compliance requires using active files only

**Use these active directories instead:**
- `init/` - Project initialization framework
- `development/` - Development framework  
- `deployment/` - Deployment framework
- `operations/` - Operations framework

## Getting Started

For new projects or framework implementation:
1. Read the framework startup guide: `AI_ASSISTANT_STARTUP.md`
2. Follow the quick start process: `QUICK_START.md`
3. Ensure all mandatory pre-work requirements are completed
4. Proceed through the 8-phase development lifecycle
5. Maintain framework compliance throughout development

## Success Metrics

Target framework effectiveness:
- **Development Velocity**: 2-3x improvement through AI optimization
- **Quality Assurance**: >95% defect reduction through systematic validation
- **Security Integration**: >95% security-by-design implementation
- **Deployment Success**: >95% automated deployment success rate
- **Framework Compliance**: 100% structure compliance achieved
