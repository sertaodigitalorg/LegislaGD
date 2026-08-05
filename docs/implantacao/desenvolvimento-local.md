# Desenvolvimento local

Use `scripts/bootstrap.sh` para preparar diretorios ausentes, copiar `.env.example` para `.env` quando necessario e clonar componentes ausentes.

## Papel do LegislaGD

O LegislaGD e a plataforma central legislativa aberta. Neste repositorio ficam a orquestracao local, os nomes de acesso, os comandos principais e a documentacao de uso. Os componentes seguem como sistemas independentes, mas durante o desenvolvimento sao tratados como modulos integrados da plataforma:

- `PortalModelo-SD`: portal institucional e fachada publica.
- `SAPL-SD`: processo legislativo e dados legislativos oficiais.
- `SIGI-SD`: atendimento, ouvidoria, e-SIC, IA e automacoes de relacionamento.
- `e-Cidade-SD`: modulo administrativo previsto, mas ainda fora da subida principal.

## Requisitos

- Docker com Docker Compose v2.
- `make`.
- Repositorios clonados lado a lado:
  - `C:\LegislaGD`
  - `C:\PortalModelo-SD`
  - `C:\SAPL-SD`
  - `C:\SIGI-SD`

Se algum desses reposititorios ainda nao existir, `make up` chama `scripts/clone-components.sh` antes do Docker Compose. Por padrao, o clone usa os forks oficiais da Sertao Digital:

| Modulo | Fork usado como `origin` | Upstream quando aplicavel |
| --- | --- | --- |
| PortalModelo-SD | `https://github.com/sertaodigitalorg/PortalModelo-SD.git` | `https://github.com/interlegis/portalmodelo.git` |
| SAPL-SD | `https://github.com/sertaodigitalorg/SAPL-SD.git` | `https://github.com/interlegis/sapl.git` |
| SIGI-SD | `https://github.com/sertaodigitalorg/SIGI-SD.git` | mantido pelo Sertao Digital |
| e-Cidade-SD | `https://github.com/sertaodigitalorg/e-Cidade-SD.git` | `https://github.com/DBSeller/e-cidade.git` |

O script nao troca branch, nao executa reset e nao sobrescreve historico de repositorios que ja existem localmente.

As URLs podem ser substituidas no `.env` quando for necessario usar outra fonte:

```bash
PORTALMODELO_SD_GIT_URL=https://github.com/sertaodigitalorg/PortalModelo-SD.git
SAPL_SD_GIT_URL=https://github.com/sertaodigitalorg/SAPL-SD.git
SIGI_SD_GIT_URL=https://github.com/sertaodigitalorg/SIGI-SD.git
ECIDADE_SD_GIT_URL=https://github.com/sertaodigitalorg/e-Cidade-SD.git
```

## Branch por ambiente

A branch dos componentes e configurada no `.env` do LegislaGD. O padrao local e `dev`:

```bash
LEGISLAGD_ENV=development
LEGISLAGD_COMPONENT_BRANCH=dev
LEGISLAGD_ENABLE_PORTAL=1
LEGISLAGD_ENABLE_SAPL=1
LEGISLAGD_ENABLE_SIGI=1
LEGISLAGD_INCLUDE_ECIDADE=0
```

Mapeamento recomendado:

| Ambiente | Branch dos componentes |
| --- | --- |
| Desenvolvimento local | `dev` |
| Homologacao | `hml` |
| Principal/producao | `main` |

Tambem e possivel fixar uma branch por modulo:

```bash
SAPL_SD_BRANCH=dev
PORTALMODELO_SD_BRANCH=hml
SIGI_SD_BRANCH=main
```

Use `LEGISLAGD_ENABLE_PORTAL=0`, `LEGISLAGD_ENABLE_SAPL=0` ou `LEGISLAGD_ENABLE_SIGI=0` para retirar um modulo da subida principal. Os comandos individuais continuam disponiveis, por exemplo `make up sapl`.

Use `LEGISLAGD_INCLUDE_ECIDADE=1` somente quando a etapa administrativa estiver pronta para entrar na plataforma.

## Subida principal

No diretorio `C:\LegislaGD`, execute:

```bash
make up
```

Esse comando sobe:

- Clonagem dos forks ausentes, conforme a branch configurada.
- Traefik central do LegislaGD.
- PortalModelo-SD, quando `LEGISLAGD_ENABLE_PORTAL=1`.
- SAPL-SD e PostgreSQL de desenvolvimento, quando `LEGISLAGD_ENABLE_SAPL=1`.
- SIGI-SD e seus servicos definidos no compose do modulo, quando `LEGISLAGD_ENABLE_SIGI=1`.

O e-Cidade-SD nao sobe nesta etapa.

Para derrubar tudo:

```bash
make down
```

Para reiniciar tudo:

```bash
make restart
```

## Modulos individuais

Use os comandos individuais quando quiser trabalhar em apenas um modulo com o mesmo Traefik central:

```bash
make up portal
make up sapl
make up sigi
```

Para parar ou remover apenas um modulo:

```bash
make stop portal
make down portal
make down sapl
make down sigi
```

## URLs locais

Execute:

```bash
make urls
```

Enderecos principais:

| Modulo | URL |
| --- | --- |
| LegislaGD / Traefik | `http://legislagd.localhost` |
| Dashboard Traefik | `http://proxy.legislagd.localhost` |
| PortalModelo-SD | `http://portal.legislagd.localhost` |
| SAPL-SD | `http://sapl.legislagd.localhost` |
| SIGI-SD admin | `http://sigi.legislagd.localhost` |
| SIGI Chatwoot | `http://chat.sigi.legislagd.localhost` |
| SIGI Botpress | `http://bot.sigi.legislagd.localhost` |
| SIGI IA/Ollama | `http://ia.sigi.legislagd.localhost` |
| SIGI Qdrant | `http://qdrant.sigi.legislagd.localhost` |
| SIGI pgAdmin | `http://pgadmin.sigi.legislagd.localhost` |
| SIGI Portainer | `http://portainer.sigi.legislagd.localhost` |

Os nomes `*.localhost` normalmente resolvem para a maquina local sem editar `hosts`.

## Comandos uteis

```bash
make ps
make ps portal
make logs portal
make logs sapl
make logs sigi
make logs proxy
make config
make build
make pull
```

`make logs` exige um modulo porque acompanha logs em modo continuo.

## Traefik central

O compose `infrastructure/compose/docker-compose.proxy.yml` cria a rede Docker `legislagd` e sobe um Traefik unico para a plataforma. Os overrides em `infrastructure/compose/overrides/` conectam os modulos a essa rede e adicionam labels de roteamento.

Quando o LegislaGD sobe o SIGI-SD, o Traefik proprio do SIGI fica em profile `standalone` para evitar conflito na porta 80. Se for trabalhar dentro de `C:\SIGI-SD` sem o LegislaGD, os comandos originais do SIGI continuam disponiveis.
