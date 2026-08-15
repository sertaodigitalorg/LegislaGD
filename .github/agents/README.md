# LegislaGD Custom Agents

This directory contains specialized AI agents for different aspects of LegislaGD development.

## 🎯 Quick Start

### How to Use
1. Open Copilot Chat in VS Code (Ctrl+Shift+Alt+I)
2. Type `/` to see available agents
3. Select the appropriate agent for your task
4. Describe what you need

### Discovery
- **Functional agents**: For disciplines (Architecture, Development, Quality, etc.)
- **Component agents**: For specific modules (SAPL, e-Cidade, Portal, SIGI)

See [AGENTS.md](./AGENTS.md) for complete guide and decision matrix.

## 📁 File Structure

```
.github/agents/
├── README.md                      # This file
├── AGENTS.md                      # Complete reference guide
├── architecture.agent.md          # Architecture & design decisions
├── development.agent.md           # Code implementation
├── engineering.agent.md           # Infrastructure & operations
├── quality.agent.md               # Testing & security
├── observability.agent.md         # Debugging & monitoring
├── sustenance.agent.md            # Maintenance & support
├── sapl.agent.md                  # Legislative component
├── ecidade.agent.md               # Admin/Financial component
├── portal.agent.md                # Public portal component
└── sigi.agent.md                  # Services/Protocol component
```

## 🏛️ Functional Agents

| Agent | Purpose | Tools |
|-------|---------|-------|
| **Architecture Specialist** | System design, integrations, ADRs | read, search, web |
| **Development Agent** | Feature implementation, code | read, search, edit, execute |
| **Engineering & Ops** | Infrastructure, deployment, monitoring | read, search, execute |
| **Quality & Security** | Testing, vulnerabilities, standards | read, search, execute |
| **Observability & Debugging** | Logging, metrics, troubleshooting | read, search, execute |
| **Sustenance & Support** | Patches, upgrades, maintenance | read, search, execute |

## 🔧 Component Agents

| Agent | Module | Focus |
|-------|--------|-------|
| **SAPL-SD Specialist** | sapl.agent.md | Legislative workflows, bills, voting |
| **e-Cidade-SD Specialist** | ecidade.agent.md | Admin/financial, budget, payroll |
| **Portal-Modelo Specialist** | portal.agent.md | Public portal, transparency, content |
| **SIGI-SD Specialist** | sigi.agent.md | Services, protocols, notifications |

## 📚 When to Use Each

### By Task Type
- **Designing**: Architecture Specialist + Component Specialist
- **Coding**: Development Agent + Component Specialist
- **Deploying**: Engineering & Operations Agent
- **Testing**: Quality & Security Agent
- **Debugging**: Observability & Debugging Agent
- **Maintaining**: Sustenance & Support Agent

### By Component
- **Legislative (SAPL)**: SAPL-SD Specialist
- **Admin/Finance (e-Cidade)**: e-Cidade-SD Specialist
- **Public Portal**: Portal-Modelo-SD Specialist
- **Services (SIGI)**: SIGI-SD Specialist

## 💡 Example Conversations

```
# Legislative Feature
@Architecture Specialist
I need to add a new bill type in SAPL. What's the integration point with e-Cidade?

# Admin/Finance
@e-Cidade-SD Specialist
How do I implement a new payroll rule?

# Bug Investigation
@Observability & Debugging Agent
API timeout on /api/materia - how do I debug this?

# Release
@Sustenance & Support Agent
What's the process for a security patch?
```

## 🎓 Philosophy

Each agent is trained on:
- LegislaGD architecture and principles
- Component responsibilities and integration contracts
- Technology stack for each module
- Common workflows and patterns
- Best practices for institutional deployments

Agents respect:
- **No-SaaS principle**: Institutional autonomy over centralized services
- **Sovereignty**: Code, data, operations under institutional control
- **Contract-based integration**: APIs, events, webhooks (no direct DB access)
- **Upstream respect**: Forks preserve original licenses and credits

## 📖 Full Reference

See [AGENTS.md](./AGENTS.md) for:
- Complete agent descriptions
- When to use each agent
- Decision matrix
- Quick reference by component
- Tips for best experience

## 🚀 Customization

To improve or add agents:
1. Edit the corresponding `.agent.md` file
2. Test by chatting with the agent
3. Submit PR to improve coverage

Agents use VS Code's custom agent format with YAML frontmatter:
```yaml
---
description: "Use when..."  # Discovery trigger
tools: [read, search, edit, execute]  # Allowed tools
---
```

## 📝 Feedback

Found an issue with an agent? Improvements to suggest?
- Edit the `.agent.md` file
- Add context to pull request
- Reference specific prompts where agent could improve
