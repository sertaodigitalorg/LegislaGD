# Keycloak

Infraestrutura de identidade do LegislaGD.

O Keycloak roda como componente self-hosted da plataforma legislativa e usa banco e usuario proprios dentro do PostgreSQL central do LegislaGD. Ele nao deve compartilhar schema nem credenciais com SAPL-SD, SIGI-SD, Chatwoot ou e-Cidade-SD.

Arquivos principais:

- `infrastructure/compose/docker-compose.keycloak.yml`
- `config/keycloak/realms/legislagd-realm.json`

Comandos:

```bash
make up keycloak
make ps keycloak
make logs keycloak
make down keycloak
```

URL local:

```text
http://id.legislagd.localhost
```

O realm inicial e `legislagd`. As integracoes de aplicacao devem ser habilitadas uma por vez, com SAPL-SD como primeiro piloto.
