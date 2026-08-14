# Chatwoot-SD e SSO LegislaGD

## Decisao

O LegislaGD usara o fork `sertaodigitalorg/Chatwoot-SD` para evoluir o
Chatwoot Community com integracoes proprias, incluindo SSO com Keycloak,
melhorias de IA e integracoes com o SIGI-SD.

O fork deve permanecer o mais proximo possivel do upstream `chatwoot/chatwoot`.
Quando recursos equivalentes forem liberados na Community Edition, a preferencia
sera remover patches proprios e reutilizar a implementacao upstream.

## Repositorios

| Papel | Repositorio |
| --- | --- |
| Fork LegislaGD | `https://github.com/sertaodigitalorg/Chatwoot-SD.git` |
| Upstream | `https://github.com/chatwoot/chatwoot.git` |
| Branches LegislaGD | `dev`, `hml`, `main` |
| Branch upstream acompanhada | `develop` |
| Checkout local | `modules/SIGI-SD/apps/chatwoot-sd` |

As branches de trabalho seguem o padrao do ecossistema LegislaGD:

| Ambiente | Branch |
| --- | --- |
| Desenvolvimento local | `dev` |
| Homologacao | `hml` |
| Producao/base principal | `main` |

## Escopo da fase 3

1. Usar `Chatwoot-SD`, clonado dentro do SIGI-SD em `apps/chatwoot-sd`, como
   fonte da imagem local do Chatwoot no ambiente integrado.
2. Criar client OIDC `chatwoot` no realm `legislagd`.
3. Implementar login OIDC no Chatwoot-SD usando o maximo possivel do padrao
   interno existente de autenticacao social/OmniAuth.
4. Exibir botao `Entrar com LegislaGD` na tela de login do Chatwoot.
5. Vincular usuario por `sub` OIDC e, no piloto, permitir associacao inicial por
   e-mail validado.
6. Mapear roles macro do Keycloak para permissoes do Chatwoot:
   - `chatwoot.admin`
   - `chatwoot.agent`

## Client Keycloak previsto

| Campo | Valor local |
| --- | --- |
| Client ID | `chatwoot` |
| Tipo | OIDC confidencial |
| Redirect URI | `http://chat.sigi.legislagd.localhost/*` |
| Web Origin | `http://chat.sigi.legislagd.localhost` |
| Issuer | `http://id.legislagd.localhost/realms/legislagd` |

O segredo do client nao deve ser commitado. Em desenvolvimento local, pode ser
exposto por variavel no `.env`; em homologacao/producao deve vir de secret do
ambiente.

## Modelo de autenticacao alvo

Fluxo esperado:

```text
Usuario logado no SAPL via Keycloak
abre Central de Atendimento
Chatwoot exibe Entrar com LegislaGD
Chatwoot redireciona para Keycloak
Keycloak reaproveita a sessao existente
Chatwoot cria sessao propria e abre a interface
```

O login local do Chatwoot deve permanecer disponivel para contingencia
administrativa durante o piloto.

## Implementacao tecnica prevista no Chatwoot-SD

Pontos a investigar/alterar no fork:

- configuracoes de instalacao para habilitar o provider LegislaGD;
- estrategia OmniAuth/OIDC para Keycloak;
- rota de callback;
- service para localizar/criar usuario por identidade externa;
- persistencia de `provider`, `uid/sub`, e-mail e ultimo login;
- mapeamento de roles para `administrator` ou `agent`;
- componente de login para exibir `Entrar com LegislaGD`.

Variaveis previstas:

```env
CHATWOOT_OIDC_ENABLED=true
CHATWOOT_OIDC_PROVIDER_NAME=legislagd
CHATWOOT_OIDC_DISPLAY_NAME=LegislaGD
CHATWOOT_OIDC_ISSUER=http://id.legislagd.localhost/realms/legislagd
CHATWOOT_OIDC_CLIENT_ID=chatwoot
CHATWOOT_OIDC_CLIENT_SECRET=change_me
CHATWOOT_OIDC_SCOPES=openid email profile
```

## Criterios de aceite

- Chatwoot-SD sobe pela orquestracao do LegislaGD.
- Login local do Chatwoot segue funcional.
- Botao `Entrar com LegislaGD` aparece apenas quando OIDC estiver habilitado.
- Usuario autenticado no Keycloak entra no Chatwoot sem redigitar senha quando a
  sessao central ja existe.
- Usuario sem role `chatwoot.*` nao ganha acesso indevido.
- Nenhum token completo ou segredo aparece em log.

## Rollback

- Voltar `CHATWOOT_SD_IMAGE` para imagem publicada anterior ou remover o build
  local no override.
- Desabilitar `CHATWOOT_OIDC_ENABLED`.
- Manter banco e login local do Chatwoot intactos.
