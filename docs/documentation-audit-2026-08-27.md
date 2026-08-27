# Auditoria Documental — LegislaGD

**Data:** 2026-08-27  
**Origem:** `SD-Knowledge/docs/DOCUMENTATION_AUDIT_MATRIX_2026-08-27.md`  
**Prioridade:** A  
**Estado:** CLOSED  
**Linha de integração:** branch de trabalho -> `dev` -> `hml` -> `main`

## Objetivo

Separar e consolidar documentação FUNCIONAL, TÉCNICA, HÍBRIDA e PONTEIROS conforme a política de autoridade do Sertão Digital.

## Autoridades consolidadas

- Google Drive: MASTER funcional, institucional, estratégico e de produto.
- GitHub: MASTER técnico para engenharia, arquitetura, implantação, APIs, integrações técnicas, segurança, testes, CI/CD e ADRs.
- Documentos híbridos devem declarar explicitamente as duas autoridades.
- Documentação upstream não é promovida automaticamente a MASTER funcional.

## MASTERs funcionais confirmados

- `FICHA-FUNCIONAL-E-ESTRATEGICA-LEGISLAGD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-SAPL-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-E-CIDADE-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-PORTALMODELO-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-SIGI-SD`

## Saneamentos realizados

### SAPL-SD
`docs/sapl/processo-legislativo.md` foi convertido em ponteiro funcional para o MASTER do Drive. Integração, APIs, sincronização upstream e engenharia permanecem no GitHub.

### e-Cidade-SD
`cadastros-iniciais.md`, `folha-de-pagamento.md` e `perfil-legislativo.md` foram convertidos em referências funcionais. `modulos-legislativos.md` passou a separar a escolha funcional dos módulos do princípio técnico de base única configurável.

### PortalModelo-SD
`portal-institucional.md` passou a apontar para o MASTER funcional. Migração, temas, configuração e integrações permanecem técnicos/operacionais no GitHub.

### SIGI-SD
`atendimento-legislativo.md`, `esic.md` e `ouvidoria.md` deixaram de definir política institucional localmente e passaram a referenciar o MASTER funcional.

O handoff `2026-08-26-FUNCTIONAL-001` foi resolvido em 2026-08-27. A ficha `FICHA-FUNCIONAL-E-ESTRATEGICA-SIGI-SD` recebeu a política funcional base do Atendimento Único da Câmara, definindo canais institucionais parametrizáveis, categorias de mensagens públicas, SLA/horário por implantação, papéis funcionais, publicação no PortalModelo-SD, princípios LGPD, retenção e homologação.

`PENDING_SYNC.md` foi atualizado para `RESOLVED`.

### Arquitetura
`componentes.md` e `responsabilidades.md` agora separam explicitamente autoridade funcional do Drive e arquitetura/autoridade técnica do GitHub.

O README passou a declarar a política Drive x GitHub, corrigiu o SIGI-SD como plataforma própria sem upstream e consolidou a linha técnica de integração.

### ADRs
ADRs 007 e 008 do Plenário Digital foram validados como padrão recomendado para documentos híbridos: requisitos funcionais referenciados a partir do MASTER e decisão arquitetural mantida no GitHub.

## Fluxo Git

O fluxo documental e técnico permanece:

`feature/*`, `fix/*`, `bugfix/*` ou `chore/*` -> `dev` -> `hml` -> `main`

Promoções devem ocorrer por Pull Request, checks e aprovações exigidas pelos rulesets vigentes. Esta auditoria não autoriza force push, exclusão de branches protegidas ou bypass de revisão.

## Execução

- [x] Localizar matriz oficial.
- [x] Inventariar estrutura principal.
- [x] Localizar MASTER funcional no Drive.
- [x] Revisar `docs/sapl/`.
- [x] Revisar `docs/ecidade/`.
- [x] Revisar `docs/portalmodelo/`.
- [x] Revisar `docs/sigi-sd/`.
- [x] Revisar arquitetura e ADRs.
- [x] Atualizar a ficha funcional LegislaGD no Drive.
- [x] Resolver o handoff funcional `2026-08-26-FUNCTIONAL-001` no Drive.
- [x] Ajustar `componentes.md`, `responsabilidades.md` e README.
- [x] Atualizar `PENDING_SYNC.md` para `RESOLVED`.
- [x] Consolidar fechamento documental do LegislaGD.

## Resultado

A auditoria documental Prioridade A do LegislaGD está encerrada no nível de classificação, autoridade e sincronização funcional base.

Configurações específicas de cada Câmara continuam a ser registradas na documentação funcional da respectiva implantação, sem hardcode institucional no repositório técnico.

## Segurança

Nenhum histórico Git foi removido. Nenhuma documentação upstream foi migrada indevidamente para o Drive. Nenhuma credencial, token ou segredo foi incluído na documentação funcional.
