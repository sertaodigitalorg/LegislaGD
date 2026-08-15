# 🎯 LegislaGD Agents - Summary & Usage Guide

## ✅ Agents Created

### 📐 Functional Agents (6)

```
┌─────────────────────────────────────────────────────────┐
│ Architecture Specialist                                 │
│ └─ Design components, ADRs, integration contracts       │
│ └─ When: Architectural decisions, component design      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Development Agent                                       │
│ └─ Code implementation, refactoring, testing            │
│ └─ When: Building features, writing code                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Engineering & Operations Agent                          │
│ └─ Deployment, CI/CD, infrastructure, backup            │
│ └─ When: DevOps, deployment, monitoring                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Quality & Security Agent                                │
│ └─ Testing, security review, quality gates              │
│ └─ When: Testing strategy, vulnerabilities, standards   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Observability & Debugging Agent                         │
│ └─ Logging, metrics, troubleshooting, performance       │
│ └─ When: Debugging issues, monitoring, performance      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Sustenance & Support Agent                              │
│ └─ Patches, upgrades, bug fixes, maintenance            │
│ └─ When: Releases, support, documentation               │
└─────────────────────────────────────────────────────────┘
```

### 🏛️ Component Agents (4)

```
┌──────────────────────────────────────────────────────────┐
│ SAPL-SD Specialist                                       │
│ Upstream: github.com/interlegis/sapl                     │
│ Tech: Python/Django, PostgreSQL                          │
│ Focus: Bills, votes, sessions, legislative process       │
│ When: Working on legislative features                    │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ e-Cidade-SD Specialist                                   │
│ Upstream: github.com/DBSeller/e-cidade                   │
│ Tech: Java/Spring, PostgreSQL                            │
│ Focus: Admin, budget, payroll, organizational            │
│ When: Working on administrative/financial features       │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ Portal-Modelo-SD Specialist                              │
│ Upstream: github.com/interlegis/portalmodelo             │
│ Tech: Python/Django, PostgreSQL                          │
│ Focus: Public portal, transparency, content              │
│ When: Working on public-facing features                  │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ SIGI-SD Specialist                                       │
│ Maintained by: Sertão Digital                            │
│ Tech: Python/Django, PostgreSQL                          │
│ Focus: Services, protocols, notifications, SLA           │
│ When: Working on citizen services/protocols              │
└──────────────────────────────────────────────────────────┘
```

## 📍 Location

```
LegislaGD/
├── .github/agents/
│   ├── README.md                          (Quick reference)
│   ├── AGENTS.md                          (Complete guide)
│   ├── architecture.agent.md              ✅
│   ├── development.agent.md               ✅
│   ├── engineering.agent.md               ✅
│   ├── quality.agent.md                   ✅
│   ├── observability.agent.md             ✅
│   ├── sustenance.agent.md                ✅
│   ├── sapl.agent.md                      ✅
│   ├── ecidade.agent.md                   ✅
│   ├── portal.agent.md                    ✅
│   └── sigi.agent.md                      ✅
```

## 🚀 How to Use

### Option 1: Direct Selection
1. Open Copilot Chat (Ctrl+Shift+Alt+I)
2. Type `/` → Select agent from list
3. Describe your task

### Option 2: By Mention
```
@Architecture Specialist
Design the integration between SAPL and e-Cidade

@SAPL-SD Specialist
How do I add a new bill type?

@Engineering & Operations Agent
How do I setup automated backups?
```

### Option 3: By Context
Start your message and Copilot will suggest the best agent

## 📊 Agent Selection Matrix

| I'm... | Discipline | Task | Agent |
|--------|-----------|------|-------|
| **Architecting** | Design | New integration | Architecture Specialist |
| **Developing** | Code | Feature implementation | Development + Component |
| **Operating** | Ops | Infrastructure | Engineering & Operations |
| **Testing** | QA | Security review | Quality & Security |
| **Debugging** | Ops | Production issue | Observability & Debugging |
| **Sustaining** | Ops | Release management | Sustenance & Support |
| **Working on SAPL** | Legislation | Bill workflow | SAPL-SD Specialist |
| **Working on e-Cidade** | Admin | Budget/Payroll | e-Cidade-SD Specialist |
| **Working on Portal** | Portal | Public data | Portal-Modelo-SD Specialist |
| **Working on SIGI** | Services | Service requests | SIGI-SD Specialist |

## 💡 Common Workflows

### Adding a Feature
```
1. @Architecture Specialist
   → Design the integration points

2. @Component Specialist (SAPL/e-Cidade/Portal/SIGI)
   → Understand the data model

3. @Development Agent
   → Implement the code

4. @Quality & Security Agent
   → Review for vulnerabilities & test coverage

5. @Sustenance & Support Agent
   → Plan the release
```

### Debugging Production Issue
```
1. @Observability & Debugging Agent
   → Analyze logs/metrics to find root cause

2. @Component Specialist
   → Understand the workflow

3. @Quality & Security Agent
   → Determine if it's a security issue

4. @Sustenance & Support Agent
   → Prepare hotfix/release
```

### Planning Infrastructure
```
1. @Architecture Specialist
   → Design the infrastructure requirements

2. @Engineering & Operations Agent
   → Implement Docker/Kubernetes/CI-CD

3. @Quality & Security Agent
   → Security review of infrastructure

4. @Observability & Debugging Agent
   → Setup monitoring & alerting
```

## 🎓 What Each Agent Knows

### Architecture Specialist
- Multi-component architecture (SAPL, e-Cidade, Portal, SIGI)
- ADRs (Architecture Decision Records)
- API contracts & integration patterns
- Upstream fork management
- Core principles (No-SaaS, Sovereignty, Contracts)

### Development Agent
- Python/Django patterns (SAPL, Portal, SIGI)
- Java/Spring patterns (e-Cidade)
- PostgreSQL database design
- Testing strategies
- Upstream compatibility

### Engineering & Operations
- Docker Compose setup
- Traefik reverse proxy
- Keycloak SSO configuration
- GitHub Actions CI/CD
- Backup & restore procedures
- Infrastructure as Code

### Quality & Security
- Unit/Integration/E2E testing strategies
- Security vulnerabilities (SQL injection, auth, secrets)
- Code style & linting (Black, Checkstyle)
- Coverage targets & metrics
- Compliance & audit trails

### Observability & Debugging
- Structured logging (JSON, request IDs)
- Prometheus metrics
- Distributed tracing (OpenTelemetry)
- Grafana dashboards
- SLA tracking & alerting

### Sustenance & Support
- Patch management & security updates
- Version upgrades with data migration
- Backward compatibility
- Runbooks & troubleshooting guides
- Institutional support procedures

### Component Specialists
Each knows the specific domain:
- **SAPL**: Legislative workflows, bills, votes, sessions
- **e-Cidade**: Budget, payroll, organizational structure
- **Portal**: Public data, transparency, content, accessibility
- **SIGI**: Service requests, protocols, notifications, SLA

## 📚 Additional Resources

Inside each agent file you'll find:
- **Context**: Component overview and key entities
- **Principles**: Core design patterns
- **Constraints**: Don't do this
- **Approach**: Step-by-step methodology
- **Common Tasks**: Typical development scenarios
- **Documentation References**: Links to project docs
- **Output Format**: Expected response structure

## ✨ Key Features

✅ **Specialized**: Each agent is trained on LegislaGD architecture & components
✅ **Detailed**: Includes workflows, API contracts, data models
✅ **Practical**: Common tasks and real-world examples
✅ **Principled**: Respects no-SaaS, sovereignty, contract-based integration
✅ **Discoverable**: Clear when to use each agent
✅ **Collaborative**: Agents complement each other

## 🎯 Next Steps

1. **Try an agent**: Open Copilot Chat, type `/` and pick one
2. **Read AGENTS.md**: Full reference guide with examples
3. **Check README.md**: Quick reference for agents directory
4. **Review component docs**: `docs/sapl/`, `docs/ecidade/`, etc.

---

**Created**: August 15, 2026  
**Location**: `.github/agents/`  
**Team**: LegislaGD Project  
**License**: Inherited from LegislaGD (check LICENSE)
