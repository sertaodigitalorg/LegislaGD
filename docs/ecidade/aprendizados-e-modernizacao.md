# Aprendizados e modernizacao do e-Cidade-SD

Este documento registra descobertas feitas durante a operacao e a integracao do e-Cidade-SD no LegislaGD. Ele deve ser atualizado continuamente conforme o trabalho avancar por processo, setor, modulo e fluxo de usuario.

## Objetivo

- Consolidar conhecimento tecnico e funcional aprendido durante a implantacao.
- Separar fatos observados de hipoteses de melhoria.
- Apoiar futuras evolucoes, incluindo SSO, atualizacao de PHP, uso maior de classes e reducao gradual de codigo legado procedural.
- Preservar rastreabilidade sem transformar o e-Cidade-SD em dependencia interna do LegislaGD.

## Padrao de registro

Cada descoberta deve informar:

- Data e contexto.
- Processo, setor ou modulo afetado.
- Evidencia observada em codigo, banco, log ou tela.
- Decisao ou ajuste aplicado.
- Risco conhecido.
- Possivel melhoria futura.

## Aprendizados atuais

### Login local e sessao legada

Data: 2026-08-27.

Contexto: validacao inicial do e-Cidade-SD em ambiente local integrado ao LegislaGD.

Evidencias:

- `login.php` monta a tela de login e inclui o template definido em `config/require_extensions.xml`.
- `login.php` envia credenciais para `abrir.php` usando `sAuth`.
- A senha e transformada em MD5 no cliente antes do envio.
- `abrir.php` valida o usuario local em `configuracoes.db_usuarios`.
- Depois da validacao, `abrir.php` cria variaveis de sessao `DB_*`, incluindo `DB_login`, `DB_id_usuario`, `DB_administrador`, `DB_base`, `DB_user` e `DB_senha`.
- `libs/db_conecta.php` considera a sessao invalida quando `DB_login` ou `DB_id_usuario` nao existem.
- A extensao Desktop completa instituicao, exercicio, data e departamento depois da sessao basica existir.

Decisao:

- Manter o login local como contingencia administrativa.
- Implementar SSO por adaptador OIDC separado, sem reescrever `abrir.php`, permissoes por menu ou estrutura principal de usuarios nesta fase.

Riscos:

- Criar sessao parcial sem respeitar as variaveis `DB_*` pode quebrar Desktop, menus, auditoria e rotinas internas.
- Roles do Keycloak nao substituem permissoes detalhadas do e-Cidade.

Melhoria futura:

- Extrair a criacao de sessao de `abrir.php` para uma classe/servico reutilizavel pelo login local e pelo adaptador SSO.

### Bootstrap local em PostgreSQL moderno

Data: 2026-08-27.

Contexto: execucao de `make initial-load-ecidade` em ambiente local com PostgreSQL atual.

Evidencias:

- A carga base do e-Cidade contem comandos e funcoes antigas que exigem compatibilidade com versoes anteriores do PostgreSQL.
- O codigo legado usa textos ISO-8859-1/Latin1 em pontos de auditoria.
- O banco local integrado estava em UTF-8, exigindo cuidado com `client_encoding`.

Decisao:

- Ajustar o script de carga para tratar incompatibilidades conhecidas do PostgreSQL atual.
- Configurar `client_encoding` do usuario de aplicacao para `LATIN1`, permitindo conversao pelo PostgreSQL.
- Garantir criacao de `libs/db_acessa.php` a partir de `libs/db_acessa.php.dist`.
- Garantir existencia e permissao de `extension/log/error.log`.

Riscos:

- Mudancas globais de encoding devem ficar restritas ao ambiente e usuario do e-Cidade.
- Atualizacoes futuras do dump podem exigir novos sanitizadores.

Melhoria futura:

- Criar testes automatizados de smoke para carga inicial, login e abertura do Desktop.
- Documentar uma matriz de compatibilidade PostgreSQL por dump/base.

### Composer e ambiente legado PHP

Data: 2026-08-27.

Contexto: instalacao de dependencias PHP no volume montado do e-Cidade-SD.

Evidencias:

- O Composer falhava ao remover diretorios temporarios em `vendor/composer`.
- O fluxo de instalacao tambem podia travar em scripts de pos-instalacao.

Decisao:

- Executar `composer install` com ambiente controlado e `--no-scripts`.
- Manter scripts especificos do Desktop rodando depois, de forma explicita.

Riscos:

- O e-Cidade combina PHP 5.6, Laravel 5.4, codigo procedural e dependencias antigas; atualizacao direta para PHP 8 e de alto risco.

Melhoria futura:

- Mapear dependencias bloqueantes para PHP 8.
- Separar camadas: bootstrap, autenticacao, sessao, banco, auditoria, menu e dominio.
- Introduzir classes adaptadoras pequenas antes de qualquer refatoracao ampla.

## SSO LegislaGD

Direcao tecnica:

- Usar Keycloak como provedor OIDC do LegislaGD.
- Usar o client Keycloak `ecidade`.
- Adicionar botao `Entrar com LegislaGD` na tela de login.
- Criar endpoints separados para iniciar login OIDC e receber callback.
- Validar token OIDC antes de criar sessao local.
- Vincular `sub` OIDC a `configuracoes.db_usuarios` por tabela auxiliar.
- Permitir vinculacao inicial por e-mail ou CPF/CNPJ apenas em migracao controlada.
- Exigir usuario local ativo, com departamento e permissoes locais existentes.

Fora de escopo nesta fase:

- Remover login local.
- Usar senha local para simular SSO.
- Substituir permissoes de menu por roles Keycloak.
- Fazer auto-provisionamento amplo sem regra funcional aprovada.

### Estrategia de fork minimo para SSO

Data: 2026-08-27.

Contexto: definicao de como aplicar SSO LegislaGD no e-Cidade-SD sem espalhar alteracoes pelo codigo legado original.

Evidencias:

- O e-Cidade possui mecanismo proprio de `extension` em `extension/package`.
- O e-Cidade possui mecanismo de `modification`, com comandos `modification:*` e XMLs em `modification/xml`.
- `login.php` carrega o template de login definido em `config/require_extensions.xml`.
- `login.php` chama `modification($sScriptLogin)` antes de incluir o template.
- `abrir.php` concentra validacao local e criacao das variaveis de sessao `DB_*`.

Decisao proposta:

- Criar um pacote isolado `extension/package/Legislagdsso` para todo codigo novo de SSO.
- Usar `modification` apenas para inserir o botao `Entrar com LegislaGD` no template de login ou, se o patch ficar fragil, manter uma alteracao minima e documentada no template.
- Evitar alteracao direta em `abrir.php` na primeira fase.
- Criar um adaptador de sessao que reproduza somente a parte necessaria da sessao legada apos validar o token OIDC.
- Guardar vinculo OIDC em tabela auxiliar propria, sem alterar a estrutura principal de `configuracoes.db_usuarios` inicialmente.
- Manter login local como contingencia.

Estrutura sugerida:

```text
extension/package/Legislagdsso/
  Manifest.xml
  Controller/Auth.php
  Service/OidcClient.php
  Service/UserResolver.php
  Service/SessionBridge.php
  migration/
  modification/
```

Configuracoes sugeridas:

- `ECIDADE_OIDC_ENABLED`
- `ECIDADE_OIDC_ISSUER`
- `ECIDADE_OIDC_CLIENT_ID`
- `ECIDADE_OIDC_CLIENT_SECRET`
- `ECIDADE_OIDC_REDIRECT_URI`
- `ECIDADE_OIDC_SCOPES`
- `ECIDADE_OIDC_ALLOW_EMAIL_LINK`

Riscos:

- O mecanismo `modification` aplica alteracoes sobre arquivos originais ou cacheados; por isso, os XMLs devem ser pequenos, reprodutiveis e testados apos atualizacao do fork.
- Duplicar muita regra de `abrir.php` pode criar divergencia entre login local e SSO.
- Vinculo automatico por e-mail ou CPF/CNPJ deve ser controlado para evitar associacao indevida de identidade.

Melhoria futura:

- Extrair de `abrir.php` uma classe `SessionBridge` ou equivalente, usada tanto pelo login local quanto pelo SSO.
- Transformar o patch de login em ponto de extensao explicito, se o fork passar a manter contribuicoes proprias.
- Criar testes de smoke para: botao SSO visivel, callback OIDC, usuario inativo bloqueado, usuario sem departamento bloqueado, Desktop aberto com menus preservados.

### Implementacao inicial do pacote SSO

Data: 2026-08-27.

Contexto: primeira implementacao tecnica do SSO LegislaGD no fork e-Cidade-SD.

Arquivos principais:

- `extension/package/Legislagdsso/Manifest.xml`.
- `extension/package/Legislagdsso/Controller/Auth.php`.
- `extension/package/Legislagdsso/Service/Config.php`.
- `extension/package/Legislagdsso/Service/OidcClient.php`.
- `extension/package/Legislagdsso/Service/UserResolver.php`.
- `extension/package/Legislagdsso/Service/SessionBridge.php`.
- `extension/package/Legislagdsso/modifications/login-button.xml`.
- `extension/package/Legislagdsso/database/001_create_oidc_identity.sql`.

Fluxo implementado:

1. O botao `Entrar com LegislaGD` aparece no login somente quando `ECIDADE_OIDC_ENABLED` estiver ativo.
2. O botao envia o usuario para `/extension/legislagdsso/auth/login`.
3. A action `login` inicia Authorization Code Flow com PKCE no Keycloak.
4. A action `callback` valida `state`, `nonce`, `issuer`, `audience`, expiracao e assinatura RS256 do `id_token`.
5. O acesso exige role macro configurada em `ECIDADE_OIDC_ALLOWED_ROLES`.
6. O usuario local e resolvido por vinculo `provider + subject`; se ainda nao existir, pode ser vinculado por e-mail verificado ou login, conforme variaveis de ambiente.
7. O adaptador exige usuario local ativo e departamento existente.
8. O `SessionBridge` cria as variaveis `DB_*` necessarias e redireciona para o Desktop.

Variaveis adicionadas no LegislaGD:

- `ECIDADE_OIDC_ENABLED`
- `ECIDADE_OIDC_ISSUER`
- `ECIDADE_OIDC_WELL_KNOWN_URL`
- `ECIDADE_OIDC_CLIENT_ID`
- `ECIDADE_OIDC_CLIENT_SECRET`
- `ECIDADE_OIDC_REDIRECT_URI`
- `ECIDADE_OIDC_UI_LOCALES`
- `ECIDADE_OIDC_ALLOW_EMAIL_LINK`
- `ECIDADE_OIDC_ALLOW_LOGIN_LINK`
- `ECIDADE_SSO_USER`
- `ECIDADE_SSO_PASSWORD`
- `ECIDADE_SSO_EMAIL`

Validacoes executadas:

- `php -l` nos arquivos PHP novos da extensao.
- Parse XML do `Manifest.xml`.
- Parse XML do `modifications/login-button.xml`.
- Extensao `Legislagdsso` instalada e ativa no container local junto com `Desktop`.
- Botao `Entrar com LegislaGD` visivel em `login.php`.
- Inicio do SSO redirecionando para o client Keycloak `ecidade` com Authorization Code + PKCE.
- Login real validado pelo smoke `scripts/smoke-ecidade-sso.sh`.
- Callback validado ate redirecionar para `extension/desktop/`.
- Usuario sem role macro `ecidade.*` bloqueado antes de criar sessao local.
- Mapper `realm roles` do client scope `roles` ajustado para emitir `realm_access.roles` no `id_token`, pois o adaptador valida roles a partir do `id_token`.

Validacao pendente:

- Validar manualmente, no navegador, menus e permissoes internas do Desktop apos entrada por SSO.
- Configurar HTTPS local ou decisao explicita de excecao para ambientes HTTP de desenvolvimento; o smoke contorna cookies `Secure` do Keycloak apenas para teste automatizado local.

## Modernizacao futura

Diretrizes:

- Modernizar por bordas e contratos, nao por reescrita ampla.
- Preservar comportamento de sessoes, auditoria e permissoes antes de mudar estrutura interna.
- Criar classes pequenas para encapsular fluxos ja entendidos.
- Priorizar testes de smoke e regressao por modulo antes de atualizar runtime.

Possiveis frentes:

- `Auth`: login local, SSO, callback, logout e sessao.
- `Session`: criacao e validacao das variaveis `DB_*`.
- `Audit`: escrita em `db_logsacessa` e tratamento de encoding.
- `Menu`: permissao por modulo, instituicao, exercicio e item.
- `User`: vinculo entre Keycloak, `db_usuarios`, `db_usuacgm` e dados de CGM.
- `Bootstrap`: carga inicial, extensoes, arquivos `.dist`, permissao de logs e compatibilidade PostgreSQL.
