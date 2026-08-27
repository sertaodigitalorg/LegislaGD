# Integracao SIGI-SD

SIGI-SD integra atendimentos com SAPL-SD, PortalModelo-SD e e-Cidade-SD por APIs, eventos ou filas.

## Comunicacao unica

O desenho tecnico local para unificar e-mail, WhatsApp, webchat e demais canais
oficiais da Camara esta em
`docs/sigi-sd/comunicacao-unica-camara.md`.

Resumo do limite de responsabilidade:

- PortalModelo-SD publica os canais oficiais.
- Chatwoot recebe e opera as conversas.
- SIGI-SD importa conversas, gera protocolo, vincula cadastros e audita.
- SAPL-SD e e-Cidade-SD recebem encaminhamentos por contrato quando necessario.
