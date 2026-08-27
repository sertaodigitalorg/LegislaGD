# Comunicacao unica da Camara

Este documento registra o desenho tecnico local para operar atendimento e
comunicacao institucional em um fluxo unico no LegislaGD.

## Objetivo

Centralizar entradas publicas da Camara em uma fila unica de atendimento, com
protocolo SIGI-SD, rastreabilidade e canais oficiais configurados. O Chatwoot
opera as conversas; o SIGI-SD consolida cadastros, protocolos, historico,
auditoria e integracoes.

## Componentes

| Componente | Responsabilidade |
| --- | --- |
| PortalModelo-SD | Expor canais publicos, links, formularios e widget de atendimento. |
| Chatwoot | Receber e operar e-mail, WhatsApp, webchat e outros inboxes oficiais. |
| SIGI-SD | Importar conversas, gerar protocolo, vincular pessoa/organizacao e manter historico. |
| Keycloak Legislativo | Centralizar identidade e niveis de acesso administrativo. |
| SAPL-SD/e-Cidade-SD | Receber encaminhamentos quando houver demanda legislativa ou administrativa. |

## Fluxo padrao

1. O cidadao acessa um canal oficial publicado no PortalModelo-SD.
2. O Chatwoot recebe a conversa pelo inbox configurado.
3. O webhook do Chatwoot envia o evento para o SIGI-SD.
4. O SIGI-SD normaliza canal, contato, etiquetas, responsavel e prioridade.
5. O SIGI-SD cria ou reaproveita o protocolo vinculado a conversa Chatwoot.
6. A equipe acompanha a fila em `Protocolos e Conversas`.
7. Quando aplicavel, o atendimento e encaminhado para SAPL-SD ou e-Cidade-SD por contrato.

## Canais oficiais

Os canais aceitos tecnicamente neste primeiro desenho sao:

| Canal | Entrada esperada | Observacao |
| --- | --- | --- |
| E-mail | Inbox de e-mail no Chatwoot | Deve usar conta institucional da Camara. |
| WhatsApp | Inbox WhatsApp/Meta no Chatwoot | Deve preservar consentimento e historico operacional. |
| Webchat | Widget Chatwoot no PortalModelo-SD | Deve exibir origem publica do portal. |
| Instagram | Inbox Instagram no Chatwoot | Opcional, quando a Camara operar esse canal oficialmente. |

Qualquer canal pessoal de servidor, vereador ou fornecedor nao deve ser tratado
como canal oficial da Camara sem decisao funcional registrada.

## Configuracoes gerais

Configuracoes operacionais ficam em SIGI-SD:

- `Configuracao do Atendimento Unico`: escopo do sequencial de protocolo e
  mensagem publica enviada ao cidadao.
- `Canais Oficiais da Camara`: contas Chatwoot, URL base, conta, inbox, token de
  API e segredo de webhook.
- Variaveis de ambiente: URLs publicas/internas do Chatwoot e SIGI, conta,
  inbox e tokens sem exposicao em repositorio.

Segredos reais devem ficar somente no ambiente de deploy. `.env.example` pode
documentar nomes de variaveis, nunca valores produtivos.

## Importacoes

As importacoes vindas do Chatwoot devem seguir comportamento idempotente:

- uma conversa Chatwoot gera no maximo um protocolo SIGI ativo;
- novos eventos da mesma conversa atualizam historico, status, agente, equipe,
  etiquetas e mensagem mais recente;
- etiquetas de origem devem diferenciar `email`, `whatsapp`, `webchat`,
  `instagram` ou `unknown`;
- falha ao aplicar etiqueta ou enviar mensagem publica nao deve duplicar
  protocolo;
- payload bruto deve ficar acessivel apenas para operador autorizado ou modo de
  diagnostico.

## Organizacoes

Organizacoes representam Camaras, setores, gabinetes, fornecedores,
instituicoes parceiras e unidades externas envolvidas no atendimento. O cadastro
deve preservar:

- hierarquia institucional por organizacao pai;
- tipo de organizacao;
- status operacional;
- contatos institucionais por canal;
- vinculos de pessoas com papeis e vigencia.

Esse cadastro nao substitui a fonte funcional oficial da instituicao quando
houver documento mestre no Google Drive; ele modela a operacao tecnica local.

## Niveis de acesso

O estado atual do SIGI-SD usa `ROLE_USER` e `ROLE_ADMIN`.

| Nivel tecnico atual | Uso no SIGI-SD | Observacao |
| --- | --- | --- |
| `ROLE_USER` | Usuario autenticado basico | Base para acesso autenticado. |
| `ROLE_ADMIN` | Administracao, protocolos, canais e configuracoes | Herda `ROLE_USER`. |

Mapa funcional recomendado para validacao posterior:

| Papel funcional | Nivel minimo sugerido | Escopo |
| --- | --- | --- |
| Atendente | `ROLE_USER` com permissao operacional futura | Ver e responder atendimentos atribuidos. |
| Supervisor | Papel especifico futuro | Ver fila, SLA, etiquetas, redistribuicao e relatorios. |
| Administrador de canais | `ROLE_ADMIN` ou papel especifico futuro | Configurar contas Chatwoot e webhooks. |
| Administrador geral | `ROLE_ADMIN` | Configuracoes gerais e usuarios. |

A criacao de novos papeis tecnicos exige decisao funcional e migracao propria.
Este documento registra a necessidade, sem alterar permissao em runtime.

## Teste visual

Checklist minimo para homologar a parte publica e a operacao administrativa:

| Area | Verificacao |
| --- | --- |
| PortalModelo-SD publico | Links de e-mail, WhatsApp e webchat visiveis e sem sobreposicao em desktop e mobile. |
| Widget Chatwoot | Carrega no portal, abre conversa e identifica origem do atendimento. |
| SIGI-SD protocolos | Tabela de `Protocolos e Conversas` cabe em desktop, permite rolagem horizontal e filtros nao quebram em mobile. |
| Canais oficiais | Tela de contas mostra status, webhook, sincronizacao e acoes sem quebrar layout. |
| Configuracao | Campo da mensagem publica comporta texto longo e variaveis suportadas. |

Quando a stack local estiver ativa, validar com navegador em:

- `http://portal.legislagd.localhost`
- `http://sigi.legislagd.localhost`
- `http://chatwoot.legislagd.localhost`

## Pendencias funcionais

As definicoes abaixo dependem de fonte funcional autorizada:

- texto oficial de saudacao e encerramento por canal;
- horario de atendimento e politica de SLA;
- quais canais sao oficialmente publicados por cada Camara;
- matriz definitiva de papeis alem de `ROLE_USER` e `ROLE_ADMIN`;
- regras de retencao e descarte de anexos recebidos por canais externos.

Sem acesso direto ao Google Drive institucional nesta atividade, essas pendencias
devem ser sincronizadas por Prompt Handoff antes de virarem regra funcional.
