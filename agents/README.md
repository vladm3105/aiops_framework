# Claude Code Agents for RisenOne Fire Risk Analysis System

This directory contains local copies of all Claude Code specialized agents, extracted from global settings and customized for the RisenOne Fire Risk Analysis Agent System development.

## Available Agents

### Core Development Agents
- **coder-agent.md** - Central programming coordinator for TDD-based implementation
- **test-engineer.md** - Test-first development and comprehensive validation strategies
- **code-reviewer.md** - Code quality review and standards compliance
- **refactoring-specialist.md** - Code quality improvement and technical debt reduction

### Architecture & Design Agents
- **system-architect.md** - Strategic technical planning and architecture design
- **gcp-ai-architect.md** - Google Cloud Platform and AI services architecture
- **api-design-architect.md** - API design and specification for backend development
- **database-specialist.md** - Database schema design and query optimization

### DevOps & Cloud Operations
- **cloud-devops-expert.md** - DevOps, MLOps, and cloud environment automation
- **cloud-ops-engineer.md** - Cloud operations and production troubleshooting
- **performance-optimizer.md** - Performance analysis and optimization

### Security & Quality
- **security-auditor.md** - Security analysis and vulnerability assessment
- **frontend-specialist.md** - UI/UX design and frontend development
- **documentation-specialist.md** - Technical documentation and API documentation

### Project Management
- **project-manager.md** - Multi-agent coordination and workflow orchestration

## Usage in RisenOne Development

Based on the CLAUDE.md guidelines, recommended agent combinations for RisenOne development:

### Fire Risk Analysis Workflows
```bash
# Comprehensive fire risk system development
"gcp-ai-architect + test-engineer + coder-agent + security-auditor"

# Fire danger visualization optimization  
"frontend-specialist + performance-optimizer + code-reviewer"

# NFDRS calculation validation
"database-specialist + test-engineer + performance-optimizer"
```

### Cloud Deployment & Operations
```bash
# Google Cloud Run deployment
"cloud-devops-expert + security-auditor + gcp-ai-architect"

# Production monitoring and operations
"cloud-ops-engineer + performance-optimizer + system-architect"
```

### Documentation & Quality
```bash
# Architecture documentation
"documentation-specialist + system-architect + gcp-ai-architect"

# Code quality and refactoring
"refactoring-specialist + code-reviewer + test-engineer"
```

## Configuration

All agents use the following configuration:
- Default model: `sonnet` (configurable per agent via frontmatter)
- Local settings: `.claude/settings.json`
- Project-specific instructions: `CLAUDE.md` (root level)

## Fire Risk Analysis Context

These agents are specifically configured for the RisenOne Fire Risk Analysis Agent System, which includes:

- **Mission Critical Application**: Fire danger assessment for wildfire management
- **Technology Stack**: Google ADK Framework, AlloyDB, BigQuery, ASCII visualization
- **Performance Targets**: Sub-second response times for critical fire assessments
- **Compliance**: Fire safety validation and NFDRS accuracy requirements

Each agent understands the fire risk domain context and will apply appropriate safety and performance considerations when working on RisenOne components.

## Agent Coordination

The agents follow the multi-agent coordination patterns defined in:
- `docs/specs/SPECS-0016-multi-agent-orchestrator.md` 
- `docs/architecture/ARCHITECTURE_INTEGRATION.md`

Key coordination principles:
- Test-driven development with test-engineer leading requirements
- Security-first approach with security-auditor validation
- Performance optimization integrated throughout development
- Documentation maintained continuously with documentation-specialist

## Local Customization

To customize agents for specific RisenOne requirements:

1. Edit individual agent `.md` files in this directory
2. Modify the `model` field in frontmatter to use specific models
3. Add RisenOne-specific instructions to agent descriptions
4. Update `.claude/settings.json` for project-wide configuration

Last updated: 2025-08-19
Agent source: Global Claude Code settings (/home/ya/.claude/agents/)