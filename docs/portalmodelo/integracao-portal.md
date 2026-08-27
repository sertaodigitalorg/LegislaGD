# Integracao PortalModelo-SD

PortalModelo-SD consome publicacoes institucionais e dados legislativos por contratos estaveis.

## Atendimento publico

Na comunicacao unica da Camara, o PortalModelo-SD deve atuar como fachada
publica dos canais oficiais:

- publicar e-mail institucional de atendimento;
- publicar link ou botao de WhatsApp oficial quando autorizado;
- embarcar widget webchat do Chatwoot quando configurado;
- apontar formularios ou chamadas publicas para o fluxo SIGI-SD/Chatwoot;
- nao expor tokens, segredos de webhook ou URLs internas.

O detalhamento tecnico do fluxo esta em
`docs/sigi-sd/comunicacao-unica-camara.md`.

## Migracao do site original

O roteiro tecnico para migrar informacoes de um Portal Modelo original da
Interlegis para o PortalModelo-SD local esta em
`docs/portalmodelo/migracao-conteudo-site-original.md`.
