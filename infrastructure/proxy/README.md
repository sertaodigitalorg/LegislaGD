# Proxy

O proxy central do LegislaGD usa Traefik para rotear os modulos integrados no
ambiente local.

## Entradas locais

| Host | Uso |
| --- | --- |
| `legislagd.localhost` | Painel operacional central do LegislaGD |
| `proxy.legislagd.localhost` | Dashboard tecnico do Traefik |
| `traefik.legislagd.localhost` | Alias do dashboard tecnico do Traefik |

O painel central e servido pelo container `legislagd-dashboard`, com arquivos
estaticos em `infrastructure/proxy/dashboard`.
