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
| e-Cidade-SD | https://github.com/sertaodigitalorg/e-Cidade-SD.git | https://github.com/DBSeller/e-cidade.git |

## e-Cidade-SD

O usuario autorizou que o Git do e-Cidade-SD seja zerado/reiniciado e que a distribuicao comece a partir de `DBSeller/e-cidade`.

Essa autorizacao nao implica executar automaticamente `git push --force`. A acao remota deve ser feita com cuidado, idealmente por um procedimento autenticado e revisado, porque substitui historico no repositorio oficial.

Procedimento recomendado:

1. Confirmar backup ou ausencia de historico relevante em `sertaodigitalorg/e-Cidade-SD`.
2. Clonar `DBSeller/e-cidade` em um ambiente limpo.
3. Configurar `origin` como `sertaodigitalorg/e-Cidade-SD`.
4. Configurar `upstream` como `DBSeller/e-cidade`.
5. Publicar a branch principal da distribuicao somente apos revisao.

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

## Forks ainda nao confirmados

SIGI-SD e mantido pelas equipes do Sertao Digital. Atualizacoes sao feitas pelas equipes internas, sem upstream externo nesta etapa.
