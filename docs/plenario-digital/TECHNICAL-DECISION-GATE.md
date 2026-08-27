# Plenario Digital - Technical Decision Gate

Status: Proposed  
Data: 2026-08-23  
Projeto: LegislaGD / SAPL-SD  
Feature: Plenario Digital

## Resumo executivo

Arquitetura recomendada: implementar o Plenario Digital como uma aplicacao Django independente, operada pelo LegislaGD, com banco proprio e deploy local-first. O Core deve se integrar ao SAPL por contrato canonico e adapters, preferindo API HTTP. No piloto, o adapter SAPL-SD pode usar endpoints existentes e launchers para telas ja existentes do SAPL. Acesso direto ao banco do SAPL nao deve ser usado.

O que reutilizar do SAPL: painel principal existente (`/painel-principal/<sessao>`), endpoint JSON do painel (`/painel/<sessao>/dados`), voto individual (`/voto-individual/`), abertura de votacao nas views de sessao, modelos e APIs DRF existentes para sessoes, parlamentares, materias, documentos, presenca e votacoes.

O que implementar no Core: configuracao de providers, health/conectividade, descoberta de sessao atual, launcher do painel e voto individual, cadastro de plenario/display/dispositivo, autorizacao de dispositivo, prontidao tecnologica, preferencias de apresentacao, mensagens operacionais e capabilities por provider.

O que alterar no SAPL-SD: somente extensoes API nao intrusivas quando o SAPL nao expuser operacoes necessarias de forma adequada. Candidatas iniciais: estado canonico do plenario, sessao corrente, voto/painel em payload estavel, capabilities, endpoints de comando para abrir/fechar votacao e registrar voto com semantica idempotente e auditavel.

O que propor ao upstream: endpoints genericos de painel/plenario em API publica/autenticada, payload estavel para estado de sessao, capabilities e melhorias de documentacao OpenAPI. Mudancas especificas de dispositivos, prontidao tecnologica e operacao multi-display ficam no Core, nao no upstream.

MVP implementavel: iniciar sem substituir o painel ou o voto individual. Entregar provider SAPL, health check, descoberta de sessao, launchers, estrutura do Core, prontidao tecnologica e gerenciamento inicial de dispositivos. Nao implementar voto offline nem reescrever painel nesta etapa.

Riscos principais: consistencia de voto, autorizacao indevida, replay, concorrencia, dependencia de telas HTML existentes, fragilidade do JSON atual do painel como API, diferencas entre SAPL-SD e SAPL Interlegis remoto, e maturidade do SSO/OIDC entre Core e SAPL.

Decisoes tecnicas ainda pendentes: contrato canonico definitivo, escopo exato dos endpoints `/api/sd/plenario/...`, politica tecnica de device credential, autenticacao M2M definitiva, suporte a escrita contra SAPL Interlegis remoto, comandos legislativos por API, voto por API e qualquer contingencia com voto offline.

## Fontes consultadas

- `AGENTS.md` do LegislaGD.
- `.sdka.yaml`.
- `C:\SD-Knowledge\AGENTS.md`.
- `C:\SD-Knowledge\skills\sertaodigital-core\SKILL.md`.
- `C:\SD-Knowledge\skills\legislagd\SKILL.md`.
- `C:\SD-Knowledge\skills\legislagd\references\architecture.md`.
- `C:\SD-Knowledge\skills\legislagd\references\integrations.md`.
- `C:\SD-Knowledge\skills\legislagd\references\sapl.md`.
- `C:\SD-Knowledge\skills\legislagd\references\identity.md`.
- `README.md`, `SECURITY.md`, `docs/`, `infrastructure/` do LegislaGD.
- ADRs locais: `ADR-001`, `ADR-002`, `ADR-003`, `ADR-005`, `ADR-006`.
- SAPL-SD local em `modules/SAPL-SD`, branch `dev`, com `origin` Sertao Digital e `upstream` Interlegis configurados.
- Codigo SAPL-SD: `sapl/painel`, `sapl/sessao`, `sapl/api`, `sapl/base/oidc.py`, `sapl/settings.py`, `drfautoapi`.
- Validacao funcional concluida no Google Drive em 2026-08-23.

## Validacao funcional de 2026-08-23

A validacao funcional concluida no Google Drive em 2026-08-23 confirma as seguintes premissas para o piloto:

- Perfis iniciais: Administrador, Operador, Presidente, Secretario e Vereador.
- Prontidao tecnologica e separada de presenca legislativa e quorum.
- Politica de dispositivos deve ser configuravel.
- Estados de dispositivo: `PENDENTE`, `AUTORIZADO`, `BLOQUEADO`, `REVOGADO`, `EXPIRADO`.
- SAPL e autoridade do voto.
- Core nao armazena voto como dado autoritativo.
- MVP usa `/voto-individual/` existente.
- Nao ha voto offline no MVP.
- Niveis de mensagens: `PUBLICO_DISPLAY`, `PARLAMENTAR`, `OPERACIONAL`, `ADMINISTRATIVO`.
- Cenarios de contingencia: `LOCAL_COMPLETO`, `REMOTO_COM_CACHE`, `REMOTO_SEM_CONTINGENCIA`.
- `HIBRIDO` fica reservado para evolucao futura.

## Estado atual observado

O LegislaGD e um agregador multirrepositorio com infraestrutura local integrada. Os componentes ficam independentes, com historico e ciclo proprios. A decisao vigente de integracao por API ja existe em `docs/adr/ADR-003-integracao-por-api.md` e rejeita acesso direto irrestrito aos bancos internos como estrategia de integracao.

A infraestrutura local usa Traefik, PostgreSQL central com bases separadas por componente e Keycloak Legislativo planejado/implementado de forma incremental. O override do SAPL-SD ja configura host `sapl.legislagd.localhost`, banco separado `sapl_sd` e variaveis `SAPL_OIDC_*`.

O SAPL-SD observado usa Django, Django REST Framework, PostgreSQL, frontend Vue 2/Webpack, Bootstrap/jQuery e autenticacao DRF por TokenAuthentication e SessionAuthentication. A versao informada no settings e `3.1.165-RC2`.

O SAPL-SD ja possui piloto OIDC aditivo para Keycloak: rotas `/auth/legislagd/login/` e `/auth/legislagd/callback/`, PKCE, validacao de ID token, `OidcIdentity` com `provider` e `subject`, criacao/vinculacao de usuario local e mapeamento de roles para grupos Django. O login local permanece para contingencia.

## Analise do codigo SAPL

### Painel

`sapl/painel/urls.py` expoe:

| Rota | Uso observado |
| --- | --- |
| `/painel-principal/<pk>` | Renderiza o painel principal da sessao. |
| `/painel/<pk>/dados` | Retorna JSON para o painel. |
| `/painel/switch-painel` | Alterna `SessaoPlenaria.painel_aberto`. |
| `/painel/verifica-painel` | Consulta se o painel esta aberto. |
| `/painel/cronometro` | Atualiza estado de cronometro na sessao web. |
| `/voto-individual/` | Tela de voto do parlamentar autenticado. |

`sapl/painel/views.py` ja monta dados uteis para display: sessao, data/hora, solene/finalizada, brasao, status do painel, cronometros, materia atual, ementa, tipo de votacao, resultado, presentes, votos e oradores. A view prioriza materia com votacao aberta na Ordem do Dia e depois no Expediente. Se nao houver materia aberta, exibe a ultima votada/lida.

O endpoint `/painel/<pk>/dados` e util para o MVP, mas nao deve ser tratado como contrato canonico definitivo: ele e acoplado ao painel atual, usa nomes e formatos voltados a UI, depende de permissao de modulo e inclui detalhes que podem mudar com o template.

### Voto individual

`/voto-individual/` exige login, permissao `parlamentares.can_vote` e vinculo `Votante` entre `auth.User` e `Parlamentar`. A view localiza uma unica votacao aberta, valida presenca legislativa e registra/atualiza `VotoParlamentar` para Ordem do Dia ou Expediente.

Isso confirma o principio de autoridade: o voto oficial ou pre-registro de voto parlamentar pertence ao SAPL. O Core nao deve persistir voto como autoridade. Para o MVP, o Core deve apenas lancar/encaminhar o usuario para o voto individual existente.

### Sessao, presenca e votacao

`SessaoPlenaria` contem `painel_aberto`, `iniciada`, `finalizada`, data/hora e demais dados oficiais da sessao. A pauta/votacao usa `OrdemDia` e `ExpedienteMateria`, ambos com `tipo_votacao`, `votacao_aberta`, `registro_aberto`, resultado e materia vinculada.

Presenca legislativa esta em `SessaoPlenariaPresenca` e `PresencaOrdemDia`. Resultado consolidado esta em `RegistroVotacao`. Votos individuais estao em `VotoParlamentar`, com `user`, `ip` e `data_hora`.

### API existente

`sapl/api/urls.py` monta OpenAPI via drf-spectacular, usa um router DRF autogerado e publica token auth em `/api/auth/token`. O `drfautoapi` registra rotas no padrao `/<app_label>/<model_name>`, por exemplo `api/sessao/sessaoplenaria`, `api/parlamentares/parlamentar`, `api/painel/painel`, conforme apps construidas.

A API usa `SaplModelPermissions`, que permite leitura publica quando a matriz de regras marca o modelo como publico e exige permissoes Django para escrita. Existem endpoints de health/readiness em `/health/`, `/ready/` e versao em `/version/`.

### Abertura e encerramento de votacao

As views de `sapl/sessao` ja contem rotas e logica para abrir votacao, votacao nominal/simbolica/secreta, leitura, presenca e ordem do dia. Para operacao pelo Plenario Digital, nao basta chamar telas HTML: sera necessario criar endpoints de comando explicitamente desenhados, idempotentes, autenticados e auditaveis, ou confirmar que a API autogerada atende com seguranca.

## Alternativas avaliadas

### A. Modulo dentro do SAPL

Vantagens: menor latencia, acesso direto aos modelos e permissoes SAPL, reuso imediato de templates, menor superficie de deploy.

Desvantagens: aumenta divergencia do fork, dificulta operar contra SAPL Interlegis remoto, incentiva acoplamento por modelo/banco e torna o Plenario Digital dependente do ciclo do SAPL.

Conclusao: rejeitar como arquitetura principal. Pode haver extensoes pequenas no SAPL-SD para API quando necessario.

### B. Aplicacao Django independente

Vantagens: mesma linguagem e padroes operacionais do SAPL-SD, menor complexidade de instalacao, deploy independente, banco proprio, facil integracao com Keycloak, compatibilidade local-first e melhor isolamento de dominio.

Desvantagens: exige adapter e contratos; precisa lidar com autenticacao M2M e diferencas de providers.

Conclusao: recomendar.

### C. Servico independente em outra stack

Vantagens: liberdade tecnica e frontend/backend desacoplados.

Desvantagens: adiciona runtime, manutencao, dependencias e superficie operacional sem beneficio concreto neste momento.

Conclusao: nao recomendado para o MVP.

### D. Combinacao

Core independente + extensoes API pequenas no SAPL-SD + reuso inicial de telas SAPL.

Conclusao: recomendada.

## Decisoes tecnicas propostas

### 1. Forma do Plenario Digital

Usar combinacao:

- Core como aplicacao Django independente, em repositorio/componente proprio ou modulo independente governado pelo LegislaGD.
- SAPL Adapter no Core.
- Extensoes SAPL-SD somente quando API existente nao atender.
- Reuso inicial das telas SAPL para painel e voto.

### 2. Stack

Backend: Python/Django.  
Banco: PostgreSQL proprio do Core.  
Frontend inicial: Django templates ou frontend leve integrado, evitando SPA complexa no MVP.  
Tempo real: polling no MVP, SSE como proximo passo, WebSocket apenas se necessidade concreta aparecer.  
Infra: Docker Compose, Traefik, Keycloak Legislativo, banco separado no PostgreSQL central local.

Essa stack segue a base do SAPL-SD e do LegislaGD, reduzindo complexidade operacional.

### 3. Banco proprio do Core

Sim. O Core precisa persistir dados operacionais proprios:

- casas/instancias/provedores configurados;
- plenarios;
- displays e perfis de display;
- dispositivos;
- estado de autorizacao de dispositivo;
- credenciais complementares e metadados nao secretos;
- sessoes de conexao tecnologica;
- prontidao tecnologica;
- preferencias de apresentacao;
- mensagens e visibilidade;
- cache de leitura de provider, com validade e origem;
- capabilities detectadas por provider;
- logs/auditoria operacional do Core.

### 4. Dados que o Core nao deve persistir como autoridade

- sessao legislativa;
- abertura/encerramento oficial de sessao;
- parlamentares como cadastro oficial;
- presenca legislativa oficial;
- pauta e ordem do dia;
- materia/proposicao/documentos/tramitacao;
- votacao oficial;
- voto registrado;
- resultado oficial;
- regras formais do processo legislativo.

O Core pode armazenar cache e snapshots de leitura, sempre marcados como derivados, com timestamp, provider e TTL.

### 5. SAPL Adapter

Contrato canonico inicial sugerido:

| Metodo | Responsabilidade |
| --- | --- |
| `get_health()` | Conectividade e versao/capacidade minima. |
| `get_capabilities()` | Informa leitura/escrita, endpoints disponiveis e limitacoes. |
| `get_current_session()` | Descobre sessao corrente/ativa/candidata. |
| `get_session(session_id)` | Dados basicos oficiais da sessao. |
| `get_panel_state(session_id)` | Estado consolidado para display. |
| `get_attendance(session_id)` | Presenca legislativa oficial. |
| `get_current_matter(session_id)` | Materia aberta ou em foco. |
| `get_documents(session_id)` | Documentos/pauta/ata/anexos. |
| `get_voting(session_id)` | Estado de votacao aberta. |
| `get_voting_result(session_id, item_id)` | Resultado oficial/consolidado. |
| `get_speakers(session_id)` | Oradores. |
| `build_panel_url(session_id)` | URL para painel SAPL existente. |
| `build_vote_url()` | URL para voto individual SAPL existente. |
| `open_voting(...)` | Futuro comando, se provider suportar escrita segura. |
| `close_voting(...)` | Futuro comando, se provider suportar escrita segura. |
| `submit_vote(...)` | Futuro comando, se provider suportar escrita segura. |

Providers:

- `sapl_interlegis`: consome API upstream e launchers/telas quando disponiveis; inicialmente leitura e launchers.
- `sapl_sd`: consome API upstream compativel e extensoes `/api/sd/plenario/...` quando necessarias.

### 6. Capabilities

Capabilities devem ser dinamicas por provider/instancia, por exemplo:

- `read.health`
- `read.session`
- `read.panel_state`
- `read.attendance`
- `read.voting`
- `read.results`
- `launch.panel`
- `launch.vote`
- `write.open_voting`
- `write.close_voting`
- `write.submit_vote`
- `realtime.polling`
- `realtime.sse`
- `auth.oidc`
- `auth.token`

O Core deve desabilitar UI de comando quando a capability nao existir.

## APIs existentes que atendem ao MVP

| Necessidade MVP | Reuso inicial |
| --- | --- |
| Health/conectividade | `/health/`, `/ready/`, `/version/`. |
| Token API | `/api/auth/token`, com HTTPS obrigatorio em producao. |
| OpenAPI | `/api/schema/`, `/api/schema/swagger-ui/`, `/api/schema/redoc/`. |
| Sessao por API | Rotas DRF autogeradas de `sessao/sessaoplenaria`; endpoint legado `/api/sessao-plenaria`. |
| Parlamentares | Rotas DRF autogeradas de `parlamentares/parlamentar`. |
| Presenca | Rotas DRF autogeradas de `sessao/sessaoplenariapresenca` e `sessao/presencaordemdia`, mediante permissoes. |
| Materias da sessao | Rotas DRF autogeradas de `sessao/ordemdia` e `sessao/expedientemateria`. |
| Votacao/resultado | Rotas DRF autogeradas de `sessao/registrovotacao` e `sessao/votoparlamentar`, mediante permissoes. |
| Painel atual | `/painel-principal/<sessao>` e `/painel/<sessao>/dados`. |
| Voto individual | `/voto-individual/`. |

## Dados atuais do painel que podem ser reutilizados

- identificacao da sessao;
- data e hora;
- sessao solene/finalizada;
- status do painel;
- brasao;
- mostrar voto;
- cronometros;
- materia legislativa em votacao;
- ementa;
- observacao;
- tipo de votacao;
- resultado;
- presentes;
- votos exibiveis conforme configuracao;
- oradores;
- mensagem padrao de votacao aberta ou ausencia de materia.

## Endpoints faltantes

| Endpoint/contrato | Motivo |
| --- | --- |
| `GET /api/sd/plenario/capabilities` | Detectar suporte real da instancia SAPL-SD. |
| `GET /api/sd/plenario/current-session` | Descoberta estavel de sessao corrente/candidata. |
| `GET /api/sd/plenario/sessions/{id}/state` | Payload canonico para Core/display, sem acoplamento ao template atual. |
| `GET /api/sd/plenario/sessions/{id}/voting` | Estado de votacao com ids canonicos de item. |
| `POST /api/sd/plenario/sessions/{id}/voting/open` | Comando futuro, idempotente e auditavel. |
| `POST /api/sd/plenario/sessions/{id}/voting/close` | Comando futuro, idempotente e auditavel. |
| `POST /api/sd/plenario/votes` | Registro de voto futuro, se aprovado; SAPL continua autoridade. |
| `GET /api/sd/plenario/me` | Correlacao usuario/parlamentar/permissoes para UI do Core. |

## Inventario SAPL

| Recurso | Existe upstream? | Existe SAPL-SD? | API? | Reutilizar? | Criar extensao? |
| --- | --- | --- | --- | --- | --- |
| Sessao ativa/corrente | Parcial, como sessoes pesquisaveis | Sim, `SessaoPlenaria` | Parcial via DRF | Sim | Sim, descoberta canonica |
| Painel | Sim | Sim | HTML + JSON especifico | Sim | Sim, estado canonico |
| Dados do painel | Sim, endpoint JSON | Sim, `/painel/<pk>/dados` | Parcial, nao canonica | Sim no MVP | Sim |
| Presenca | Sim | Sim | DRF autogerada | Sim | Talvez, para consolidar |
| Votacao aberta | Sim | Sim, flags em Ordem/Expediente | Parcial via DRF/painel | Sim leitura | Sim para comando |
| Voto individual | Sim | Sim, `/voto-individual/` | Tela HTML | Launcher no MVP | Sim para API futura |
| Resultado | Sim | Sim, `RegistroVotacao` | DRF/painel | Sim | Talvez, payload estavel |
| Parlamentares | Sim | Sim | DRF autogerada | Sim | Nao inicialmente |
| Materias | Sim | Sim | DRF autogerada | Sim | Nao inicialmente |
| Documentos | Sim | Sim | DRF/autogerada e arquivos | Sim | Talvez, agregacao |
| Oradores | Sim | Sim, `OradorExpediente` | Painel/DRF | Sim | Talvez, payload estavel |
| Cronometros | Sim, no painel | Sim, estado em sessao web/painel | Parcial | Sim no painel | Sim, se display proprio |

## Autenticacao e SSO

Usuarios humanos devem autenticar no Keycloak Legislativo. O Core deve usar OIDC Authorization Code + PKCE para web. O SAPL-SD ja tem piloto OIDC aditivo com `OidcIdentity`, o que permite SSO progressivo sem remover login local.

Autorizacao:

- Keycloak define identidade e roles macro.
- SAPL mantem permissoes legislativas detalhadas e `Votante`.
- Core mantem autorizacao operacional propria, restrita a configuracoes, dispositivos, displays e comandos disponiveis.
- Para Parlamentar, a correlacao com SAPL deve vir do SAPL (`Votante`/parlamentar) ou de endpoint proprio, nao de cadastro paralelo.
- Perfis funcionais validados para o piloto: Administrador, Operador, Presidente, Secretario e Vereador.
- No Core/Keycloak, os papeis tecnicos ficam limitados a `plenario.admin`, `plenario.operador` e `plenario.parlamentar`; Presidente, Secretario e cargo parlamentar exercido na sessao sao autoridade do SAPL.

Machine-to-machine:

- Preferir OAuth2 client credentials quando Keycloak e APIs estiverem preparados.
- No SAPL atual, usar token DRF de usuario tecnico com escopo/permissoes minimas enquanto nao houver M2M OIDC.
- Segredos somente por variavel de ambiente/secret manager do ambiente; nunca em repositorio.
- Todas as chamadas M2M devem ter timeout, auditoria, correlation id e retries controlados.

## Identificacao de dispositivo autorizado

Nao usar MAC address como identidade primaria. A politica de dispositivos foi validada como configuravel para o piloto. Para browser, o MVP deve usar chave de dispositivo gerada no cliente e credencial assinada pelo Core, vinculada ao usuario, device id, browser e prazo. Guardar apenas hash/identificador e metadados necessarios no Core.

Evolucao recomendada:

1. Token de dispositivo rotacionavel + refresh curto.
2. Vinculo a usuario/parlamentar e aprovacao operacional.
3. WebAuthn/passkey para prova forte quando a politica estiver madura.
4. Certificado de cliente apenas para cenarios controlados, se a operacao aceitar complexidade.

Estados validados para o piloto: `PENDENTE`, `AUTORIZADO`, `BLOQUEADO`, `REVOGADO`, `EXPIRADO`.

## Atualizacao de estado

MVP: polling curto e adaptativo do Core para SAPL e das interfaces para o Core. Isso reduz dependencias e funciona contra SAPL Interlegis remoto.

Proximo passo: SSE do Core para displays e interfaces de operador quando houver display proprio.

WebSocket: reservar para interacao bidirecional em tempo real, se polling/SSE forem insuficientes. Evitar Redis/Channels no MVP, salvo necessidade comprovada de fan-out.

## Display

MVP: o Display pode ser servido como launcher/iframe/link controlado para `/painel-principal/<sessao>` do SAPL quando o provider suportar.

Evolucao: Display proprio servido pelo Core, usando `get_panel_state()` canonico. Perfis futuros: `COMPLETO`, `PRESENCA`, `STATUS`, `CRONOMETRO`, `VOTACAO`, `ACONTECENDO_AGORA`.

Estados operacionais devem ser derivados do SAPL:

- sem sessao corrente: `SEM_SESSAO`;
- sessao criada mas nao iniciada: `PREPARANDO_SESSAO`;
- presenca em andamento: `REGISTRO_PRESENCA`;
- `iniciada` true e `finalizada` false: `SESSAO_INICIADA`;
- materia em expediente: `EXPEDIENTE`;
- materia em ordem do dia: `ORDEM_DIA`;
- `votacao_aberta` true: `VOTACAO`;
- `RegistroVotacao` ou `RegistroLeitura` recente: `RESULTADO`;
- orador ativo quando endpoint existir: `ORADOR`;
- `finalizada` true: `ENCERRADA`.

Estados como `SUSPENSA` dependem de modelagem/endpoint adicional, pois nao ficaram claros no codigo inspecionado.

## Descoberta automatica de sessao

Regra funcional validada em 2026-08-23:

1. Sessao com votacao aberta, quando houver uma unica sessao valida.
2. Sessao iniciada e nao finalizada na data atual.
3. Sessao com painel aberto, quando houver uma unica candidata.
4. Sessao do dia mais recente ainda nao finalizada como fallback.
5. Em qualquer ambiguidade, nao selecionar silenciosamente.
6. Apresentar candidatas e permitir selecao manual pelo Operador.

A descoberta somente identifica a sessao acompanhada pelo Plenario Digital e nunca altera estado legislativo no SAPL.

## Implantacao local-first

Cenario `LOCAL_COMPLETO`: SAPL-SD local + Core local:

- Traefik local roteando `sapl.camara.local` e `plenario.camara.local`, ou hosts `.legislagd.localhost` em dev.
- SAPL-SD, Core, Keycloak e PostgreSQL na LAN.
- Bancos separados para SAPL, Core e Keycloak.
- Operacao interna continua sem internet, exceto integracoes externas.

Cenario `REMOTO_COM_CACHE`: SAPL Interlegis remoto + Core local:

- Core local consulta SAPL remoto por API.
- Cache apenas de leitura.
- Sem SAPL remoto, comandos legislativos ficam indisponiveis.
- Nao armazenar voto offline para sincronizacao posterior sem ADR especifico.

Cenario `REMOTO_SEM_CONTINGENCIA`: sem SAPL remoto, recursos dependentes ficam indisponiveis.

O cenario `HIBRIDO` fica reservado para evolucao futura.

## Compatibilidade com SAPL Interlegis remoto

O provider remoto deve assumir capacidade menor:

- leitura por API existente;
- launchers de URLs quando autenticacao/sessao permitirem;
- escrita somente se API e autorizacao suportarem claramente;
- sem extensoes `/api/sd/...`.

O Core deve degradar graciosamente conforme capabilities e nunca depender de banco, rede Docker interna ou modelo Python do SAPL.

## Seguranca

Riscos e controles:

| Risco | Controle recomendado |
| --- | --- |
| Token/API key exposto | Secrets por ambiente, HTTPS, rotacao e menor privilegio. |
| CSRF em comandos | APIs JSON autenticadas, CSRF/session correto ou bearer token M2M; evitar comando por GET. |
| CORS amplo | Allowlist por host do Core/Display. |
| Replay de voto/comando | Idempotency key, nonce, timestamp, usuario, device id e auditoria. |
| Voto duplicado/alterado | SAPL decide politica; Core apenas reflete capabilities e resposta confirmada. |
| Concorrencia abrir/fechar votacao | Lock/transacao no SAPL, comando idempotente e retorno de estado atual. |
| Impersonation parlamentar | Correlacao pelo SAPL/Keycloak, nao por parametro livre do cliente. |
| Device roubado | Revogacao, expiracao curta, revalidacao e logs. |
| Painel publicando dado sensivel | Niveis de visibilidade no Core e respeito a configuracao SAPL `mostrar_voto`. |
| Logs com voto/token | Sanitizacao; nao logar payload sensivel. |
| Rede local insegura | HTTPS local em producao/homologacao e segmentacao minima. |

## Auditoria e consistencia de voto

Todo comando legislativo iniciado no Core deve ter ciclo:

1. usuario autenticado;
2. autorizacao local e capability do provider;
3. request ao SAPL com correlation/idempotency id;
4. confirmacao do SAPL;
5. persistencia de evento operacional no Core;
6. atualizacao de display/interface.

O Core nunca deve considerar voto, abertura de votacao ou resultado como concluidos antes de confirmacao do SAPL.

Nao ha voto offline no MVP, conforme validacao funcional. Qualquer contingencia com voto offline exige decisao separada sobre validade juridica, conflitos, ordem temporal, auditoria, assinatura e reconciliacao.

## Partes que podem iniciar sem alterar SAPL

- Projeto/estrutura inicial do Core.
- Modelos operacionais de provider, plenario, display e dispositivo.
- Health check contra SAPL.
- Cadastro de provider SAPL-SD/SAPL remoto.
- Descoberta inicial de sessao por API/painel.
- Launcher do painel existente.
- Launcher do voto individual existente.
- Prontidao tecnologica separada de presenca legislativa.
- Cache de leitura e capabilities.

## Partes que exigem mudanca no SAPL-SD

- API canonica de estado do plenario.
- Descoberta oficial de sessao corrente, se regra for consolidada.
- Comandos API para abrir/fechar votacao.
- Registro de voto por API, se aprovado.
- Endpoint para correlacionar usuario autenticado a parlamentar/votante.
- Eventos/SSE/webhooks de mudanca de estado, se polling se mostrar insuficiente.

## Mudancas e upstream

| Mudanca | SAPL-SD | Upstream possivel? | Justificativa |
| --- | --- | --- | --- |
| `GET current-session` | Extensao local inicial | Sim | Util generico para integracoes de plenario/painel. |
| `GET panel-state` canonico | Extensao local inicial | Sim | O painel ja existe; payload estavel beneficia integracoes. |
| `GET capabilities` | Extensao local inicial | Sim | Ajuda clientes a lidar com versoes diferentes. |
| Device management | Core, nao SAPL | Nao inicialmente | Dominio operacional do Plenario Digital. |
| Prontidao tecnologica | Core, nao SAPL | Nao inicialmente | Nao e presenca legislativa. |
| Comandos de votacao por API | Extensao local apos ADR | Talvez | Generico, mas exige desenho de seguranca e regras SAPL. |
| Registro de voto por API | Somente apos decisao especifica | Talvez | Alto risco juridico/auditoria; precisa maturidade. |
| Reescrever painel | Nao alterar | Nao | MVP reutiliza painel existente. |

## MVP tecnico

| ID | Entrega | Observacao |
| --- | --- | --- |
| PD-001 | Configuracao de provider SAPL | Base para SAPL-SD local e SAPL remoto. |
| PD-002 | Health check/conectividade | Usar `/health/`, `/ready/`, `/version/`. |
| PD-003 | Descoberta de sessao atual | Usar regra funcional validada; ambiguidades exigem selecao manual pelo Operador. |
| PD-004 | Launcher do painel existente | Abrir `/painel-principal/<sessao>`. |
| PD-005 | Launcher do voto individual existente | Encaminhar para `/voto-individual/`. |
| PD-006 | Estrutura inicial do Core | Django independente, banco proprio. |
| PD-007 | Prontidao tecnologica | Nao altera quorum/presenca SAPL. |
| PD-008 | Gerenciamento inicial de dispositivos | Sem MAC address como identidade primaria. |

## ADRs necessarios

- ADR desta arquitetura do Plenario Digital Core: necessario agora, em status `Proposed`.
- ADR futuro para comandos legislativos por API: necessario antes de abrir/fechar votacao pelo Core.
- ADR futuro para voto por API: necessario antes de substituir `/voto-individual/`.
- ADR futuro para contingencia com voto offline: necessario se algum dia for considerado.
- ADR futuro para tempo real WebSocket/Redis: somente se polling/SSE nao atender.

## Cross-Layer Impact Check

Impacto tecnico: sim, nova aplicacao Core e possiveis extensoes SAPL-SD. Registrado neste Gate e ADR proposto.

Impacto funcional: validado no Google Drive em 2026-08-23. Nao ha pendencia funcional aberta neste Gate para regra de descoberta de sessao, perfis piloto, prontidao tecnologica, politica de dispositivos, estados de dispositivo, voto no MVP, niveis de mensagens ou cenarios de contingencia.

Impacto em SD-Knowledge: nao ha alteracao transversal obrigatoria de Skill neste momento. Se a arquitetura for aprovada e se tornar padrao reutilizavel, avaliar PR separado no SD-Knowledge.

Pendencias tecnicas restantes:

- contrato canonico definitivo;
- endpoints `/api/sd/plenario/...`;
- device credential;
- autenticacao M2M definitiva;
- escrita contra SAPL Interlegis;
- comandos legislativos por API;
- voto por API;
- qualquer contingencia com voto offline.

## Recomendacao final

Aprovar, como proposta, a arquitetura:

```text
Usuarios / Displays
        |
        v
Plenario Digital Core (Django, banco proprio)
        |
        v
SAPL Adapter (contrato canonico + capabilities)
        |
        +--> SAPL-SD local: API upstream + extensoes /api/sd/plenario quando necessario
        |
        +--> SAPL Interlegis remoto: API/URLs existentes, capacidade reduzida
```

O SAPL controla o processo legislativo. O Plenario Digital controla a experiencia operacional do plenario.

O Core nao deve saber como o SAPL persiste seus dados; deve conhecer apenas contratos de integracao.
