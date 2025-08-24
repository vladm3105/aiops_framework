# Framework Navigation Guide

**Find exactly what you need in seconds** 🎯

---

## 🚀 **Start Here**

| I want to... | Go to | Time |
|--------------|-------|------|
| **Get started immediately** | [GET_STARTED.md](GET_STARTED.md) | 5 min |
| **Start a new project** | [New Project Setup](GET_STARTED.md#new-project-5-minute-setup) | 5 min |
| **Add framework to existing code** | [Existing Project](GET_STARTED.md#existing-project-integration) | 10 min |
| **Deploy to production** | [Deployment Guide](GET_STARTED.md#deployment-only) | 15 min |
| **Set up monitoring** | [Operations Setup](GET_STARTED.md#operations-setup) | 20 min |

---

## 📚 **Core Framework Files**

### **Essential Reading**
- [`README.md`](README.md) - Framework overview and architecture
- [`CLAUDE.md`](CLAUDE.md) - AI assistant rules and project instructions  
- [`GET_STARTED.md`](GET_STARTED.md) - Quick start for all scenarios

### **Project Templates**
- [`product.md.template`](product.md.template) - Business vision and strategic objectives template
- [`requirements.md.template`](requirements.md.template) - Master requirements (EARS format) template
- [`design.md.template`](design.md.template) - System architecture and technical design template
- [`tasks.md.template`](tasks.md.template) - Implementation roadmap and task management template
- [`deployment.md.template`](deployment.md.template) - Deployment strategy and procedures template

---

## 🤖 **AI Agent Quick Reference**

### **Development Agents**
- `general-purpose` - Research, analysis, multi-step tasks
- `coder-agent` - Code implementation, bug fixes, TDD
- `test-engineer` - BDD scenarios, test creation, validation
- `security-auditor` - Security analysis, vulnerability assessment

### **Architecture Agents**
- `gcp-ai-architect` - Cloud architecture, system design
- `api-design-architect` - API design, data models
- `system-architect` - Platform comparisons, technical strategy

### **Quality Agents**
- `code-reviewer` - Code quality, standards compliance
- `performance-optimizer` - Performance analysis, optimization  
- `refactoring-specialist` - Code improvement, technical debt

### **Operations Agents**
- `cloud-devops-expert` - CI/CD, deployment automation
- `cloud-ops-engineer` - Infrastructure, production operations
- `database-specialist` - Database design, optimization

### **Coordination Agents**
- `project-manager` - Multi-agent workflows, coordination
- `documentation-specialist` - Documentation creation, updates

---

## 📁 **Framework Phases**

### **Phase 0: Init Framework** 🎯
**Purpose**: Safe project setup and framework initialization
- [`init/`](init/) - Complete initialization methodology
- [`QUICK_START.md`](QUICK_START.md) - Detailed setup guide
- **Time**: 30-60 minutes
- **Output**: Framework-compliant project structure

### **Phase 1-6: Development Framework** 🔨
**Purpose**: Requirements through testing with AI acceleration
- [`development/`](development/) - Complete development methodology
- **Phases**: Requirements → Architecture → Implementation → Testing
- **Time**: 2-8 hours depending on project complexity
- **Output**: Production-ready application code

### **Phase 7: Deployment Framework** 🚀  
**Purpose**: Infrastructure through production deployment
- [`deployment/`](deployment/) - Complete deployment methodology
- **Focus**: Zero-downtime deployments, Infrastructure-as-Code
- **Time**: 1-3 hours depending on infrastructure complexity
- **Output**: Production system with monitoring

### **Phase 8: Operations Framework** ⚙️
**Purpose**: AI-autonomous operations and optimization
- [`operations/`](operations/) - Complete operations methodology  
- **Focus**: Predictive monitoring, self-healing, optimization
- **Time**: Ongoing autonomous operations
- **Output**: Self-optimizing production system

---

## 📖 **Documentation Structure**

### **Documentation Hierarchy**
- [`docs/`](docs/) - Master documentation directory
  - [`docs/adr/`](docs/adr/) - Architecture Decision Records
  - [`docs/ears/`](docs/ears/) - EARS format requirements
  - [`docs/bdd/`](docs/bdd/) - Behavior-Driven Development scenarios
  - [`docs/prd/`](docs/prd/) - Product Requirements Documents
  - [`docs/specs/`](docs/specs/) - Technical specifications
  - [`docs/validation/`](docs/validation/) - Quality validation reports

### **Session Management**
- [`SESSION_MANAGEMENT.md`](SESSION_MANAGEMENT.md) - Universal session protocols
- [`TodoWrite Integration`] - Real-time task management throughout framework

### **Reference Materials**
- [`_shared/terminology.md`](_shared/terminology.md) - Standardized framework terms
- [`.github/workflows/`](.github/workflows/) - CI/CD automation workflows

---

## 🎯 **Quick Commands by Use Case**

### **Start Development Work**
```bash
"test-engineer: Create BDD scenarios for [feature] following Framework v3.7"
"coder-agent: Implement [feature] using TDD based on BDD scenarios"  
"security-auditor: Review implementation for security compliance"
```

### **Production Issue Response**
```bash
"general-purpose: Analyze production issue [description] and identify root cause"
"coder-agent: Implement fix with comprehensive testing"
"cloud-devops-expert: Deploy fix using zero-downtime deployment"
```

### **Infrastructure Changes**
```bash
"gcp-ai-architect: Design infrastructure for [requirements]"
"cloud-devops-expert: Implement Infrastructure-as-Code following design"
"security-auditor: Validate infrastructure security configuration"
```

### **Performance Optimization**
```bash
"performance-optimizer: Analyze current performance bottlenecks"
"performance-optimizer: Recommend specific optimizations with implementation plan"
"coder-agent: Implement performance improvements with validation"
```

### **Security Enhancement**
```bash
"security-auditor: Perform comprehensive security audit of [component]"
"security-auditor: Implement security controls based on threat model"
"test-engineer: Create security-focused BDD scenarios and tests"
```

---

## 🔍 **Find Information Fast**

### **By Topic**
| Topic | Primary Location | Secondary Resources |
|-------|------------------|-------------------|
| **Getting Started** | [GET_STARTED.md](GET_STARTED.md) | [README.md](README.md) |
| **AI Agents** | [Agents Directory](agents/) | [Agent Quick Reference](GET_STARTED.md#-ai-agent-quick-reference) |
| **Development** | [development/](development/) | [BDD Integration](development/bdd_integration_guide_v3.7.md) |
| **Deployment** | [deployment/](deployment/) | [CI/CD Pipeline](deployment/ci_cd_pipeline_v3.7.md) |
| **Operations** | [operations/](operations/) | [Monitoring](operations/monitoring_observability_v3.7.md) |
| **Security** | [Security Integration](development/ai_assistant_guide_v3.7.md) | [Threat Modeling](docs/adr/) |
| **Quality** | [Testing Guide](development/bdd_integration_guide_v3.7.md) | [Validation](docs/validation/) |

### **By Role**
| Role | Start Here | Key Resources |
|------|------------|---------------|
| **Developer** | [Development Framework](development/) | [AI Assistant Guide](development/ai_assistant_guide_v3.7.md) |
| **DevOps Engineer** | [Deployment Framework](deployment/) | [Infrastructure Automation](deployment/infrastructure_automation_v3.7.md) |
| **SRE/Operations** | [Operations Framework](operations/) | [Monitoring Guide](operations/monitoring_observability_v3.7.md) |
| **Architect** | [System Architecture](design.md.template) | [ADR Guide](development/adr_guide_v3.7.md) |
| **Project Manager** | [Framework Overview](README.md) | [Session Management](SESSION_MANAGEMENT.md) |
| **Security Engineer** | [Security Integration](docs/bdd/security_bdd.md) | [Security Auditor Agent](agents/) |

---

## 💡 **Tips for Maximum Effectiveness**

### **First Time Users**
1. **Start with GET_STARTED.md** - Don't skip the 5-minute overview
2. **Complete Phase -1 Pre-work** - Critical for project safety  
3. **Choose your path** - New project vs existing project integration
4. **Follow the phases** - Don't jump ahead without completing prerequisites

### **Experienced Users**
1. **Use specific agents** - Direct agent commands are faster than general requests
2. **Reference terminology** - Consistent terms improve AI understanding
3. **Leverage templates** - All docs/ subdirectories have templates
4. **Update session state** - Use TodoWrite for better continuity

### **Team Leaders**
1. **Review success metrics** - Track 10x development velocity targets
2. **Monitor quality gates** - Ensure >95% framework compliance  
3. **Validate security** - Security-by-design throughout all phases
4. **Measure effectiveness** - Compare before/after framework adoption

---

## 🆘 **Troubleshooting Quick Links**

### **Common Issues**
- **Framework structure missing**: Run Phase 0 initialization

- **Quality gate failures**: Review [framework compliance](docs/validation/)
- **Deployment issues**: Check [deployment guide](deployment/)
- **Performance problems**: Use [performance optimizer](agents/)

### **Emergency Procedures**
- **Production incident**: [Operations Framework](operations/) → Incident Response
- **Security breach**: [Security Auditor](agents/) → Security Incident Response
- **Framework rollback**: [Session Management](SESSION_MANAGEMENT.md) → Emergency Procedures

---

**Need something not listed here?** Use the `general-purpose` agent: 
```bash
"general-purpose: Help me find information about [topic] in Framework v3.7"
```

*Framework Navigation Guide - AI Agent Development Framework v3.7*  
*Created: 2025-08-23*  
*Purpose: Fast access to all framework resources*