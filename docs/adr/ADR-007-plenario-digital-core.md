# ADR-007: Plenario Digital Core independente integrado ao SAPL por API

Status: Proposed  
Data: 2026-08-23

## Contexto

O Plenario Digital deve complementar o SAPL/SAPL-SD sem criar uma segunda fonte autoritativa para sessoes, parlamentares, presenca legislativa, pauta, materias, votacao, votos ou resultado.

O mesmo Plenario Digital deve operar com SAPL-SD local e com SAPL Interlegis remoto. A arquitetura vigente do LegislaGD preserva repositorios independentes, modelo nao SaaS/local-first e integracao por API, eventos ou contratos controlados.

O codigo atual do SAPL-SD ja fornece painel principal, voto individual, APIs DRF, health/readiness e piloto OIDC com Keycloak Legislativo. O painel atual pode ser reutilizado no MVP, mas o JSON do painel ainda e contrato de UI, nao API canonica estavel.

A validacao funcional concluida no Google Drive em 2026-08-23 confirmou para o piloto:

- perfis Administrador, Operador, Presidente, Secretario e Vereador;
- prontidao tecnologica separada de presenca legislativa e quorum;
- politica configuravel de dispositivos;
- estados `PENDENTE`, `AUTORIZADO`, `BLOQUEADO`, `REVOGADO`, `EXPIRADO`;
- SAPL como autoridade do voto;
- Core sem voto autoritativo;
- MVP usando `/voto-individual/` existente;
- sem voto offline no MVP;
- niveis `PUBLICO_DISPLAY`, `PARLAMENTAR`, `OPERACIONAL`, `ADMINISTRATIVO`;
- contingencias `LOCAL_COMPLETO`, `REMOTO_COM_CACHE`, `REMOTO_SEM_CONTINGENCIA`;
- `HIBRIDO` reservado para evolucao futura.

Na consolidacao tecnica de 2026-08-24, os papeis do Core foram separados dos
cargos legislativos da sessao. O Keycloak/Core controla acesso tecnico por
`plenario.admin`, `plenario.operador` e `plenario.parlamentar`. Presidencia,
secretaria, presenca, quorum, direito de voto e cargo exercido em uma sessao
continuam autoridade do SAPL e nao devem ser inferidos por role do Core.

## Decisao proposta

Implementar o Plenario Digital como um Core Django independente, com banco proprio, integrado ao SAPL por um SAPL Adapter e contrato canonico.

O Core deve:

- persistir apenas dados operacionais proprios;
- consumir SAPL por API HTTP e URLs de launcher;
- suportar providers SAPL-SD e SAPL Interlegis remoto;
- detectar capabilities por provider;
- reaproveitar inicialmente `/painel-principal/<sessao>` e `/voto-individual/`;
- descobrir a sessao acompanhada sem alterar estado legislativo no SAPL;
- permitir que o Operador persista a sessao acompanhada no Core sem alterar o SAPL;
- controlar acesso tecnico proprio sem substituir cargos legislativos da sessao;
- tratar toda alteracao legislativa como concluida somente apos confirmacao do SAPL;
- evitar acesso direto ao banco do SAPL.

O SAPL-SD pode receber extensoes API nao intrusivas, preferencialmente em namespace como `/api/sd/plenario/...`, quando APIs existentes nao forem suficientes.

A descoberta de sessao deve seguir a regra funcional validada:

1. sessao com votacao aberta, quando houver uma unica sessao valida;
2. sessao iniciada e nao finalizada na data atual;
3. sessao com painel aberto, quando houver uma unica candidata;
4. sessao do dia mais recente ainda nao finalizada como fallback;
5. em qualquer ambiguidade, nao selecionar silenciosamente;
6. apresentar candidatas e permitir selecao manual pelo Operador.

## Consequencias

Positivas:

- reduz acoplamento com modelos internos do SAPL;
- preserva compatibilidade com upstream;
- permite operar com SAPL-SD local e SAPL Interlegis remoto;
- mantem SAPL como autoridade legislativa;
- permite evolucao incremental sem substituir painel/voto existentes;
- encaixa na infraestrutura local-first do LegislaGD.

Negativas:

- exige desenho e manutencao de contrato canonico;
- comandos legislativos exigirao endpoints SAPL-SD especificos antes de UI propria de presidente/operador;
- SAPL Interlegis remoto podera ter capabilities menores;
- consistencia de voto e auditoria precisam decisoes especificas antes de substituir voto individual.

## Dados do Core

O banco do Core pode armazenar:

- providers e conexoes;
- plenarios;
- displays e perfis;
- dispositivos e estados de autorizacao;
- credenciais complementares e metadados nao secretos;
- prontidao tecnologica;
- preferencias de apresentacao;
- mensagens e visibilidade;
- cache/snapshots derivados do SAPL;
- eventos e auditoria operacional.

O banco do Core nao deve armazenar como autoridade:

- sessoes legislativas;
- presenca legislativa;
- pauta, ordem do dia, materias, proposicoes e documentos;
- votacao oficial;
- voto registrado;
- resultado oficial;
- regras formais do processo legislativo.

## Alternativas consideradas

Modulo dentro do SAPL: rejeitado como arquitetura principal por aumentar acoplamento e dificultar SAPL Interlegis remoto.

Servico em stack nova: rejeitado para o MVP por adicionar runtime e complexidade sem beneficio comprovado.

Core independente + extensoes SAPL-SD pontuais: recomendado.

## Decisoes tecnicas futuras relacionadas

- contrato canonico definitivo;
- endpoints `/api/sd/plenario/...`;
- device credential;
- autenticacao M2M definitiva;
- escrita contra SAPL Interlegis;
- comandos legislativos por API;
- voto por API;
- qualquer contingencia com voto offline;
- SSE/WebSocket se polling nao atender.
