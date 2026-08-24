# Technical Decision Gate - Plenario Digital

Status: APROVADO COM PENDENCIAS  
Data: 2026-08-24  
Produto: LegislaGD / Plenario Digital  
Repositorios analisados: LegislaGD, SAPL-SD, SD-Knowledge

## 1. Contexto

O Plenario Digital deve ser uma camada operacional do plenario, configuravel por
Camara, integrada ao SAPL e sem criar uma segunda fonte de verdade do processo
legislativo. A fonte funcional MASTER no Google Drive valida que o SAPL/SAPL-SD
permanece autoridade de sessao oficial, presenca legislativa, pauta, materia,
votacao, voto, resultado, quorum e cargos exercidos na sessao.

O estado tecnico real do LegislaGD ja aponta para um modelo multirrepositorio,
local-first, nao SaaS obrigatorio e integrado por API. O Plenario Digital ja tem
infraestrutura prevista como Core independente em `plenario-core`, banco proprio
`plenario_core`, Traefik local, Keycloak Legislativo e SAPL Adapter.

## 2. Fontes consultadas

- `AGENTS.md`
- `.sdka.yaml`
- `C:\SD-Knowledge\AGENTS.md`
- `C:\SD-Knowledge\skills\sertaodigital-core\SKILL.md`
- `C:\SD-Knowledge\skills\legislagd\SKILL.md`
- `C:\SD-Knowledge\skills\legislagd\references\domain.md`
- `C:\SD-Knowledge\skills\legislagd\references\architecture.md`
- `C:\SD-Knowledge\skills\legislagd\references\identity.md`
- `C:\SD-Knowledge\skills\legislagd\references\integrations.md`
- `C:\SD-Knowledge\skills\legislagd\references\sapl.md`
- Google Drive: `PLENARIO-DIGITAL-VISAO-FUNCIONAL-E-ARQUITETURAL`, atualizado em 2026-08-24.
- `docs/plenario-digital/TECHNICAL-DECISION-GATE.md`
- `docs/plenario-digital/IMPLANTACAO-MVP.md`
- `docs/adr/ADR-001-arquitetura-multirrepositorio.md`
- `docs/adr/ADR-002-nao-saas.md`
- `docs/adr/ADR-003-integracao-por-api.md`
- `docs/adr/ADR-005-submodules-ou-clonagem.md`
- `docs/adr/ADR-007-plenario-digital-core.md`
- `docs/arquitetura/*.md`
- `docs/seguranca/*.md`
- `integrations/**/*.md`
- `infrastructure/compose/overrides/plenario.legislagd.yml`
- `infrastructure/monitoring/README.md`
- `infrastructure/logging/README.md`

## 3. Codigo analisado

No SAPL-SD:

- `sapl/sessao/models.py`
- `sapl/sessao/views.py`
- `sapl/sessao/urls.py`
- `sapl/painel/views.py`
- `sapl/painel/urls.py`
- `sapl/api/urls.py`
- `sapl/api/permissions.py`
- `sapl/api/views_health.py`
- `sapl/health.py`
- `sapl/base/oidc.py`
- `sapl/base/models.py`

No LegislaGD:

- `infrastructure/compose/overrides/plenario.legislagd.yml`
- `infrastructure/compose/docker-compose.dev.yml`
- `integrations/contracts/*.schema.json`
- `config/keycloak/realms/legislagd-realm.json`

## 4. Requisitos funcionais

Resumo da fonte funcional MASTER:

- SAPL controla processo legislativo; Plenario Digital controla experiencia operacional.
- Core nao acessa banco interno do SAPL e deve integrar por APIs/adapters.
- SAPL-SD local pode expor extensoes proprias; SAPL Interlegis remoto deve operar com capabilities menores.
- Conexao, autenticacao, dispositivo autorizado e presenca legislativa sao conceitos distintos.
- Presenca exige evento proprio, confirmacao explicita e pode ocorrer multiplas vezes por sessao.
- Rito deve ser configuravel por Casa Legislativa e tipo de sessao.
- Template de rito e instancia de rito da sessao devem ser separados para preservar historico.
- Estado institucional, estado do participante, estado de sincronizacao e estado operacional devem permanecer separados.
- Atos sensiveis podem seguir `solicitacao -> confirmacao/autorizacao -> execucao`.
- Roles tecnicas iniciais do Core: `plenario.admin`, `plenario.operador`, `plenario.parlamentar`.
- Presidente e Secretario sao cargos/perfis funcionais derivados do SAPL, nao roles permanentes do Core.
- Saude Operacional e independente da sessao legislativa e combina monitoramento passivo com diagnostico ativo.
- Diagnostico durante sessao nao pode modificar presenca, voto, fala, resultado, rito ou estado legislativo.
- MVP continua sem voto por API, sem comando legislativo por API e sem voto offline.

## 5. Arquitetura atual

O LegislaGD e agregador tecnico e de governanca. Componentes ficam em
repositorios independentes e sao integrados por contratos, APIs, eventos,
webhooks, filas ou exportacoes controladas.

O SAPL-SD local e um Django app baseado no SAPL Interlegis. Ele ja possui:

- `SessaoPlenaria` com `painel_aberto`, `iniciada`, `finalizada`, datas e anexos.
- `OrdemDia` e `ExpedienteMateria` com `tipo_votacao`, `votacao_aberta` e `registro_aberto`.
- `SessaoPlenariaPresenca` e `PresencaOrdemDia`.
- `RegistroVotacao` e `VotoParlamentar`.
- `IntegranteMesa` para cargo de mesa na sessao.
- Painel HTML em `/painel-principal/<pk>`.
- JSON de painel em `/painel/<pk>/dados`.
- Voto individual em `/voto-individual/`.
- API DRF autogerada e OpenAPI em `/api/schema/`.
- Token auth em `/api/auth/token`.
- Health/readiness em `/health/`, `/ready/` e versao.
- OIDC aditivo com PKCE, `OidcIdentity` e mapeamento de roles para grupos Django.

## 6. Gaps

- Nao ha contrato canonico estavel de Plenario Digital no SAPL-SD.
- O JSON do painel e acoplado a UI atual e nao deve virar contrato definitivo.
- Abertura/fechamento de votacao ainda ocorre por views HTML e fluxo interno.
- Nao ha endpoints idempotentes para comandos legislativos.
- Nao ha API canonica para cargo exercido em sessao, usuario/parlamentar e capabilities do provider.
- Nao ha modelo tecnico implementado para rito configuravel no Core.
- Nao ha modelo operacional implementado para multiplas chamadas de presenca.
- Nao ha subsistema de Saude Operacional, diagnostico interativo ou auditoria de diagnostico.
- Nao ha realtime proprio do Core.
- Nao ha outbox/inbox ou idempotency keys para comandos futuros.

## 7. Boundaries

Bounded context recomendado: **Plenary Operations**.

Subdominios logicos dentro do mesmo Core, sem criar microservicos no MVP:

- Session Orchestration: sessao acompanhada, rito operacional e comandos pendentes.
- Participant State: conexao, autenticacao, dispositivo e interacao.
- Operational Health: monitoramento, diagnostico, impacto e historico.
- Devices and Displays: autorizacao, perfis e visibilidade.
- Realtime and Messaging: eventos operacionais, entrega e confirmacao.
- SAPL Integration: adapters, cache, capabilities, reconciliacao e erro.

O Core nao e fonte de processo legislativo. Ele armazena estado operacional,
configuracao, cache/projecoes marcadas como derivadas e trilha operacional.

## 8. Autoridade de dados

| Conceito | Autoridade |
| --- | --- |
| Casa Legislativa oficial | SAPL / configuracao institucional |
| Sessao legislativa oficial | SAPL |
| Tipo de sessao oficial | SAPL |
| Sessao acompanhada pelo Plenario Digital | CORE |
| Template de rito operacional | CORE |
| Instancia de rito operacional da sessao | CORE, derivada da sessao SAPL |
| Pauta, materia, documento, ordem do dia | SAPL |
| Presenca legislativa oficial | SAPL |
| Chamada operacional de presenca | CORE, com resultado oficial confirmado no SAPL quando suportado |
| Quorum regimental | SAPL / DERIVADO |
| Votacao oficial | SAPL |
| Voto oficial | SAPL |
| Resultado oficial | SAPL |
| Presidente/Secretario da sessao | SAPL |
| Roles tecnicas `plenario.*` | Keycloak/Core |
| Dispositivo autorizado | CORE |
| Conexao/heartbeat/last seen | CORE |
| Diagnostico operacional | CORE |
| Display e perfil de display | CORE |
| Cache de sessao/pauta/materia | CACHE/PROJECTION |
| Evento operacional | CORE |
| Auditoria legislativa | SAPL |
| Auditoria operacional | CORE |

## 9. Maquina de estados

Nao deve haver uma unica state machine global. A decisao tecnica e usar quatro
modelos coordenados:

1. Estado institucional observado: derivado do SAPL e nunca sobrescrito pelo Core.
2. Workflow operacional da sessao: controla preparacao, solicitacoes, rito e pendencias operacionais.
3. Estado do participante/dispositivo: conexao, autenticacao, autorizacao de dispositivo, presenca operacional e interacao.
4. Estado de sincronizacao/saude: SAPL, banco, realtime, displays, latencia, erros e reconciliacao.

Macroestados funcionais como `PLANEJADA`, `PREPARACAO`, `PRONTA`,
`AGUARDANDO ABERTURA`, `ABERTURA SOLICITADA`, `SESSAO ABERTA`,
`EM ANDAMENTO`, `ENCERRAMENTO SOLICITADO`, `SESSAO ENCERRADA`,
`FINALIZACAO`, `SINCRONIZACAO` e `CONCLUIDA` devem existir como workflow
operacional do Core, referenciando a sessao SAPL. Estados excepcionais
`SUSPENSA`, `INTERROMPIDA`, `CANCELADA`, `COM PENDENCIAS` e
`FALHA OPERACIONAL` devem ser suportados sem reinterpretar atos legislativos.

## 10. Rito configuravel

Modelo recomendado:

```text
Casa Legislativa
  -> Tipo de sessao
  -> Template de rito
  -> Instancia de rito da sessao
  -> Etapas executadas / eventos / pendencias
```

O template contem etapas, ordem, nome exibido, obrigatoriedade, autoridades
responsaveis, condicoes de entrada/conclusao, repeticao e flags de habilitacao.
A instancia deve ser snapshot do template no momento de criacao/associacao da
sessao. Alterar template futuro nao altera historico.

O rito operacional do Core nao substitui a pauta nem a ordem do dia do SAPL. Ele
coordena a experiencia de plenaria, visibilidade, solicitacoes e navegacao.

## 11. Presenca

Presenca deve ser modelada como processo, nao booleano permanente:

- dispositivo conectado;
- usuario autenticado;
- dispositivo autorizado, quando exigido;
- aguardando chamada;
- chamada de presenca solicitada;
- confirmacao explicita do parlamentar;
- registro operacional da confirmacao;
- confirmacao oficial no SAPL quando a capability existir;
- reconciliacao/pendencia quando nao houver escrita segura.

Uma sessao pode ter multiplas chamadas de presenca. Cada chamada precisa ter
identificador, solicitante, horario, escopo, participantes alvo, prazo,
confirmacoes, timeouts, resultado e vinculacao com sessao SAPL.

Mecanismos futuros como PIN, NFC, passkeys, biometria do dispositivo, fotografia
ou reconhecimento exigem avaliacao propria de privacidade, seguranca,
necessidade e base juridica. O MVP nao deve armazenar biometria nem fotografia.

## 12. Autoridade

Keycloak/Core controla acesso tecnico:

- `plenario.admin`: configuracao, dispositivos, diagnostico, auditoria operacional.
- `plenario.operador`: operacao autorizada, selecao de sessao, diagnostico e solicitacoes.
- `plenario.parlamentar`: interface parlamentar e interacoes permitidas.

SAPL controla autoridade legislativa contextual:

- Presidente;
- Secretario;
- cargo na mesa;
- direito de voto;
- presenca oficial;
- quorum;
- permissoes formais do processo legislativo.

Autorizacao recomendada: RBAC tecnico no Core combinado com ABAC contextual
derivado do SAPL. Exemplo: um operador pode solicitar abertura; a execucao
legislativa sensivel depende de confirmacao do Presidente derivado do SAPL e
de capability segura de comando.

## 13. Realtime

Decisao: usar abordagem incremental e hibrida.

- MVP: polling curto/adaptativo para SAPL e Core, suficiente para health,
  descoberta de sessao, painel existente e voto individual via SAPL.
- Proximo passo: SSE do Core para displays, operador e paineis de saude,
  porque o fluxo principal e server-to-client.
- WebSocket: reservar para interacao bidirecional intensa, diagnostico
  interativo em larga escala ou baixa latencia comprovadamente necessaria.
- Broker/filas: introduzir quando houver fan-out, comandos assincronos,
  outbox ou processamento de diagnostico em volume.

Nao adotar WebSocket por padrao antes de medir necessidade e complexidade
operacional no ambiente municipal.

## 14. Eventos

Usar eventos operacionais internos e auditaveis. Nao adotar Event Sourcing como
modelo principal neste momento.

Motivo: o dominio precisa de auditoria e rastreabilidade, mas a fonte
legislativa oficial permanece no SAPL. Event Sourcing completo aumentaria
complexidade sem resolver a autoridade do voto, presenca oficial ou resultado.

Modelo recomendado:

- tabelas transacionais para estado operacional atual;
- event log operacional append-only para auditoria;
- outbox para comandos/eventos que precisam sair do Core;
- inbox/deduplicacao para eventos recebidos do SAPL quando houver;
- idempotency keys para comandos sensiveis.

Eventos uteis: `SessionSelected`, `AttendanceRequested`,
`AttendanceConfirmed`, `VotingOpenRequested`, `DiagnosticRequested`,
`DiagnosticDelivered`, `DiagnosticConfirmed`, `DeviceDisconnected`,
`IntegrationUnavailable`, `SyncCompleted`.

## 15. Saude Operacional

Saude Operacional e bounded area propria do Core, independente da sessao
legislativa.

Componentes minimos:

- Core app;
- banco do Core;
- rede local;
- Internet quando necessaria;
- SAPL/SAPL-SD;
- autenticacao/Keycloak;
- realtime;
- displays;
- terminais parlamentares;
- Presidencia;
- Secretaria;
- Operacao;
- sincronizacao de horario;
- filas/cache se forem introduzidos.

Diagnostico deve combinar:

- monitoramento passivo: heartbeat, last seen, latencia, reconexoes, erros.
- teste ativo: geral, por componente, por usuario, por dispositivo.
- teste interativo: conectado, mensagem entregue, usuario confirmou visualizacao.

Durante sessao, diagnostico nao altera estado legislativo. Em votacao, priorizar
teste individual e evitar substituir a tela de voto ou acao confundivel com
voto.

Classificacao recomendada:

- origem provavel: `DISPOSITIVO`, `REDE_LOCAL`, `INTERNET`, `CORE`, `BANCO`,
  `SAPL`, `AUTENTICACAO`, `REALTIME`, `DISPLAY`, `INDETERMINADO`.
- resultado: `SAUDAVEL`, `DEGRADADO`, `FALHA_PARCIAL`, `FALHA_CRITICA`,
  `INCONCLUSIVO`.

## 16. Persistencia

Pertencem ao Core:

- providers e capabilities;
- plenarios;
- displays e perfis;
- dispositivos e credenciais complementares nao secretas;
- autorizacoes, revogacoes e validade de dispositivo;
- conexoes, heartbeat e last seen;
- sessao acompanhada operacionalmente;
- templates e instancias de rito operacional;
- chamadas de presenca operacionais;
- diagnosticos, mensagens, confirmacoes, timeouts e resultados;
- cache/projecoes derivadas do SAPL com origem, timestamp e TTL;
- eventos e auditoria operacional;
- idempotency keys e outbox/inbox futuros.

Nao pertencem ao Core como autoridade:

- cadastro oficial de parlamentar;
- sessao legislativa;
- presenca legislativa oficial;
- pauta, materia, documentos, ordem do dia;
- votacao, voto e resultado;
- quorum;
- cargo legislativo exercido.

## 17. Integracao SAPL

Contrato canonico inicial do SAPL Adapter:

| Metodo | Categoria | Observacao |
| --- | --- | --- |
| `get_health()` | leitura | Usa `/health/`, `/ready/`, versao. |
| `get_capabilities()` | leitura | Necessario no SAPL-SD; inferido no remoto. |
| `get_current_session_candidates()` | leitura | Nao seleciona silenciosamente em ambiguidade. |
| `get_session(session_id)` | leitura | Dados oficiais basicos. |
| `get_panel_state(session_id)` | leitura | MVP pode usar `/painel/<pk>/dados`; contrato canonico futuro. |
| `get_attendance(session_id)` | leitura | Presenca oficial quando disponivel. |
| `get_rite_context(session_id)` | leitura | Tipo de sessao, pauta e etapa observada. |
| `get_matter_context(session_id)` | leitura | Materia atual, documentos e votacao. |
| `get_role_context(session_id, user)` | leitura | Presidente/Secretario/cargo/votante por SAPL. |
| `build_panel_url(session_id)` | launcher | `/painel-principal/<pk>`. |
| `build_vote_url()` | launcher | `/voto-individual/`. |
| `request_attendance_write(...)` | escrita futura | Somente com endpoint seguro. |
| `open_voting(...)` | escrita futura | Exige ADR e endpoint idempotente. |
| `close_voting(...)` | escrita futura | Exige ADR e endpoint idempotente. |
| `submit_vote(...)` | escrita futura | Fora do MVP. |

Capabilities devem habilitar/desabilitar UI. SAPL Interlegis remoto deve ser
tratado como provider de capacidade reduzida.

## 18. Resiliencia

Politicas por categoria:

- Display visual: cache curto, fallback visual e degradacao aceitavel.
- Pauta/materias/documentos: cache de leitura com TTL e origem.
- Presenca oficial: sem escrita offline; pendencia operacional ate confirmacao SAPL.
- Voto oficial: sem offline; bloquear ou redirecionar para SAPL conforme capability.
- Comandos sensiveis: idempotency key, timeout, retry controlado, confirmacao SAPL.
- Diagnostico: pode continuar localmente sem SAPL, marcando SAPL indisponivel.

Cenarios:

- `LOCAL_COMPLETO`: sem Internet, opera se SAPL-SD, Core, banco, Keycloak e rede local estiverem disponiveis.
- `REMOTO_COM_CACHE`: sem Internet/SAPL remoto, leitura visual pode usar cache; escrita oficial bloqueada.
- `REMOTO_SEM_CONTINGENCIA`: recursos dependentes do SAPL remoto indisponiveis.
- `HIBRIDO`: reservado, exige decisao especifica.

Banco local indisponivel torna o Core nao pronto. Sessao legislativa no SAPL
pode continuar por telas SAPL se o SAPL estiver operacional.

## 19. Seguranca

Threat model minimo:

| Ameaca | Controle |
| --- | --- |
| Spoofing de dispositivo | Credencial de dispositivo assinada, rotacionavel, hash no Core, revogacao. |
| Hijacking de sessao | HTTPS, cookies seguros, OIDC/PKCE, timeout e revalidacao. |
| Replay de comando | Idempotency key, nonce, timestamp, usuario, device id e correlation id. |
| CSRF | Sem comandos por GET; CSRF/session correto ou bearer M2M. |
| XSS | Escape em templates, CSP futura, sanitizacao de mensagens operacionais. |
| Voto indevido | SAPL valida votante, presenca e permissao; Core nao aceita parlamentar por parametro livre. |
| Presenca falsa | Confirmacao explicita e registro auditavel; escrita oficial so com capability. |
| Diagnostico intrusivo | Politica por fase da sessao; sem alterar voto/presenca/fala/rito. |
| Painel publico vazando dado | Niveis de visibilidade e respeito a configuracao SAPL `mostrar_voto`. |
| Token/secret em logs | Redacao, logs estruturados e secrets por ambiente. |
| Biometria/foto | Nao armazenar sem avaliacao juridica, necessidade e seguranca. |

Menor privilegio:

- usuario tecnico SAPL com permissoes estritamente necessarias;
- M2M OIDC quando disponivel;
- leitura publica somente quando o SAPL ja classifica como publica;
- segregacao entre administrador, operador e parlamentar.

## 20. Observabilidade

Metricas:

- disponibilidade e latencia do Core, banco, SAPL, Keycloak, realtime;
- heartbeats e last seen por dispositivo/display;
- reconexoes e perda de conexao;
- tempo de entrega/confirmacao de diagnostico;
- falhas de sync, retries e circuit breaker;
- contagem de comandos solicitados, confirmados, negados, expirados.

Logs:

- estruturados com correlation id;
- usuario, dispositivo, sessao, acao, resultado e erro;
- sem tokens, votos sensiveis ou dados pessoais desnecessarios.

Eventos:

- eventos operacionais auditaveis;
- diagnosticos e confirmacoes;
- mudancas de estado de dispositivo;
- indisponibilidade de integracao.

Alertas:

- SAPL indisponivel durante sessao;
- banco Core indisponivel;
- falha critica de realtime;
- display critico sem confirmacao;
- perda coletiva de terminais.

## 21. ADRs necessarios

Criado neste Gate:

- `docs/adr/ADR-008-plenario-digital-state-rito-saude-operacional.md`

Ja existente e mantido:

- `docs/adr/ADR-007-plenario-digital-core.md`

ADRs futuros antes de implementacao especifica:

- comandos legislativos por API no SAPL-SD;
- voto por API;
- contingencia/offline de voto, se algum dia for cogitada;
- realtime WebSocket/broker, se SSE/polling nao atender;
- uso de biometria/fotografia/NFC como fator forte.

## 22. Plano de implementacao

Incrementos recomendados:

1. Health, capabilities e painel operacional do Core.
2. Dispositivos, displays, heartbeat, last seen e autorizacao basica.
3. Saude Operacional e diagnostico ativo/interativo sem interferencia legislativa.
4. Presenca operacional com multiplas chamadas e reconciliacao com SAPL quando houver capability.
5. Rito configuravel: templates, snapshot de instancia e workflow operacional.
6. Fala, inscricoes, cronometros e estado visual proprio do display.
7. Materias/documentos por adapter e cache/projecoes.
8. Votacao integrada: primeiro launcher SAPL; comandos API somente apos ADR e endpoint seguro.
9. Resiliencia avancada, outbox/inbox, alertas e reconciliacao.

Primeiro incremento implementavel: health + capabilities + painel operacional,
porque reduz risco, valida conectividade real e nao toca voto, presenca ou estado
legislativo.

## 23. Testes

Estrategia:

- testes unitarios do SAPL Adapter com providers fake;
- testes de contrato para payload canonico;
- testes de permissao para `plenario.admin`, `plenario.operador`, `plenario.parlamentar`;
- testes de workflow de rito com snapshot imutavel;
- testes de multiplas chamadas de presenca;
- testes de idempotencia e deduplicacao para comandos futuros;
- testes de diagnostico: entregue, confirmado, timeout e falha;
- testes de degradacao: SAPL off, Internet off, banco off, dispositivo off;
- testes de seguranca: CSRF, XSS em mensagens, replay, spoofing de dispositivo;
- testes end-to-end locais com SAPL-SD via Traefik.

## 24. Impactos externos

SAPL-SD:

- precisa de endpoints canonicos de capabilities, sessao corrente/candidatas,
  estado de plenario, contexto de cargo e eventualmente comandos idempotentes.
- qualquer escrita legislativa por API exige PR separado e ADR proprio.

SD-Knowledge:

- sem mudanca obrigatoria de Skill neste momento.
- se `Plenary Operations` virar padrao reutilizavel para outros produtos,
  propor PR separado no SD-Knowledge.

Google Drive:

- fonte funcional MASTER ja validou presenca, rito e saude operacional para piloto.
- nao ha divergencia funcional a devolver agora.
- futuras decisoes sobre voto por API, biometria/foto, NFC forte ou offline
  exigem validacao funcional/juridica.

## 25. Cross-Layer Impact Check

Tecnico especifico do LegislaGD:

- documentado neste Gate e no ADR-008.
- implementar no Core como dominio operacional proprio.

Tecnico especifico do SAPL-SD:

- handoff tecnico futuro para endpoints `/api/sd/plenario/...`.
- nao alterar SAPL-SD automaticamente nesta execucao.

Tecnico transversal:

- sem atualizacao obrigatoria no SD-Knowledge agora.

Funcional/institucional:

- Drive permanece MASTER.
- nenhuma regra funcional foi alterada por este Gate.
- pendencias futuras: voto por API, voto offline, biometria/fotografia/NFC forte,
  comandos legislativos oficiais e politicas regimentais especificas por Casa.

## Respostas objetivas

1. Bounded context: `Plenary Operations`.
2. Onde roda: Core independente local-first, modulo/componente do LegislaGD, com banco proprio e adapter SAPL.
3. Autoridade: SAPL para legislativo; Core para operacional; Keycloak/Core para roles tecnicas; cache como derivado.
4. Sessao tecnica: referencia a sessao SAPL + workflow operacional proprio + cache/projecao.
5. State machines/workflows: quatro dimensoes coordenadas, nao uma maquina unica.
6. Rito: template por Casa/tipo de sessao e instancia snapshot por sessao.
7. Presenca: processo com chamadas multiplas, confirmacao explicita e SAPL como autoridade oficial.
8. Presidente/Secretario: derivados do SAPL, nao roles permanentes do Core.
9. Dispositivos: credencial criptografica/assinada e estado no Core; nao MAC address como identidade primaria.
10. Realtime: polling no MVP, SSE depois, WebSocket apenas se comprovado.
11. Diagnostico: monitoramento passivo + teste ativo + confirmacao interativa.
12. Health: app, banco, SAPL, Keycloak, realtime, rede, displays, terminais e horario.
13. Parlamentar desconecta: afeta estado operacional/last seen; nao remove presenca ou voto oficial.
14. SAPL cai: leitura pode degradar/cachear; escrita legislativa bloqueada; diagnostico registra impacto.
15. Internet cai: `LOCAL_COMPLETO` continua local; SAPL remoto fica indisponivel.
16. Banco local cai: Core fica nao pronto; SAPL pode seguir se independente.
17. Falha individual x critica: classificar origem, escopo e impacto operacional.
18. Auditoria: Core audita operacional; SAPL audita legislativo; correlacao por ids.
19. Event Sourcing: nao e necessario agora.
20. Persistencia: estado operacional, configuracao, cache derivado, eventos e diagnostico.
21. Duplicidade: idempotency keys, correlation id, deduplicacao e confirmacao SAPL.
22. Retry: backoff controlado por categoria; nunca retry cego de voto/comando sensivel.
23. Reconciliacao: comparar estado Core derivado com SAPL e marcar pendencias sem sobrescrever SAPL.
24. Interlegis: provider por capabilities e extensoes apenas no SAPL-SD local.
25. SAPL-SD: endpoints canonicos e comandos futuros, em PR separado.
26. Upstream: panel-state, current-session, capabilities e OpenAPI podem ser candidatos.
27. SD-Knowledge: documentar depois se virar padrao transversal.
28. Primeiro incremento: health + capabilities + painel operacional.

## Decisao final

Gate: **APROVADO COM PENDENCIAS**.

Pendente nao bloqueante:

- contratos canonicos `/api/sd/plenario/...`;
- endpoint seguro para cargos/contexto de sessao;
- decisao futura para comandos legislativos por API;
- decisao futura para voto por API;
- decisao futura para realtime WebSocket/broker se necessario;
- validacao funcional/juridica antes de biometria, fotografia, NFC forte ou voto offline.
