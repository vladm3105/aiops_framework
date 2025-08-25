# AI Agent Ecosystem for Framework v3.7

This directory contains the complete collection of specialized AI agents that provide domain expertise and task coordination for the AI Agent Development Framework v3.7 methodology.

## Available Agents

### Core Development Agents
- **coder.md** - Central programming coordinator for TDD-based implementation
- **test-engineer.md** - Test-first development and comprehensive validation strategies
- **code-reviewer.md** - Code quality review and standards compliance
- **refactor-specialist.md** - Code quality improvement and technical debt reduction

### Architecture & Design Agents
- **system-architect.md** - Strategic technical planning and architecture design
- **gcp-architect.md** - Google Cloud Platform and AI services architecture
- **api-architect.md** - API design and specification for backend development
- **db-specialist.md** - Database schema design and query optimization

### DevOps & Cloud Operations
- **devops-expert.md** - DevOps, MLOps, and cloud environment automation
- **ops-engineer.md** - Cloud operations and production troubleshooting
- **perf-optimizer.md** - Performance analysis and optimization

### Security & Quality
- **security-auditor.md** - Security analysis and vulnerability assessment
- **frontend-specialist.md** - UI/UX design and frontend development
- **docs-specialist.md** - Technical documentation and API documentation

### Project Management
- **project-manager.md** - Multi-agent coordination and workflow orchestration

## Usage in Framework Development

Based on the Framework v3.7 methodology, recommended agent combinations for framework implementation:

### System Development
```bash
# Comprehensive system development
"gcp-architect + test-engineer + coder + security-auditor"

# UI/UX development
"frontend-specialist + perf-optimizer + code-reviewer"

# Database development
"db-specialist + test-engineer + perf-optimizer"
```

### Cloud Deployment & Operations
```bash
# Google Cloud Run deployment
"devops-expert + security-auditor + gcp-architect"

# Production monitoring and operations
"ops-engineer + perf-optimizer + system-architect"
```

### Documentation & Quality
```bash
# Architecture documentation
"docs-specialist + system-architect + gcp-architect"

# Code quality and refactoring
"refactor-specialist + code-reviewer + test-engineer"
```

## Configuration

All agents can be configured by editing the frontmatter in their respective markdown files.

## Framework v3.7 Context

These agents are specifically configured for the AI Agent Development Framework v3.7, which includes:

- **AI-First Methodology**: Complete lifecycle automation with human strategic oversight
- **Framework Phases**: Init → Development → Deployment → Operations workflow
- **Performance Targets**: 10x development velocity, >99.9% reliability, >95% quality
- **Compliance**: Framework compliance validation and regulatory adherence

Each agent understands the framework methodology context and will apply appropriate quality and compliance considerations when working on framework components.

## Agent Coordination

The agents follow the multi-agent coordination patterns defined in the framework. Key coordination principles:

- Test-driven development with test-engineer leading requirements
- Security-first approach with security-auditor validation
- Performance optimization integrated throughout development
- Documentation maintained continuously with docs-specialist

## Local Customization

To customize agents for specific project requirements:

1. Edit individual agent `.md` files in this directory
2. Modify the `model` field in frontmatter to use specific models
3. Add project-specific instructions to agent descriptions

Last updated: 2025-08-19
Agent source: Global Claude Code settings (/home/ya/.claude/agents/)
