# Inventario inicial dos repositorios

Data da inspecao: 2026-08-02

Este inventario registra apenas informacoes confirmadas por consulta Git publica e pela inspecao local do workspace. Nenhum push, reset ou alteracao de historico remoto foi executado.

## LegislaGD

- Repositorio oficial: https://github.com/sertaodigitalorg/LegislaGD.git
- Diretorio local: `C:\LegislaGD`
- Branch local: `main`
- Status local antes da estruturacao: repositorio sem commits locais
- Papel: agregador do ecossistema, documentacao, governanca, infraestrutura e integracoes
- Upstream externo: nao aplicavel

## SAPL-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/SAPL-SD.git
- Origem autorizada pelo usuario: https://github.com/interlegis/sapl.git
- Consulta ao repositorio oficial: sem branches publicas visiveis na consulta `git ls-remote`
- Branch local baixada: `3.1.x`
- Situacao: fork/distribuicao preparado localmente a partir de `interlegis/sapl`
- Observacao: nao criar fork adicional sem confirmacao previa do usuario

## PortalModelo-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/PortalModelo-SD.git
- Origem autorizada pelo usuario: https://github.com/interlegis/portalmodelo.git
- Consulta ao repositorio oficial: sem branches publicas visiveis na consulta `git ls-remote`
- Branch local baixada: `master`
- Situacao: fork/distribuicao preparado localmente a partir de `interlegis/portalmodelo`
- Observacao: nao criar fork adicional sem confirmacao previa do usuario

## e-Cidade-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/e-Cidade-SD.git
- Origem autorizada pelo usuario: https://github.com/DBSeller/e-cidade.git
- Branch publica atual no repositorio oficial: `main`
- Branch local baixada: `master`
- Situacao: o usuario autorizou zerar/reiniciar o Git do e-Cidade-SD e iniciar a partir da origem `DBSeller/e-cidade`; a base foi preparada localmente
- Limite: nao foi executado reset, force push ou substituicao de historico remoto nesta etapa
- Observacao Windows: a checkout local apresenta modificacoes aparentes causadas por sensibilidade a maiusculas/minusculas; usar WSL/Linux ou diretorio case-sensitive para publicacao limpa.

## SIGI-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/SIGI-SD.git
- Branch publica atual: `main`
- Origem upstream: nao aplicavel nesta etapa
- Situacao: sistema mantido pelas equipes do Sertao Digital

## Pendencias de inspecao profunda

- Inspecionar licencas, frameworks, bancos, Docker, pipelines, testes e dependencias nos diretorios baixados.
- Confirmar se `SAPL-SD` e `PortalModelo-SD` estao vazios ou privados com refs nao publicas.
- Definir procedimento autenticado para criar ou reinicializar forks na organizacao `sertaodigitalorg`, se necessario.
