# Auditoria Documental — LegislaGD

**Data:** 2026-08-27  
**Origem:** `SD-Knowledge/docs/DOCUMENTATION_AUDIT_MATRIX_2026-08-27.md`  
**Prioridade:** A  
**Estado:** UNDER_REVIEW  
**Linha de integração:** branch de trabalho → `dev` → `hml` → `main`

## Objetivo
Revisar profundamente o `LegislaGD`, separando documentação FUNCIONAL, TÉCNICA, HÍBRIDA e PONTEIROS segundo a política de autoridade do Sertão Digital.

## Autoridades
- Google Drive: MASTER funcional, institucional, estratégico e de produto.
- GitHub: MASTER técnico: engenharia, arquitetura, implantação, APIs, integrações técnicas, segurança, testes, CI/CD e ADRs.
- Híbridos devem separar explicitamente as autoridades.
- Documentação upstream não deve ser migrada automaticamente para o Drive.

## Governança Git aplicada
A auditoria passou a usar `dev` como branch viva. Alterações desta revisão estão em branch derivada de `dev` e seguem por Pull Request para `dev`; promoção posterior ocorre por `dev -> hml -> main`.

## MASTERs funcionais confirmados no Drive
- `FICHA-FUNCIONAL-E-ESTRATEGICA-LEGISLAGD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-SAPL-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-E-CIDADE-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-PORTALMODELO-SD`
- `FICHA-FUNCIONAL-E-ESTRATEGICA-SIGI-SD`

## Classificação consolidada

### SAPL
| Arquivo | Classe | Ação |
|---|---|---|
| `docs/sapl/distribuicao-sapl-sd.md` | TÉCNICO/REFERENCIAL | Manter |
| `docs/sapl/integracao-sapl.md` | TÉCNICO | Manter |
| `docs/sapl/sincronizacao-upstream.md` | TÉCNICO/GOVERNANÇA DE FORK | Manter |
| `docs/sapl/processo-legislativo.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO para a ficha SAPL-SD do Drive |

A ficha funcional SAPL-SD confirma que o produto é autônomo, atua como componente especializado do processo legislativo no LegislaGD e associa seu escopo a processo legislativo, proposições, sessões, pautas, votações, atas e comissões. O GitHub não deve redefinir esse escopo.

### e-Cidade
| Arquivo | Classe | Ação |
|---|---|---|
| `docs/ecidade/integracao-administrativa.md` | TÉCNICO | Manter |
| `docs/ecidade/cadastros-iniciais.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO |
| `docs/ecidade/folha-de-pagamento.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO |
| `docs/ecidade/perfil-legislativo.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO |
| `docs/ecidade/modulos-legislativos.md` | HÍBRIDO | Separadas regra funcional de implantação e princípio técnico de base única |

A ficha funcional e-Cidade-SD confirma uma única base configurável por cadastros, perfis e módulos. A escolha concreta dos módulos pertence à implantação funcional; a estratégia de não duplicar código permanece decisão técnica.

### PortalModelo
| Arquivo | Classe | Ação |
|---|---|---|
| `docs/portalmodelo/distribuicao-portalmodelo-sd.md` | TÉCNICO/REFERENCIAL | Manter |
| `docs/portalmodelo/portal-institucional.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO |
| `docs/portalmodelo/integracao-portal.md` | HÍBRIDO | Manter por enquanto; separar decisões de publicação de canais das integrações técnicas |
| `docs/portalmodelo/migracao-conteudo-site-original.md` | HÍBRIDO OPERACIONAL | Manter; execução técnica depende de escopo funcional de conteúdo, LGPD e aceite |
| `docs/portalmodelo/inventario-migracao-conteudo.csv` | OPERACIONAL/TÉCNICO | Manter como instrumento de execução, não como MASTER funcional |

A ficha PortalModelo-SD confirma seu papel institucional/transparência e autonomia de produto. A migração técnica de conteúdo deve continuar versionada no GitHub, mas decisões sobre o que publicar/migrar pertencem à implantação funcional.

### SIGI-SD no contexto LegislaGD
| Arquivo | Classe | Ação |
|---|---|---|
| `docs/sigi-sd/integracao-sigi-sd.md` | TÉCNICO/HÍBRIDO | Manter; limites funcionais devem derivar do Drive |
| `docs/sigi-sd/comunicacao-unica-camara.md` | HÍBRIDO | Manter desenho técnico; não promover sugestões de SLA, canais ou papéis a regra sem MASTER |
| `docs/sigi-sd/atendimento-legislativo.md` | FUNCIONAL DERIVADO | Convertido em PONTEIRO |
| `docs/sigi-sd/esic.md` | FUNCIONAL/PENDÊNCIA | Convertido em PONTEIRO; regras formais precisam MASTER funcional |
| `docs/sigi-sd/ouvidoria.md` | FUNCIONAL/PENDÊNCIA | Convertido em PONTEIRO; regras formais precisam MASTER funcional |
| `docs/sigi-sd/PENDING_SYNC.md` | PONTEIRO DE SINCRONIZAÇÃO | Manter até resolução do handoff funcional |
| `docs/sigi-sd/PROMPT-HANDOFF-FUNCIONAL-COMUNICACAO-UNICA-2026-08-26.md` | HANDOFF FUNCIONAL | Manter como registro de sincronização até fechamento |

A ficha funcional SIGI-SD já define a plataforma como CiRM e camada transversal de atendimento, protocolo, comunicação, workflow e auditoria, mantendo regras de negócio nos sistemas especializados. O handoff de Comunicação Única continua parcialmente pendente porque canais obrigatórios, textos públicos, SLA, matriz final de papéis e retenção de anexos ainda não estão formalizados como política funcional específica.

### Arquitetura e ADRs
| Artefato | Classe | Ação |
|---|---|---|
| `docs/arquitetura/fluxo-de-dados.md` | TÉCNICO | Manter |
| `docs/arquitetura/integracoes.md` | TÉCNICO | Manter |
| `docs/arquitetura/visao-geral.md` | TÉCNICO com contexto funcional | Manter; diagrama é arquitetura técnica |
| `docs/arquitetura/componentes.md` | HÍBRIDO | Revisar para reduzir definições funcionais duplicadas |
| `docs/arquitetura/responsabilidades.md` | HÍBRIDO | Revisar; contém autoridade de dados/domínio e arquitetura |
| `docs/arquitetura/soberania-tecnologica.md` | HÍBRIDO ESTRATÉGICO/TÉCNICO | Manter princípio técnico; garantir correspondência com política funcional |
| `docs/architecture/chatwoot-sso.md` | TÉCNICO | Manter |
| `docs/architecture/sso-analysis.md` | TÉCNICO/HISTÓRICO | Manter; estado observado pode envelhecer e deve ser datado |
| `docs/architecture/sso-implementation-plan.md` | TÉCNICO | Manter |
| ADR-001 | TÉCNICO | Manter |
| ADR-002 | HÍBRIDO | Decisão técnica derivada de princípio institucional não-SaaS/soberania |
| ADR-003 | TÉCNICO | Manter |
| ADR-004 | HÍBRIDO | Base única é decisão técnica; perfis/módulos concretos são funcionais |
| ADR-005 | TÉCNICO | Manter |
| ADR-006 | TÉCNICO/GOVERNANÇA GIT | Manter; confirma fluxo `feature/fix/bugfix/chore -> dev -> hml -> main` |
| ADR-007 | HÍBRIDO BEM SEPARADO | Manter; registra requisitos validados no Drive e decisão técnica do Core |
| ADR-008 | HÍBRIDO BEM SEPARADO | Manter; requisitos funcionais vêm do MASTER e modelagem técnica permanece no ADR |

## Achados críticos

### 01 — Estado funcional desatualizado
A ficha LegislaGD revisada em 2026-08-14 contém registros de acessibilidade que precisam ser atualizados com o estado atual dos repositórios. Atualizar o Drive preservando o histórico da auditoria anterior.

### 02 — README híbrido
O README combina missão/papéis com arquitetura e operação. Deve futuramente explicitar que missão, limites institucionais e papéis funcionais derivam do MASTER no Drive.

### 03 — Conteúdo funcional mínimo espalhado
Foram encontrados vários arquivos de poucas linhas que declaravam regras funcionais como se fossem autoridade local (`processo-legislativo`, `perfil-legislativo`, `cadastros-iniciais`, `folha-de-pagamento`, `portal-institucional`, `atendimento-legislativo`, `esic`, `ouvidoria`). Os casos já validados foram convertidos em ponteiros ou tiveram a autoridade separada.

### 04 — Comunicação Única é o principal híbrido pendente
`comunicacao-unica-camara.md` é tecnicamente consistente e reconhece suas próprias pendências funcionais. O handoff existente deve ser resolvido no Drive antes de canais obrigatórios, SLA, textos, papéis ou retenção virarem regra do produto.

### 05 — ADRs 007/008 são bom padrão de híbrido
Os ADRs do Plenário Digital registram explicitamente quais requisitos vieram do MASTER funcional e mantêm a decisão arquitetural no GitHub. Esse padrão deve ser reutilizado nos próximos documentos híbridos.

## Execução
- [x] Localizar matriz oficial.
- [x] Inventariar estrutura principal.
- [x] Localizar MASTER funcional no Drive.
- [x] Revisar `docs/sapl/`.
- [x] Revisar `docs/ecidade/`.
- [x] Revisar `docs/portalmodelo/`.
- [x] Revisar `docs/sigi-sd/`.
- [x] Revisar arquitetura e ADRs em busca de regras funcionais duplicadas.
- [x] Converter casos funcionais validados em PONTEIROS ou separar conteúdo HÍBRIDO.
- [ ] Atualizar a ficha funcional LegislaGD no Drive com estado atual dos vínculos/repositórios.
- [ ] Resolver o handoff funcional `2026-08-26-FUNCTIONAL-001` no Drive.
- [ ] Ajustar `componentes.md`, `responsabilidades.md`, README e híbridos restantes com referências explícitas ao MASTER.
- [ ] Atualizar `PENDING_SYNC.md` após sincronização funcional.
- [ ] Registrar fechamento do LegislaGD na matriz consolidada do `SD-Knowledge`.

## Segurança
Nenhum conteúdo upstream foi migrado para o Drive. Nenhum histórico Git foi excluído. As alterações desta auditoria são documentais e seguem a linha viva `dev` por Pull Request.
