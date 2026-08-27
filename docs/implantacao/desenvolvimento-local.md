# Desenvolvimento local

Use `scripts/bootstrap.sh` para preparar diretorios ausentes, copiar `.env.example` para `.env` quando necessario e clonar componentes ausentes.

## Padrao local

Por padrao, executar `make up` no repositorio `C:\LegislaGD` sobe o ambiente `development` da plataforma central usando a branch `dev` dos modulos.

Sem alterar o `.env`, o comportamento esperado e:

- `LEGISLAGD_ENV=development`.
- `LEGISLAGD_COMPONENT_BRANCH=dev`.
- `LEGISLAGD_ENABLE_PORTAL=1`.
- `LEGISLAGD_ENABLE_SAPL=1`.
- `LEGISLAGD_ENABLE_SIGI=1`.
- `LEGISLAGD_ENABLE_KEYCLOAK=1`.
- `LEGISLAGD_ENABLE_ECIDADE=1`.

Assim, `make up` sobe Keycloak, PortalModelo-SD, SAPL-SD, Plenario-Digital-Core, SIGI-SD, e-Cidade-SD e o Traefik central.

O banco da plataforma integrada tambem e centralizado: `make up` sobe um unico container PostgreSQL chamado `legislagd-postgres`, com bases e usuarios separados para cada modulo.

O Keycloak usa banco e usuario proprios dentro do PostgreSQL central `legislagd-postgres`. Ele nao compartilha schema nem credenciais com SAPL-SD, Plenario-Digital-Core, SIGI-SD, Chatwoot ou e-Cidade-SD.

## Papel do LegislaGD

O LegislaGD e a plataforma central legislativa aberta. Neste repositorio ficam a orquestracao local, os nomes de acesso, os comandos principais e a documentacao de uso. Os componentes seguem como sistemas independentes, mas durante o desenvolvimento sao tratados como modulos integrados da plataforma:

- `PortalModelo-SD`: portal institucional e fachada publica.
- `SAPL-SD`: processo legislativo e dados legislativos oficiais.
- `Plenario-Digital-Core`: experiencia operacional do plenario, integrada ao SAPL por API.
- `SIGI-SD`: atendimento, ouvidoria, e-SIC, IA e automacoes de relacionamento.
- `e-Cidade-SD`: administracao, financas, RH, compras e patrimonio.

## Requisitos

- Docker com Docker Compose v2.
- `make`.
- Componentes clonados dentro do workspace do LegislaGD:
  - `C:\LegislaGD`
  - `C:\LegislaGD\modules\PortalModelo-SD`
  - `C:\LegislaGD\modules\SAPL-SD`
  - `C:\LegislaGD\modules\Plenario-Digital-Core`
  - `C:\LegislaGD\modules\SIGI-SD`
  - `C:\LegislaGD\modules\SIGI-SD\apps\chatwoot-sd`

Se algum desses reposititorios ainda nao existir, `make up` chama `scripts/clone-components.sh` antes do Docker Compose. Por padrao, o clone usa os forks oficiais da Sertao Digital:

| Modulo | Fork usado como `origin` | Upstream quando aplicavel |
| --- | --- | --- |
| PortalModelo-SD | `https://github.com/sertaodigitalorg/PortalModelo-SD.git` | `https://github.com/interlegis/portalmodelo.git` |
| SAPL-SD | `https://github.com/sertaodigitalorg/SAPL-SD.git` | `https://github.com/interlegis/sapl.git` |
| Plenario-Digital-Core | `https://github.com/sertaodigitalorg/Plenario-Digital-Core.git` | componente proprio |
| SIGI-SD | `https://github.com/sertaodigitalorg/SIGI-SD.git` | mantido pelo Sertao Digital |
| Chatwoot-SD | `https://github.com/sertaodigitalorg/Chatwoot-SD.git` | `https://github.com/chatwoot/chatwoot.git` |
| e-Cidade-SD | `https://github.com/sertaodigitalorg/e-Cidade-SD.git` | `https://github.com/DBSeller/e-cidade.git` |

O script nao troca branch, nao executa reset e nao sobrescreve historico de repositorios que ja existem localmente.
Quando encontra clones no layout antigo lado a lado, como `C:\SAPL-SD`, ele pode usa-los apenas como fonte para criar um novo clone em `modules/`, sem mover ou alterar o repositorio antigo.

O local padrao dos componentes e controlado por `LEGISLAGD_COMPONENTS_DIR`:

```bash
LEGISLAGD_COMPONENTS_DIR=modules
```

Esse caminho e relativo a raiz do LegislaGD. Assim, em servidor, a instalacao pode ficar autocontida em um unico diretorio, por exemplo `/opt/legislagd/modules/SAPL-SD`.

As URLs podem ser substituidas no `.env` quando for necessario usar outra fonte:

```bash
PORTALMODELO_SD_GIT_URL=https://github.com/sertaodigitalorg/PortalModelo-SD.git
SAPL_SD_GIT_URL=https://github.com/sertaodigitalorg/SAPL-SD.git
PLENARIO_DIGITAL_CORE_GIT_URL=https://github.com/sertaodigitalorg/Plenario-Digital-Core.git
SIGI_SD_GIT_URL=https://github.com/sertaodigitalorg/SIGI-SD.git
CHATWOOT_SD_GIT_URL=https://github.com/sertaodigitalorg/Chatwoot-SD.git
ECIDADE_SD_GIT_URL=https://github.com/sertaodigitalorg/e-Cidade-SD.git
```

## Branch por ambiente

A branch dos componentes e configurada no `.env` do LegislaGD. O padrao local e `dev`, associado ao ambiente `development`:

```bash
LEGISLAGD_ENV=development
LEGISLAGD_COMPONENT_BRANCH=dev
LEGISLAGD_ENABLE_PORTAL=1
LEGISLAGD_ENABLE_SAPL=1
LEGISLAGD_ENABLE_SIGI=1
LEGISLAGD_ENABLE_ECIDADE=1
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
CHATWOOT_SD_BRANCH=dev
```

O `Chatwoot-SD` usa as branches padrao do ecossistema (`dev`, `hml`, `main`) e
acompanha o upstream Chatwoot a partir da branch `develop`. Ele e clonado dentro
do SIGI-SD, em `apps/chatwoot-sd`, porque o Chatwoot e parte da plataforma de
atendimento/CiRM do SIGI.

Use `LEGISLAGD_ENABLE_PORTAL=0`, `LEGISLAGD_ENABLE_SAPL=0`, `LEGISLAGD_ENABLE_PLENARIO=0` ou `LEGISLAGD_ENABLE_SIGI=0` para retirar um modulo da subida principal. Os comandos individuais continuam disponiveis, por exemplo `make up sapl`.

O SAPL-SD recebe o atalho autenticado para o Plenario Digital por `LEGISLAGD_PLENARIO_DIGITAL_ENABLED` e `LEGISLAGD_PLENARIO_DIGITAL_URL`. Na plataforma integrada, o default acompanha `LEGISLAGD_ENABLE_PLENARIO`; em ambiente controlado ou execucao local do Plenario, a URL pode apontar para outro host HTTP/HTTPS valido.

Use `LEGISLAGD_ENABLE_ECIDADE=0` quando quiser retirar o e-Cidade-SD da subida principal. O comando individual continua disponivel com `make up ecidade`.

## Subida principal

No diretorio `C:\LegislaGD`, execute:

```bash
make up
```

Esse comando sobe:

- Clonagem dos forks ausentes, conforme a branch configurada.
- PostgreSQL central do LegislaGD.
- Traefik central do LegislaGD.
- Keycloak usando banco e usuario proprios no PostgreSQL central, quando `LEGISLAGD_ENABLE_KEYCLOAK=1`.
- PortalModelo-SD, quando `LEGISLAGD_ENABLE_PORTAL=1`.
- SAPL-SD apontando para o PostgreSQL central, quando `LEGISLAGD_ENABLE_SAPL=1`.
- Plenario-Digital-Core apontando para o PostgreSQL central, quando `LEGISLAGD_ENABLE_PLENARIO=1`.
- SIGI-SD e seus servicos definidos no compose do modulo, quando `LEGISLAGD_ENABLE_SIGI=1`.
- Chatwoot-SD como fonte de build do Chatwoot, quando `LEGISLAGD_ENABLE_SIGI=1`.
- e-Cidade-SD apontando para o PostgreSQL central, quando `LEGISLAGD_ENABLE_ECIDADE=1`.
- Migracoes do SAPL-SD e sincronizacao de schema do SIGI-SD no PostgreSQL central.

Com o `.env.example` ou sem `.env`, PortalModelo-SD, SAPL-SD, Plenario-Digital-Core, SIGI-SD, Keycloak e e-Cidade-SD ficam habilitados. A branch padrao dos modulos e `dev`, exceto o Plenario-Digital-Core e o e-Cidade-SD, que usam `main` por padrao nesta etapa.

Observacao sobre o SIGI-SD: no estado atual do fork, as migrations Doctrine existentes carregam SQL especifico de MySQL. Para desenvolvimento local integrado com PostgreSQL, o LegislaGD usa `doctrine:schema:update` no alvo `make migrate-sigi`. Antes de homologacao/producao, as migrations do SIGI-SD devem ser regeneradas para PostgreSQL.

## Nova instalacao local com cargas iniciais

Para preparar um ambiente local de desenvolvimento ja ativo, execute:

```bash
make dev-install
```

Esse comando:

- cria `.env` a partir de `.env.example`, quando necessario;
- define valores locais para `CHATWOOT_OIDC_CLIENT_SECRET`, `CHATWOOT_SSO_PASSWORD` e `ECIDADE_OIDC_CLIENT_SECRET` se estiverem vazios;
- sobe a plataforma integrada;
- aplica migrations/esquemas dos modulos;
- garante usuarios administrativos locais do SAPL-SD;
- cria/atualiza clients, roles e usuarios locais do Keycloak, incluindo o client `ecidade`;
- carrega fixtures estruturais do SIGI-SD;
- cria/atualiza o usuario local do Chatwoot usado pelo SSO LegislaGD;
- recria a carga inicial do PortalModelo-SD via buildout;
- executa a carga inicial do e-Cidade-SD usando `docker/install.sh` do modulo contra o PostgreSQL central.

Tambem e possivel rodar cada carga separadamente:

```bash
make prepare-dev-env
make initial-load-sapl
make initial-load-sigi
make initial-load-keycloak
make initial-load-portal
make initial-load-ecidade
make initial-load
```

`make initial-load-sigi` executa `doctrine:fixtures:load --no-interaction` e, em seguida, `scripts/provision-chatwoot-dev-sso.sh` para garantir o usuario local do Chatwoot vinculado ao SSO. Use em ambiente local/desenvolvimento, pois fixtures podem recriar dados estruturais. `make initial-load-portal` executa a rotina de seed do PortalModelo-SD e pode recriar o site local de desenvolvimento. `make initial-load-ecidade` usa a carga base do e-Cidade-SD no banco central `ecidade`.

## Banco de dados central

No modo integrado do LegislaGD existe apenas uma instalacao PostgreSQL:

| Banco | Usuario | Uso |
| --- | --- | --- |
| `sapl_sd` | `sapl` | SAPL-SD |
| `plenario_core` | `plenario` | Plenario-Digital-Core |
| `sigi_sd` | `sigi` | SIGI-SD admin e worker |
| `chatwoot_production` | `chatwoot` | Chatwoot do SIGI-SD |
| `ecidade` | `dbseller` | e-Cidade-SD |

As credenciais podem ser alteradas no `.env`:

```bash
LEGISLAGD_POSTGRES_PORT=5432
SAPL_DB_NAME=sapl_sd
SAPL_DB_USER=sapl
SAPL_DB_PASSWORD=sapl_dev_password
SIGI_DB_NAME=sigi_sd
SIGI_DB_USER=sigi
SIGI_DB_PASSWORD=sigi_dev_password
CHATWOOT_DB_NAME=chatwoot_production
CHATWOOT_DB_USER=chatwoot
CHATWOOT_DB_PASSWORD=chatwoot_dev_password
ECIDADE_DB_NAME=ecidade
ECIDADE_DB_USER=dbseller
ECIDADE_DB_PASSWORD=dbseller
```

Os bancos dos composes originais dos modulos nao devem ser usados pela plataforma integrada. SAPL-SD, SIGI-SD, Chatwoot e e-Cidade-SD apontam para `legislagd-postgres` quando sobem pelo LegislaGD; os repositorios ainda podem rodar isolados com seus composes proprios.

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
make up plenario
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
| Keycloak | `http://id.legislagd.localhost` |
| PortalModelo-SD | `http://portal.legislagd.localhost` |
| SAPL-SD | `http://sapl.legislagd.localhost` |
| Plenario Digital | `http://plenario.legislagd.localhost` |
| SIGI-SD admin | `http://sigi.legislagd.localhost` |
| SIGI Chatwoot | `http://chat.sigi.legislagd.localhost` |
| SIGI Botpress | `http://bot.sigi.legislagd.localhost` |
| SIGI IA/Ollama | `http://ia.sigi.legislagd.localhost` |
| SIGI Qdrant | `http://qdrant.sigi.legislagd.localhost` |
| SIGI pgAdmin | `http://pgadmin.sigi.legislagd.localhost` |
| SIGI Portainer | `http://portainer.sigi.legislagd.localhost` |
| e-Cidade-SD | `http://ecidade.legislagd.localhost` |

Os nomes `*.localhost` normalmente resolvem para a maquina local sem editar `hosts`.

## Identidade e SSO local

O Keycloak local e exposto pelo Traefik em:

```bash
http://id.legislagd.localhost
```

O realm importado inicialmente e `legislagd`, com clients separados para `legislagd`, `sapl`, `sigi`, `chatwoot` e `ecidade`.

O idioma padrao do realm local e `pt-BR`. O SAPL-SD tambem envia
`ui_locales=pt-BR` na chamada OIDC para solicitar a tela de login do Keycloak
em portugues.

Usuario de teste local para o piloto SAPL-SD:

| Usuario | Senha | Role |
| --- | --- | --- |
| `sapl.operador` | `sapl_dev_password` | `sapl.operador` |

Usuario de teste local para o piloto Chatwoot-SD:

| Usuario | Senha | E-mail | Role |
| --- | --- | --- | --- |
| `chatwoot.agent` | definida em `CHATWOOT_SSO_PASSWORD` | `john@acme.inc` | `chatwoot.agent` |

O e-mail padrao `john@acme.inc` acompanha o seed local do Chatwoot. Se a base
local nao tiver esse usuario, configure `CHATWOOT_OIDC_ACCOUNT_ID` para permitir
criacao Just-In-Time em uma conta especifica ou ajuste `CHATWOOT_SSO_EMAIL` para
um usuario Chatwoot ja existente. Defina tambem `CHATWOOT_OIDC_CLIENT_SECRET`
e `CHATWOOT_SSO_PASSWORD` no ambiente local antes de provisionar o Keycloak.

Usuario de teste local para o piloto e-Cidade-SD:

| Usuario | Senha | E-mail | Role |
| --- | --- | --- | --- |
| `dbseller` | `ecidade_dev_password` | `dbseller@legislagd.localhost` | `ecidade.admin` |

O SSO do e-Cidade-SD fica em `extension/package/Legislagdsso` dentro do fork
e-Cidade-SD. Ele preserva o login local e adiciona o botao `Entrar com
LegislaGD` por `modification` no template de login. O callback cria a sessao
legada `DB_*` somente apos validar token OIDC, role macro `ecidade.*`, usuario
local ativo e departamento existente.

Variaveis principais:

```bash
LEGISLAGD_ENABLE_KEYCLOAK=1
KEYCLOAK_REALM=legislagd
KEYCLOAK_HOST=id.legislagd.localhost
KEYCLOAK_FRONTEND_URL=http://id.legislagd.localhost
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin_dev_password
KEYCLOAK_DB_NAME=keycloak
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=keycloak_dev_password
CHATWOOT_OIDC_ENABLED=true
CHATWOOT_OIDC_CLIENT_ID=chatwoot
CHATWOOT_OIDC_CLIENT_SECRET=
CHATWOOT_OIDC_ISSUER=http://id.legislagd.localhost/realms/legislagd
CHATWOOT_SSO_PASSWORD=
ECIDADE_OIDC_ENABLED=true
ECIDADE_OIDC_CLIENT_ID=ecidade
ECIDADE_OIDC_CLIENT_SECRET=
ECIDADE_OIDC_ISSUER=http://id.legislagd.localhost/realms/legislagd
ECIDADE_OIDC_REDIRECT_URI=http://ecidade.legislagd.localhost/extension/legislagdsso/auth/callback
ECIDADE_OIDC_ALLOW_EMAIL_LINK=true
ECIDADE_OIDC_ALLOW_LOGIN_LINK=true
```

Essas senhas sao padroes de desenvolvimento. Em homologacao e producao, devem ser substituidas por secrets ou variaveis fora do Git.

Comandos:

```bash
make up keycloak
make provision-keycloak-db
make provision-keycloak-dev-users
make ps keycloak
make logs keycloak
make down keycloak
```

Se o realm `legislagd` ja existia antes da inclusao do usuario local de teste
ou antes da configuracao final do client SAPL, execute
`make provision-keycloak-dev-users` para criar/atualizar o usuario
`sapl.operador` e garantir o client `sapl` como publico com PKCE, sem apagar o
banco do Keycloak.

## Acesso SAPL-SD

No ambiente local integrado, o SAPL-SD usa por padrao:

| Usuario | Senha |
| --- | --- |
| `admin` | `interlegis` |
| `interlegis` | `interlegis` |

Se a base ja existir e a senha nao funcionar, execute no WSL Ubuntu:

```bash
cd /mnt/c/LegislaGD
scripts/reset-sapl-admin.sh
```

## Comandos uteis

```bash
make ps
make ps portal
make logs portal
make logs sapl
make logs sigi
make logs proxy
make config
make ps keycloak
make logs keycloak
make build
make pull
make migrate
scripts/test-wsl-stack.sh
```

`make logs` exige um modulo porque acompanha logs em modo continuo.

O script `scripts/test-wsl-stack.sh` deve ser executado dentro do WSL Ubuntu depois de `make up`; ele consulta as URLs via Traefik, lista containers PostgreSQL ativos e mostra as branches locais dos modulos.

## Traefik central

O compose `infrastructure/compose/docker-compose.proxy.yml` cria a rede Docker `legislagd` e sobe um Traefik unico para a plataforma. Os overrides em `infrastructure/compose/overrides/` conectam os modulos a essa rede e adicionam labels de roteamento.

O Traefik tambem recebe o alias Docker `id.legislagd.localhost` nessa rede. Isso permite que containers como o SAPL-SD acessem o issuer OIDC pelo mesmo host usado no navegador.

Quando o LegislaGD sobe o SIGI-SD, o Traefik proprio do SIGI fica em profile `standalone` para evitar conflito na porta 80. Se for trabalhar dentro de `C:\LegislaGD\modules\SIGI-SD` sem o LegislaGD, os comandos originais do SIGI continuam disponiveis.
