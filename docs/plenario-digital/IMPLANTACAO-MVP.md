# Plenario Digital - Implantacao MVP

Status: Draft  
Data: 2026-08-23

## Escopo

Esta implantacao cobre o MVP seguro do Plenario Digital Core:

- Core Django independente em `sertaodigitalorg/Plenario-Digital-Core`;
- banco proprio `plenario_core` no PostgreSQL central do LegislaGD;
- rota local `http://plenario.legislagd.localhost`;
- health/readiness;
- descoberta de sessao acompanhada;
- launcher do painel SAPL existente;
- launcher do voto individual existente;
- cadastro operacional de providers, plenarios, displays, dispositivos, prontidao tecnologica e mensagens.

Fora do escopo:

- comandos legislativos por API;
- voto por API;
- voto offline;
- escrita contra SAPL Interlegis remoto.

## Repositorio

Repositorio canonico:

```text
https://github.com/sertaodigitalorg/Plenario-Digital-Core
```

O LegislaGD trata o Core como modulo independente em:

```text
modules/Plenario-Digital-Core
```

## Variaveis principais

```env
LEGISLAGD_ENABLE_PLENARIO=1
PLENARIO_DIGITAL_CORE_GIT_URL=https://github.com/sertaodigitalorg/Plenario-Digital-Core.git
PLENARIO_DIGITAL_CORE_BRANCH=main
PLENARIO_URL=http://plenario.legislagd.localhost
PLENARIO_DB_NAME=plenario_core
PLENARIO_DB_USER=plenario
PLENARIO_DB_PASSWORD=plenario_dev_password
SAPL_BASE_URL=http://sapl.legislagd.localhost
SAPL_INTERNAL_BASE_URL=http://sapl-dev:8000
```

## Subida local

Subir somente o Plenario Digital Core:

```bash
make up plenario
```

Subir a plataforma padrao com Plenario habilitado:

```bash
make up
```

Ver URLs:

```bash
make urls
```

## Validacao

Health do Core:

```bash
curl http://plenario.legislagd.localhost/health/
```

Readiness contra SAPL:

```bash
curl http://plenario.legislagd.localhost/ready/
```

Descoberta de sessao:

```bash
curl http://plenario.legislagd.localhost/api/current-session/
```

Capabilities:

```bash
curl http://plenario.legislagd.localhost/api/capabilities/
```

## Regra de descoberta

A descoberta somente identifica a sessao acompanhada e nunca altera estado legislativo no SAPL.

Ordem validada:

1. sessao com votacao aberta, quando houver uma unica sessao valida;
2. sessao iniciada e nao finalizada na data atual;
3. sessao com painel aberto, quando houver uma unica candidata;
4. sessao do dia mais recente ainda nao finalizada como fallback;
5. em qualquer ambiguidade, nao selecionar silenciosamente;
6. apresentar candidatas e permitir selecao manual pelo Operador.

## Operacao esperada no MVP

1. Operador acessa `http://plenario.legislagd.localhost`.
2. Core consulta o SAPL configurado.
3. Core identifica a sessao acompanhada ou apresenta candidatas.
4. Operador abre o painel SAPL existente pelo launcher.
5. Vereador usa `/voto-individual/` existente do SAPL.

O SAPL permanece autoridade de sessao, presenca legislativa, voto e resultado.

