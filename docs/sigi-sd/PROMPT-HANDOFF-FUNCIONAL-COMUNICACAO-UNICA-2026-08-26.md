# Prompt Handoff - Comunicacao Unica da Camara

**ID:** 2026-08-26-FUNCTIONAL-001  
**Tipo:** FUNCTIONAL  
**Data:** 2026-08-26  
**Produto:** LegislaGD / SIGI-SD / PortalModelo-SD  
**Status:** PENDING

---

## Origem

Durante a organizacao tecnica do LegislaGD foi consolidado o desenho local de
Atendimento Unico e Canais Oficiais da Camara em:

- `docs/sigi-sd/comunicacao-unica-camara.md`
- `docs/sigi-sd/integracao-sigi-sd.md`
- `docs/portalmodelo/integracao-portal.md`

Tambem foram ajustados rotulos de telas administrativas no SIGI-SD para alinhar
Protocolos, Chatwoot e canais em uma mesma area operacional.

---

## Contexto

O LegislaGD passa a tratar e-mail, WhatsApp, webchat e outros canais oficiais
como entradas de uma fila unica de atendimento legislativo:

- PortalModelo-SD publica os canais oficiais.
- Chatwoot recebe e opera as conversas.
- SIGI-SD importa conversas, gera protocolo e guarda historico.
- Keycloak Legislativo centraliza identidade.
- SAPL-SD/e-Cidade-SD recebem encaminhamentos por contrato quando aplicavel.

A camada tecnica nao deve definir sozinha quais canais uma Camara publica, qual
texto oficial usa com o cidadao, quais SLAs assume ou quais papeis funcionais
existem alem dos papeis tecnicos atuais.

---

## Mudanca Necessaria

Atualizar a documentacao funcional/institucional no Google Drive para registrar:

1. Conceito de Atendimento Unico da Camara.
2. Canais oficiais autorizados: e-mail, WhatsApp, webchat, Instagram ou outros.
3. Texto padrao de saudacao, protocolo, ausencia de expediente e encerramento.
4. Horario de atendimento, SLA e regras de redistribuicao.
5. Matriz funcional de papeis: atendente, supervisor, administrador de canais,
   administrador geral e demais perfis aprovados.
6. Politica de publicacao dos canais no PortalModelo-SD.
7. Politica LGPD para anexos, dados pessoais, consentimento, retencao e descarte.
8. Procedimento de homologacao visual da parte publica do portal e widget.

---

## Resultado Esperado

Documentos funcionais oficiais no Drive devem refletir o mesmo fluxo tecnico,
sem transformar detalhes internos ou exemplos deste repositorio em politica
institucional sem revisao.

---

## Impacto Cruzado

- Drive: manual de atendimento da Camara.
- Drive: manual de configuracao de canais oficiais.
- Drive: politica de atendimento digital e LGPD.
- PortalModelo-SD: textos e links publicos publicados.
- SIGI-SD: configuracoes de mensagem publica e operacao dos atendentes.
- Keycloak Legislativo: papeis funcionais futuros e grupos de acesso.

---

## Criterios de Validacao

- [ ] Documento funcional criado ou atualizado no Drive.
- [ ] Canais oficiais definidos por Camara ou por modelo de implantacao.
- [ ] Textos publicos aprovados.
- [ ] Matriz de papeis revisada com seguranca/menor privilegio.
- [ ] SLA e horario de atendimento definidos.
- [ ] Regras LGPD de retencao/anexos registradas.
- [ ] Referencia cruzada para os documentos tecnicos do LegislaGD.

---

## Seguranca

Nao incluir tokens, senhas, segredos de webhook, numeros pessoais ou contas
privadas. A documentacao funcional deve orientar o uso de contas institucionais
e preservar consentimento, auditoria e minimo privilegio.

---

## Instrucoes para Agente Receptor

1. Carregar `SD-Knowledge/AGENTS.md`.
2. Carregar `skills/sertaodigital-core/SKILL.md` e
   `skills/legislagd/SKILL.md`.
3. Consultar `docs/SOURCE_OF_TRUTH.md`.
4. Localizar no Drive o documento mestre de atendimento/comunicacao do
   LegislaGD ou criar proposta no local institucional correto.
5. Atualizar a documentacao funcional conforme a mudanca necessaria.
6. Registrar versao, data e responsavel da atualizacao.
7. Retornar ao LegislaGD a referencia do documento atualizado.

---

## Fontes Consultadas

- `AGENTS.md`
- `C:/SD-Knowledge/AGENTS.md`
- `C:/SD-Knowledge/skills/sertaodigital-core/SKILL.md`
- `C:/SD-Knowledge/skills/legislagd/SKILL.md`
- `C:/SD-Knowledge/docs/PROMPT_HANDOFF_STANDARD.md`
- `docs/sigi-sd/comunicacao-unica-camara.md`

---

## Decisoes Pendentes

- [ ] Canais oficiais obrigatorios por implantacao.
- [ ] Textos oficiais por canal.
- [ ] Matriz funcional final de papeis e grupos Keycloak.
- [ ] SLA, horario de atendimento e regras de plantao.
- [ ] Retencao de anexos e dados pessoais recebidos por WhatsApp/e-mail/webchat.
