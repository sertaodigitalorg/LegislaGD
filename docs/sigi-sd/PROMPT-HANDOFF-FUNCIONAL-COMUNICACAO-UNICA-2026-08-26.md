# Prompt Handoff - Comunicacao Unica da Camara

**ID:** 2026-08-26-FUNCTIONAL-001  
**Tipo:** FUNCTIONAL  
**Data:** 2026-08-26  
**Produto:** LegislaGD / SIGI-SD / PortalModelo-SD  
**Status:** RESOLVED  
**Data de resolucao:** 2026-08-27

---

## Origem

Durante a organizacao tecnica do LegislaGD foi consolidado o desenho local de Atendimento Unico e Canais Oficiais da Camara em:

- `docs/sigi-sd/comunicacao-unica-camara.md`
- `docs/sigi-sd/integracao-sigi-sd.md`
- `docs/portalmodelo/integracao-portal.md`

---

## Resolucao funcional

O Google Drive foi atualizado no documento `FICHA-FUNCIONAL-E-ESTRATEGICA-SIGI-SD` com a politica funcional base do Atendimento Unico da Camara.

A politica define:

1. conceito de Atendimento Unico;
2. uso exclusivo de canais institucionais oficialmente aprovados;
3. canais parametrizaveis por implantacao, sem obrigatoriedade hardcoded;
4. textos institucionais obrigatorios por categoria, definidos pela respectiva Casa;
5. horario de atendimento e SLA como parametros funcionais da implantacao;
6. matriz funcional minima de papeis e principio de menor privilegio;
7. politica de publicacao no PortalModelo-SD;
8. principios LGPD para dados pessoais, anexos, retencao e descarte;
9. proibicao de descarte automatico irreversivel sem politica institucional aprovada;
10. procedimento minimo de homologacao publica e operacional.

## Limite de autoridade

O Drive permanece MASTER para politica funcional, canais aprovados, textos, horarios, SLAs, papeis e regras institucionais da implantacao.

O GitHub permanece MASTER para APIs, webhooks, filas, Chatwoot, Keycloak, roles tecnicas, variaveis de ambiente, seguranca tecnica, deploy, idempotencia e testes.

## Criterios de validacao

- [x] Documento funcional atualizado no Drive.
- [x] Modelo de canais oficiais definido por implantacao.
- [x] Politica de textos publicos definida sem impor redacao universal.
- [x] Matriz funcional minima revisada com menor privilegio.
- [x] Horario e SLA definidos como parametros obrigatorios da implantacao.
- [x] Regras LGPD e retencao registradas.
- [x] Referencia cruzada para a documentacao tecnica do LegislaGD mantida.

## Resultado

Handoff concluido na camada funcional base. Valores concretos de cada Camara continuam a ser definidos na documentacao funcional da respectiva implantacao.
