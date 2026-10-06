# Refinamento da experiencia LegislaGD

Data: 2026-08-30

## Objetivo

Organizar a evolucao de layout, navegacao, estrutura e login do LegislaGD a
partir do ambiente integrado ja instalado, preservando a arquitetura modular da
plataforma legislativa.

## Premissas tecnicas

- O LegislaGD coordena componentes independentes e nao deve virar monolito.
- O Keycloak Legislativo e a autoridade central de identidade.
- Login local administrativo deve ser preservado durante a implantacao SSO.
- Permissoes reais continuam protegidas nos sistemas de destino.
- Integracoes devem ocorrer por contratos, APIs, eventos ou adaptadores
  controlados, sem acoplamento direto por banco.
- Decisoes funcionais devem ser sincronizadas com o MASTER funcional no Drive ou
  registradas como handoff pendente.

## Estado inicial observado

Ambiente local integrado validado por `make ps` em WSL:

| Componente | Estado |
| --- | --- |
| PostgreSQL central | ativo |
| Traefik | ativo |
| Keycloak | ativo e healthy |
| PortalModelo-SD | ativo |
| SAPL-SD | ativo |
| Plenario-Digital-Core | ativo |
| SIGI-SD admin | ativo |
| Chatwoot-SD | ativo |
| e-Cidade-SD | ativo e healthy |

Validacao HTTP inicial por `scripts/test-wsl-stack.sh`:

| URL | Resultado |
| --- | --- |
| `http://portal.legislagd.localhost` | 200 |
| `http://sapl.legislagd.localhost` | 200 |
| `http://sigi.legislagd.localhost` | 200 |
| `http://ecidade.legislagd.localhost` | 302 |
| `http://chat.sigi.legislagd.localhost` | 200 |
| `http://qdrant.sigi.legislagd.localhost/collections` | 200 |
| `http://ia.sigi.legislagd.localhost/api/version` | 200 |

## Primeira intervencao aplicada

`http://legislagd.localhost` deixou de apontar para o dashboard tecnico do
Traefik e passou a servir um painel operacional central do LegislaGD.

Alteracoes:

- Novo servico `dashboard` no compose do proxy.
- Novo container `legislagd-dashboard`, baseado em Nginx.
- Arquivos estaticos em `infrastructure/proxy/dashboard`.
- Traefik restrito aos hosts `proxy.legislagd.localhost` e
  `traefik.legislagd.localhost`.

Validacao apos a alteracao:

| URL | Resultado |
| --- | --- |
| `http://legislagd.localhost` | 200, titulo `LegislaGD`, H1 `Painel operacional da plataforma legislativa` |
| `http://proxy.legislagd.localhost` | 200, dashboard Traefik |
| `http://id.legislagd.localhost` | 200, console Keycloak |
| `http://portal.legislagd.localhost` | 200 |
| `http://sapl.legislagd.localhost` | 200 |
| `http://plenario.legislagd.localhost` | 200, login admin Django |
| `http://sigi.legislagd.localhost` | 200 |
| `http://chat.sigi.legislagd.localhost` | 200 |
| `http://ecidade.legislagd.localhost` | 200 apos redirect para `login.php` |

## Segunda intervencao aplicada

Refinamento inicial do login/SSO nos modulos SAPL-SD e e-Cidade-SD.

### SAPL-SD

Alteracoes no repositorio `modules/SAPL-SD`:

- Tela de login reorganizada com titulo `Entrar no SAPL-SD`.
- Acao SSO destacada como `Entrar com LegislaGD`.
- Login local mantido como `Acesso local`.
- Mensagem de erro local simplificada para usuario/senha invalidos.
- Template deixou de inserir uma tag `<head>` dentro do corpo da pagina.
- Teste de redirecionamento para login passou a reconhecer o formulario por
  `id="login-form"`, evitando dependencia de texto visual do botao.

Validacao:

- `docker exec sapl-dev python manage.py check`: sem problemas.
- HTML de `http://sapl.legislagd.localhost/login/` contem:
  - `Entrar no SAPL-SD`;
  - `Entrar com LegislaGD`;
  - `Acesso local`;
  - `Entrar com acesso local`;
  - `id="login-form"`.

### e-Cidade-SD

Alteracoes no repositorio `modules/e-Cidade-SD`:

- Pacote fonte `ecidade/extension/package/Legislagdsso` ajustado para exibir o
  SSO em um bloco visual proprio.
- Botao `Entrar com LegislaGD` padronizado com a cor central do LegislaGD.
- Texto auxiliar adicionado: `Identidade central do Poder Legislativo.`
- XML validado por parser .NET.

Limite operacional encontrado:

- A tela em execucao do e-Cidade usa uma modification SSO ja aplicada
  anteriormente.
- Reiniciar o container nao reaplicou a versao nova do XML do pacote fonte.
- A tela ativa segue mostrando o botao `Entrar com LegislaGD`, mas ainda no
  estilo anterior.

Pendencia:

- Identificar e documentar o comando seguro de reaplicacao/atualizacao de
  modifications do e-Cidade antes de forcar a troca visual em runtime.
- Evitar duplicar o botao diretamente em `templates/template_login_e-cidade.php`
  enquanto a extension ja injeta o SSO.

## Frentes de refinamento

### 1. Entrada central

Criar uma experiencia inicial clara para `http://legislagd.localhost`, com
navegacao por perfil e links para os modulos. Esta entrada deve ser operacional,
nao uma landing page promocional.

Entregas:

- Tela inicial da plataforma.
- Atalhos para Portal, SAPL, Plenario, SIGI/Chatwoot, e-Cidade e Keycloak.
- Estados visuais para modulo disponivel, restrito ou em manutencao.
- Base visual reutilizavel para os refinamentos seguintes.

### 2. Login e identidade

Padronizar o fluxo `Entrar com LegislaGD` nos sistemas integrados, mantendo
rotas locais de contingencia durante a fase de validacao.

Entregas:

- Linguagem padrao para login central.
- Mensagens amigaveis para acesso negado, sessao expirada e usuario sem perfil.
- Testes de usuario com e sem role.
- Checklist de logout local e central.

### 3. Navegacao entre modulos

Reduzir a sensacao de sistemas soltos, sem criar dependencia indevida entre os
repositorios.

Entregas:

- Cabecalho/atalho consistente onde for seguro alterar.
- Links de retorno para a entrada central.
- Mapa de navegacao por perfil.
- Registro de limites quando o modulo legado nao permitir alteracao limpa.

### 4. Layout dos fluxos criticos

Priorizar telas de maior impacto operacional.

Prioridade inicial:

1. Entrada central LegislaGD.
2. Login Keycloak e botoes de SSO nos modulos.
3. Painel inicial do SAPL-SD.
4. Painel/saude operacional do Plenario Digital.
5. Admin do SIGI-SD e entrada de atendimento.
6. Entrada do e-Cidade-SD.

### 5. Testes e homologacao

Cada refinamento deve sair com evidencia minima.

Checklist:

- URL responde pelo Traefik.
- Tela carrega em desktop e mobile.
- Texto nao sobrepoe outros elementos.
- Fluxo anonimo funciona quando aplicavel.
- Fluxo autenticado funciona com usuario de teste.
- Usuario sem role nao ganha acesso indevido.
- Login local de contingencia continua disponivel quando previsto.
- Logs nao exibem senha, token completo ou client secret.

## Primeira intervencao recomendada

Prosseguir com o refinamento visual do login central no Keycloak e com a
documentacao do mecanismo seguro de reaplicacao das modifications do e-Cidade.

## Comandos de apoio

```bash
make urls
make ps
scripts/test-wsl-stack.sh
scripts/audit-ui-stack.sh
```

No Windows deste ambiente, execute os comandos via WSL:

```powershell
wsl -d Ubuntu-24.04 --cd /mnt/c/LegislaGD make urls
wsl -d Ubuntu-24.04 --cd /mnt/c/LegislaGD make ps
wsl -d Ubuntu-24.04 --cd /mnt/c/LegislaGD scripts/test-wsl-stack.sh
wsl -d Ubuntu-24.04 --cd /mnt/c/LegislaGD scripts/audit-ui-stack.sh
```
