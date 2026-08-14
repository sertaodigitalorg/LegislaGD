# Estrategia de forks

Esta estrategia preserva os projetos originais, seus creditos, licencas e historicos, mantendo as distribuicoes do Sertao Digital como forks ou derivados rastreaveis.

## Regras gerais

- Usar somente os repositorios oficiais do ecossistema LegislaGD em `sertaodigitalorg`.
- Nao criar forks adicionais sem confirmacao previa do usuario.
- Nao executar `git push --force` sem uma decisao formal e autorizacao explicita.
- Nao remover licencas, autores, creditos ou referencias aos projetos originais.
- Preferir branches de sincronizacao e merges auditaveis.
- Registrar toda divergencia mantida pelo Sertao Digital.

## Origens autorizadas nesta etapa

| Distribuicao | Repositorio Sertao Digital | Upstream autorizado |
| --- | --- | --- |
| SAPL-SD | https://github.com/sertaodigitalorg/SAPL-SD.git | https://github.com/interlegis/sapl.git |
| PortalModelo-SD | https://github.com/sertaodigitalorg/PortalModelo-SD.git | https://github.com/interlegis/portalmodelo.git |
| Chatwoot-SD | https://github.com/sertaodigitalorg/Chatwoot-SD.git | https://github.com/chatwoot/chatwoot.git |
| e-Cidade-SD | https://github.com/sertaodigitalorg/e-Cidade-SD.git | https://github.com/DBSeller/e-cidade.git |

## e-Cidade-SD

`DBSeller/e-cidade` e a fonte canonica do e-Cidade-SD. O repositorio `sertaodigitalorg/e-Cidade-SD` deve ser tratado como fork/distribuicao derivada dele.

O estado anterior de `sertaodigitalorg/e-Cidade-SD` estava desatualizado e nao possuia alteracoes proprias a preservar nesta etapa.

Procedimento aplicado nesta etapa:

1. Clonar `DBSeller/e-cidade`.
2. Configurar `origin` como `sertaodigitalorg/e-Cidade-SD`.
3. Configurar `upstream` como `DBSeller/e-cidade`.
4. Reinicializar `sertaodigitalorg/e-Cidade-SD/main` a partir de `DBSeller/e-cidade/master`.

## SAPL-SD e PortalModelo-SD

SAPL-SD deve iniciar a partir de `interlegis/sapl` e PortalModelo-SD deve iniciar a partir de `interlegis/portalmodelo`, se os repositorios oficiais estiverem vazios ou ainda nao inicializados.

Fluxo conceitual:

```text
upstream/projeto-original
        |
        v
sync/upstream
        |
        v
develop
        |
        v
main
```

## Chatwoot-SD

Chatwoot-SD e o fork controlado do Chatwoot Community para integracoes do
LegislaGD/SIGI-SD, inicialmente SSO com Keycloak/OIDC e melhorias de IA.

O fork deve acompanhar o upstream `chatwoot/chatwoot`, mantendo patches pequenos
e removendo customizacoes quando a Community Edition oferecer recurso
equivalente.

As branches oficiais do fork seguem o padrao LegislaGD: `dev`, `hml` e `main`.

## Forks ainda nao confirmados

SIGI-SD e mantido pelas equipes do Sertao Digital. Atualizacoes sao feitas pelas equipes internas, sem upstream externo nesta etapa.
