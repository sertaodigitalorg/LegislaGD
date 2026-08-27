# Auditoria Documental — LegislaGD

**Data:** 2026-08-27  
**Origem:** `SD-Knowledge/docs/DOCUMENTATION_AUDIT_MATRIX_2026-08-27.md`  
**Prioridade:** A  
**Estado:** UNDER_REVIEW

## Objetivo
Revisar profundamente o `LegislaGD`, separando documentação FUNCIONAL, TÉCNICA, HÍBRIDA e PONTEIROS segundo a política de autoridade do Sertão Digital.

## Autoridades
- Google Drive: MASTER funcional, institucional, estratégico e de produto.
- GitHub: MASTER técnico: engenharia, arquitetura, implantação, APIs, integrações técnicas, segurança, testes, CI/CD e ADRs.
- Híbridos devem ter autoridades separadas e referências cruzadas.
- Documentação upstream não deve ser migrada automaticamente para o Drive.

## Inventário inicial
A estrutura `docs/` contém `adr/`, `architecture/`, `arquitetura/`, `ecidade/`, `governanca/`, `implantacao/`, `portalmodelo/`, `roadmap/`, `sapl/`, `seguranca/` e `sigi-sd/`, além dos documentos técnicos da raiz.

## Classificação preliminar
| Artefato/área | Classe | Autoridade | Ação |
|---|---|---|---|
| `README.md` | HÍBRIDO | GitHub técnico / Drive funcional | Manter operação técnica; tratar missão, escopo e papéis como referências derivadas do Drive |
| `docs/implantacao/*` | TÉCNICO predominante | GitHub | Manter |
| `docs/governanca/estrategia-de-forks.md` | TÉCNICO | GitHub | Manter |
| `docs/governanca/*` | TÉCNICO predominante | GitHub | Revisar caso a caso |
| `docs/architecture/*`, `docs/arquitetura/*` | TÉCNICO | GitHub | Manter; identificar regras funcionais duplicadas |
| `docs/sapl/*` | TÉCNICO/INTEGRAÇÃO | GitHub | Manter; não migrar upstream |
| `docs/ecidade/*` | TÉCNICO/INTEGRAÇÃO | GitHub | Manter; não migrar upstream |
| `docs/portalmodelo/*` | TÉCNICO/INTEGRAÇÃO | GitHub | Manter; não migrar upstream |
| `docs/sigi-sd/*` | TÉCNICO/INTEGRAÇÃO | GitHub | Manter; operação funcional deve apontar para Drive |
| `docs/relatorio-estrutura-inicial.md` | TÉCNICO/HISTÓRICO | GitHub | Manter |

## MASTER funcional localizado
No Drive foi localizado `FICHA-FUNCIONAL-E-ESTRATEGICA-LEGISLAGD`, em `00_CONTROLE_FUNCIONAL`, consolidando finalidade, escopo legislativo, limite institucional, ecossistema, papéis dos componentes, identidade/SSO e política documental.

## Achados
### 01 — Estado funcional desatualizado
A ficha funcional revisada em 2026-08-14 ainda registra `LegislaGD`, `SAPL-SD` e `PortalModelo-SD` como não validados naquela auditoria. Em 2026-08-27 o `LegislaGD` está acessível e sua documentação técnica está consolidada.

**Ação:** atualizar posteriormente o MASTER funcional no Drive com o estado atual, preservando o histórico da revisão anterior.

### 02 — README híbrido
O README combina missão, princípios e responsabilidades funcionais com arquitetura, desenvolvimento local, PostgreSQL, Keycloak, branches, variáveis e módulos.

**Ação:** manter a parte técnica no GitHub e explicitar que missão, limites institucionais e papéis funcionais são derivados do MASTER funcional no Drive.

### 03 — Relatório inicial é técnico/histórico
`docs/relatorio-estrutura-inicial.md` registra publicação de repositórios, branches, caminhos locais, limitações de checkout, Git LFS, commits e procedimentos. Deve permanecer no GitHub.

### 04 — Estratégia de forks é governança técnica
`docs/governanca/estrategia-de-forks.md` trata de upstream, origem canônica, branches, force push, sincronização e licenças/créditos. Deve permanecer no GitHub.

## Execução
- [x] Localizar matriz oficial.
- [x] Inventariar estrutura principal.
- [x] Localizar MASTER funcional no Drive.
- [x] Confirmar primeiro caso de desatualização funcional.
- [x] Classificar README, implantação, estratégia de forks e relatório inicial.
- [ ] Revisar `docs/sapl/`.
- [ ] Revisar `docs/ecidade/`.
- [ ] Revisar `docs/portalmodelo/`.
- [ ] Revisar `docs/sigi-sd/`.
- [ ] Revisar arquitetura e ADRs buscando regras funcionais duplicadas.
- [ ] Atualizar a ficha funcional no Drive.
- [ ] Converter eventuais documentos funcionais no GitHub em PONTEIROS após sincronização validada.
- [ ] Registrar fechamento na matriz do `SD-Knowledge`.

## Segurança
Nenhum conteúdo será migrado ou removido apenas pelo nome. Nenhum histórico Git será excluído e nenhuma documentação upstream será promovida automaticamente a MASTER funcional.
