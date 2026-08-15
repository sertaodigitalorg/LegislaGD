# LegislaGD Custom Agents

Este arquivo documenta os agentes personalizados disponíveis para LegislaGD. Use-os para consultar especialistas em cada área do projeto.

## Como Usar

### No Chat do Copilot
1. Digite `/` para abrir seletor de agentes
2. Selecione o agente mais apropriado para sua tarefa
3. Descreva o que você quer fazer

### Exemplos de Invocação

```
# Consultar especialista de arquitetura
@Architecture Specialist
Preciso entender como SAPL-SD se integra com e-Cidade-SD via APIs

# Desenvolver feature no SAPL
@SAPL-SD Specialist
Estou adicionando um novo tipo de matéria legislativa, qual é o processo?

# Investigar problema em produção
@Observability & Debugging Agent
Logs mostram timeout no endpoint /api/materia - como faço debug?

# Preparar release
@Sustenance & Support Agent
Qual é o processo para fazer patch security no SAPL-SD?
```

---

## 📐 Agentes Funcionais (por Disciplina)

### 1. Architecture Specialist
**Para**: Decisões arquiteturais, design de componentes, ADRs, integração entre componentes

- Analisa relacionamentos entre SAPL, e-Cidade, Portal, SIGI
- Avalia conformidade com princípios (no-SaaS, soberania, contratos)
- Desenha soluções baseadas em APIs e eventos
- Documenta decisões arquiteturais

**Quando usar**:
- Projetando nova integração entre componentes
- Revisando proposta de mudança arquitetural
- Analisando violação de princípios (DB coupling)
- Documentando ADR

**Exemplo**: "Qual é a melhor forma de SIGI notificar Portal sobre mudança de status?"

---

### 2. Development Agent
**Para**: Implementação de features, refatoração, padrões de codificação, testes unitários

- Entende stack tecnológico (Python/Django, Java/Spring, PostgreSQL)
- Guia desenvolvimento respeitando separação de componentes
- Implementa contratos inter-componentes (APIs, webhooks)
- Respeita forks upstream

**Quando usar**:
- Implementando uma nova feature
- Refatorando código
- Integrando cross-component
- Definindo testes unitários

**Exemplo**: "Preciso adicionar um campo 'observações' em uma matéria do SAPL, como faço?"

---

### 3. Engineering & Operations Agent
**Para**: Deployment, CI/CD, infraestrutura, backup, monitoramento, segurança

- Gerencia Docker Compose, Traefik, Keycloak
- Configura pipelines de deployment (GitHub Actions)
- Implanta backups e restore procedures
- Monitora saúde da plataforma

**Quando usar**:
- Fazendo deploy de um componente
- Configurando backup/restore
- Otimizando infraestrutura
- Preparando staging/produção

**Exemplo**: "Como configuro auto-backup dos bancos de dados?"

---

### 4. Quality & Security Agent
**Para**: Testes, cobertura de código, segurança, padrões de qualidade, vulnerabilidades

- Desenha estratégias de teste (unit, integration, E2E)
- Identifica vulnerabilidades (SQL injection, auth, secrets)
- Estabelece quality gates e métricas
- Faz security review

**Quando usar**:
- Desenhando plano de testes
- Revisando código para vulnerabilidades
- Aumentando cobertura de testes
- Audit de segurança

**Exemplo**: "Como garantir que dados administrativos não vazam para Portal?"

---

### 5. Observability & Debugging Agent
**Para**: Logging, métricas, monitoramento, diagnóstico de problemas, performance

- Instrumenta componentes (logs estruturados, métricas)
- Desenha dashboards (Grafana)
- Guia troubleshooting de problemas
- Trace distribuído (OpenTelemetry)

**Quando usar**:
- Investigando erro em produção
- Desenhando observabilidade
- Analisando performance
- Debugging aplicação

**Exemplo**: "Uma requisição para Portal está lenta, como identifico o gargalo?"

---

### 6. Sustenance & Support Agent
**Para**: Manutenção, patches, upgrades, bug fixes, suporte institucional, documentação

- Gerencia patches e security updates
- Planeja upgrades de versão (com data migration)
- Mantém compatibilidade backward
- Suporta municípios em troubleshooting

**Quando usar**:
- Preparando security patch
- Planejando major version upgrade
- Criando runbook de troubleshooting
- Respondendo incident em produção

**Exemplo**: "Qual é o procedimento para fazer upgrade do PostgreSQL sem perder dados?"

---

## 🏛️ Agentes Especializados (por Componente)

### 7. SAPL-SD Specialist
**Para**: Desenvolvimento legislativo, workflow de matérias, votações, sessões

- Entende processo legislativo e workflow de matérias
- Desenha fluxos de votação e aprovação
- Integra matérias com e-Cidade (impacto administrativo)
- Publica legislação no Portal
- Sincroniza com upstream (Interlegis/SAPL)

**Quando usar**:
- Desenvolvendo feature legislativa
- Desenhando novo tipo de matéria
- Integrando votação com e-Cidade
- Sincronizando upstream

**Exemplo**: "Como implemento um novo fluxo de votação para decretos?"

---

### 8. e-Cidade-SD Specialist
**Para**: Desenvolvimento administrativo/financeiro, orçamento, folha de pagamento, organização

- Entende estrutura organizacional, papéis, departamentos
- Desenha workflows administrativos e financeiros
- Gerencia orçamento, empenhos, liquidações
- Calcula folha de pagamento
- Integra com legislação (SAPL) e transparência (Portal)

**Quando usar**:
- Implementando workflow administrativo
- Desenhando novo tipo de serviço
- Configurando novo departamento
- Integrando com SAPL/Portal

**Exemplo**: "Como estruturo a folha de pagamento para dois tipos de servidores diferentes?"

---

### 9. Portal-Modelo-SD Specialist
**Para**: Desenvolvimento público, portal institucional, conteúdo, transparência, cidadania

- Entende consumo de dados de SAPL e e-Cidade
- Desenha seções públicas (legislação, transparência, serviços)
- Implementa filtros de privacidade (dados públicos vs. internos)
- Otimiza performance e accessibility (WCAG)
- Integra buscas e navegação

**Quando usar**:
- Adicionando nova seção pública
- Expondo dados legislativos ou financeiros
- Melhorando experiência do cidadão
- Otimizando performance

**Exemplo**: "Como exponho o orçamento municipal no Portal sem vazam dados internos?"

---

### 10. SIGI-SD Specialist
**Para**: Desenvolvimento de serviços, protocolos, notificações, SLA, cidadania

- Entende workflow de requisições de serviço
- Desenha sistema de notificações multi-canal
- Gerencia SLA e escalações
- Integra com Portal (filing de requisições)
- Integra com e-Cidade (departamentos, staff)

**Quando usar**:
- Adicionando novo tipo de serviço
- Desenhando sistema de notificações
- Configurando SLA
- Integrando com Portal/e-Cidade

**Exemplo**: "Como implemento fila de espera para serviços com alta demanda?"

---

## 🎯 Matriz de Decisão

Qual agente devo escolher?

| Pergunta | Resposta | Agente |
|----------|----------|--------|
| **Por que estou aqui?** | Projetar nova funcionalidade | Architecture, Component Specialist |
| | Implementar código | Development, Component Specialist |
| | Deploy/infraestrutura | Engineering & Operations |
| | Testar/qualidade | Quality & Security |
| | Debug/performance | Observability & Debugging |
| | Manutenção/patch | Sustenance & Support |
| **Em qual componente?** | Legislativo | SAPL-SD Specialist |
| | Administrativo/Financeiro | e-Cidade-SD Specialist |
| | Portal público | Portal-Modelo-SD Specialist |
| | Serviços/Cidadania | SIGI-SD Specialist |
| | Múltiplos componentes | Architecture + Component Specialists |

---

## 📚 Referências Rápidas

### Documentação do Projeto
- [README.md](../../README.md) - Overview geral
- [docs/arquitectura/visao-geral.md](../../docs/arquitectura/visao-geral.md) - Arquitetura
- [docs/adr/](../../docs/adr/) - Decisões arquiteturais
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Padrões de contribuição

### Tech Stack

| Componente | Linguagem | Framework | Banco |
|-----------|-----------|-----------|-------|
| SAPL-SD | Python 3.x | Django | PostgreSQL |
| e-Cidade-SD | Java 11+ | Spring Boot | PostgreSQL |
| PortalModelo-SD | Python 3.x | Django | PostgreSQL |
| SIGI-SD | Python 3.x | Django | PostgreSQL |
| Infrastructure | Shell | Docker Compose | - |

### Princípios Fundamentais
1. **Não-SaaS**: Cada instituição hospeda sua própria instância
2. **Soberania**: Código, dados, operação sob controle institucional
3. **Contratos**: APIs, webhooks, eventos; sem acoplamento direto
4. **Forks responsáveis**: Mantemos forks de projetos upstream, respeitando origens

---

## 💡 Exemplos de Workflows

### Adicionar Nova Feature Legislativa

1. **Conversa inicial com Architecture Specialist**
   - "Preciso de um novo tipo de matéria legislativa para decretos. Como integro?"

2. **Trabalhe com SAPL-SD Specialist**
   - "Qual é o data model para matérias? Como implemento novo tipo?"

3. **Consulte Development Agent**
   - "Estou pronto para código. Qual é a estrutura de testes?"

4. **Colabore com Quality & Security Agent**
   - "Quais testes preciso antes de mergear?"

5. **Finalize com Sustenance & Support Agent**
   - "Qual é o procedimento de release?"

### Investigar Problema em Produção

1. **Comece com Observability & Debugging Agent**
   - "Vejo timeout no endpoint /api/materia. Como investigo?"

2. **Consulte Component Specialist (SAPL ou Portal)**
   - "Qual é o fluxo de dados nesse endpoint?"

3. **Trabalhe com Quality & Security Agent**
   - "Pode ser vulnerabilidade? Como testo?"

4. **Finalize com Sustenance & Support Agent**
   - "Qual é o hotfix? Preciso fazer rollback?"

---

## 🚀 Tips para Melhor Experiência

### Seja Específico
❌ "Como faço uma feature?"
✅ "Como implemento validação de quórum em votações no SAPL?"

### Forneça Contexto
❌ "Dá erro"
✅ "Ao fazer POST /api/materia com tipo 'Decreto', recebo 400. O que falta?"

### Use o Agente Certo
❌ Pedir arquitetura para Development Agent
✅ Pedir código para Development Agent, design para Architecture Specialist

### Itere
✅ Comece com question geral → Specialized Agent → Specific Component Specialist

---

## 📝 Contribuindo com Agents

Para sugerir melhorias aos agents:
1. Edite o arquivo `.agent.md` correspondente
2. Teste a mudança (converse com o agent)
3. Faça PR para `.github/agents/`

[Voltar para CONTRIBUTING.md](../../CONTRIBUTING.md)
