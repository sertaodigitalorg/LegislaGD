# Incremento 1 - Health, Capabilities e Painel Operacional

Status: Implementado no modulo `modules/Plenario-Digital-Core`  
Data: 2026-08-24

## Escopo

Este incremento entrega a base operacional inicial do Plenario Digital:

- health publico e minimo do Core;
- readiness protegida com checks padronizados;
- verificacao real do banco do Core;
- verificacao do provider SAPL/SAPL-SD;
- verificacao de autenticacao/Keycloak quando configurada;
- classificacao de Internet como nao obrigatoria no perfil `LOCAL_COMPLETO`;
- capabilities estruturadas por provider;
- painel operacional inicial com polling;
- logs/erros sanitizados no retorno de usuario;
- token SAPL lido de ambiente, sem gravacao automatica no banco.

Fora do escopo:

- presenca;
- dispositivos e heartbeat;
- displays dedicados;
- rito configuravel;
- fala;
- votacao por API;
- comandos legislativos;
- WebSocket/SSE/broker;
- voto offline.

## Endpoints

| Endpoint | Acesso | Uso |
| --- | --- | --- |
| `/health/` | publico | Informa se o processo do Core esta vivo. |
| `/ready/` | `plenario.admin` ou `plenario.operador` | Informa readiness operacional com checks detalhados. |
| `/api/capabilities/` | `plenario.admin` ou `plenario.operador` | Lista capabilities do provider com status e fonte. |
| `/api/current-session/` | `plenario.admin` ou `plenario.operador` | Mantido do MVP anterior; nao e foco do Incremento 1. |
| `/` | `plenario.admin` ou `plenario.operador` | Painel operacional. |

## Status

Status tecnico minimo:

- `OK`;
- `DEGRADED`;
- `UNAVAILABLE`;
- `UNKNOWN`.

Cada check retorna:

- nome;
- status;
- latencia;
- timestamp;
- mensagem sanitizada;
- impacto operacional;
- detalhes seguros quando aplicavel.

## Configuracao

Variaveis principais:

```env
PLENARIO_AUTH_REQUIRED=true
PLENARIO_ADMIN_ROLE=plenario.admin
PLENARIO_OPERATOR_ROLE=plenario.operador
PLENARIO_VERSION=0.1.0
PLENARIO_OPERATION_PROFILE=LOCAL_COMPLETO
PLENARIO_INTERNET_REQUIRED=false
PLENARIO_POLLING_SECONDS=10
SAPL_BASE_URL=http://sapl.legislagd.localhost
SAPL_INTERNAL_BASE_URL=http://sapl-dev:8000
SAPL_API_TOKEN=
SAPL_TIMEOUT_SECONDS=5
KEYCLOAK_BASE_URL=http://id.legislagd.localhost
```

`SAPL_API_TOKEN` deve permanecer em variavel de ambiente/secret do ambiente.
Nao deve ser gravado no banco do Core.

## Comportamento degradado

- Banco Core indisponivel: `/health/` continua vivo, mas `/ready/` deve ficar
  `UNAVAILABLE` e o painel deve indicar impacto critico.
- SAPL indisponivel: o Core continua vivo; readiness fica degradada ou
  indisponivel conforme impacto do provider.
- Internet indisponivel em `LOCAL_COMPLETO`: nao torna o Core indisponivel.
- Keycloak sem health configurado: status `UNKNOWN`, exigindo revisao
  operacional, sem expor detalhes sensiveis.

## Capabilities

Capabilities usam status estruturado:

- `available`;
- `unavailable`;
- `unknown`.

Capabilities de escrita legislativa e voto por API permanecem `unavailable` no
Incremento 1. `read.panel_state` do SAPL-SD permanece como legado/temporario ate
existir contrato canonico.

## Testes

Cobertura adicionada no Core:

- health publico e minimo;
- readiness protegido;
- readiness com banco e SAPL;
- capabilities estruturadas;
- voto por API e comandos marcados como indisponiveis.

## Limitacoes

O modulo ainda possui modelos e endpoints herdados do MVP inicial para sessao
acompanhada. Eles nao fazem parte do foco deste incremento e nao devem ser
expandidos antes do Incremento 2.

## Cross-Layer

LegislaGD: mudancas documentadas neste arquivo e no modulo Core.

SAPL-SD: nenhum patch nesta execucao. Continua pendente endpoint canonico de
capabilities/estado do plenario para substituir deteccao por schema e adapter
legado.

SD-Knowledge: sem mudanca transversal obrigatoria.

Drive MASTER: sem divergencia funcional nova.
