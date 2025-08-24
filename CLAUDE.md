# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **AI Agent Development Framework v3.7**, a comprehensive documentation-first methodology for AI-assisted software development. The framework follows an **AI-first approach** where AI agents handle 90-95% of execution tasks across four lifecycle phases: Init → Development → Deployment → Operations.

## Framework Architecture

### Four-Phase Lifecycle Structure

- **Phase -1 to 0**: `init/` - Project initialization and framework setup
- **Phase 1-6**: `development/` - EARS requirements, BDD scenarios, ADR decisions, implementation
- **Phase 7**: `deployment/` - Infrastructure automation, CI/CD, zero-downtime strategies
- **Phase 8**: `operations/` - AI-autonomous monitoring, incident response, optimization

### AI Context System

The `.ai_context/` directory provides intelligent state management:

- **`framework_progress.md`** - Master state file (single source of truth)
- **`current_context.md`** - Active working context
- **`team_patterns.md`** - Development patterns and standards
- **`domain_context.md`** - Project-specific knowledge

Always consult these files first to understand current project state and avoid duplicating work.

### Specialized Agent Ecosystem

The `agents/` directory contains 18+ specialized AI agents. Key agents include:

- **Core Development**: `coder.md`, `test-engineer.md`, `code-reviewer.md`, `refactor-specialist.md`
- **Architecture**: `system-architect.md`, `gcp-architect.md`, `api-architect.md`, `db-specialist.md`
- **DevOps**: `devops-expert.md`, `ops-engineer.md`, `perf-optimizer.md`
- **Quality**: `security-auditor.md`, `frontend-specialist.md`, `docs-specialist.md`

Use specialized agents for domain-specific tasks rather than handling everything yourself.

## Implementation Templates

The framework provides ready-to-use templates in the `templates/` directory:

### Available Template Categories

- **`templates/init/`** - Project initialization and setup templates
- **`templates/workflows/`** - CI/CD pipeline templates (GitHub Actions, GitLab, Azure)
- **`templates/infrastructure/`** - Infrastructure-as-Code templates (Terraform, Kubernetes, Docker)
- **`templates/ai-agents/`** - Executable AI agent scripts
- **`templates/development/`** - Development phase templates (EARS, BDD, ADR)
- **`templates/configurations/`** - Platform-specific configurations
- **`templates/integrations/`** - IDE and tool integrations

### Quick Template Usage

```bash
# Initialize new project with framework structure
templates/init/setup-script.sh my-project gcp

# Copy GitHub Actions workflows
cp templates/workflows/github-actions/*.yml .github/workflows/

# Deploy infrastructure using Terraform template
cp templates/infrastructure/terraform/gcp/* infrastructure/terraform/
terraform init && terraform plan

# Use AI agents for code analysis
python templates/ai-agents/code-quality-agent.py --analyze-all
python templates/ai-agents/deployment-strategy-agent.py --analyze-changes "src/main.py,Dockerfile"
```

## Common Framework Commands

### Documentation Validation

```bash
# Find and validate internal links
rg -n "\[.*\]\(.*\)" | head -20

# Check framework consistency
rg -n "v3.7" --type md | wc -l

# Validate framework structure
find . -maxdepth 2 -name "*.md" | sort
```

### Template Discovery

```bash
# List all available templates
find templates/ -name "*.template" -o -name "*.py" -o -name "*.yml" -o -name "*.tf"

# Find specific template types
find templates/ -name "*agent*.py"
find templates/ -name "*terraform*"
find templates/ -name "*workflow*"
```

### Content Search and Navigation

```bash
# Search for specific framework concepts
rg -n "EARS|BDD|ADR|SPECS" --type md

# Find templates and examples
find . -name "*.template" -o -name "*example*"

# Locate validation reports
ls docs/validation/
```

### Framework Compliance Checks

```bash
# Verify phase documentation exists
ls init/*framework*.md development/*framework*.md deployment/*framework*.md operations/*framework*.md

# Check AI context files are current
ls .ai_context/*.md
```

## File Organization Patterns

### Framework Files

- Pattern: `{phase}_framework_v3.7.md`
- Core files: `init_framework_v3.7.md`, `development_framework_v3.7.md`, `deployment_framework_v3.7.md`, `operations_framework_v3.7.md`

### Documentation Structure

- **`docs/adr/`** - Architecture Decision Records (ADR-NNNN format)
- **`docs/ears/`** - EARS format requirements
- **`docs/bdd/`** - Behavior-Driven Development scenarios
- **`docs/specs/`** - Technical specifications (SPECS-NNNN format)
- **`docs/validation/`** - Phase completion reports

### Template System

- Pattern: `{document_type}.md.template`
- Templates provide structured starting points for framework documents

## Framework Workflow Integration

### State Management Protocol

1. **Always check** `.ai_context/framework_progress.md` first
2. **Update state** after completing any framework phase or major task
3. **Maintain context** in `.ai_context/current_context.md` for session continuity

### Phase Transition Requirements

- Each phase requires completion validation before proceeding
- Human approval needed for strategic decisions (architecture, business impact)
- Documentation must be updated in `docs/validation/` for each phase completion

### Quality Gates

- **Pre-work validation**: 100% compliance before development phase
- **Framework compliance**: Structure and implementation adherence required
- **Testing targets**: 95% unit, 85% integration, 75% end-to-end coverage

## Document Standards and Conventions

### Naming Conventions

- Framework files: `{component}_{purpose}_v3.7.md`
- Documentation: Consistent with AGENTS.md guidelines (lowercase_with_underscores.md)
- Keep lines ≤ 100 characters; wrap thoughtfully around links

### Cross-Reference Management

- Use relative paths for internal links
- Maintain traceability: EARS → BDD → ADR → SPECS → Implementation
- Update related READMEs when adding new sections

## Key Performance Targets

### Framework Goals

- **10x Development Velocity** through AI acceleration
- **99.9% Deployment Reliability** with zero-downtime strategies
- **<5 Second Context Loading** for AI optimization
- **Sub-2-minute MTTR** for AI-powered incident response

### Quality Standards

- **Security-by-Design** integrated throughout lifecycle
- **Complete Documentation** with ADRs, PRDs, specifications maintained
- **95%+ Framework Compliance** for structure and implementation
- **Human Strategic Oversight** with AI operational autonomy

## Working with This Framework

### Getting Started

1. Read `README.md` for framework overview
2. Check `.ai_context/framework_progress.md` for current state
3. Review appropriate phase documentation (`init/`, `development/`, `deployment/`, `operations/`)
4. Use specialized agents from `agents/` directory for domain tasks

### Best Practices

- Consult AI context files before starting work
- Use appropriate specialized agents rather than general implementation
- Maintain documentation traceability across phases
- Update framework progress after significant milestones
- Follow established naming conventions and file organization

## AI Interaction Guidelines

### Professional Communication

- Maintain a professional and concise communication style
- Avoid excessive use of emojis in documentation and code comments
- Focus on clarity and precision in technical communication

## Memory Management

- Always keep CLAUDE.md in gitignore file

This framework is designed for systematic, AI-first software development with comprehensive lifecycle coverage while maintaining human strategic oversight.