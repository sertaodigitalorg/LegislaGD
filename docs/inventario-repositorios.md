# Inventario inicial dos repositorios

Data da inspecao: 2026-08-02

Este inventario registra apenas informacoes confirmadas por consulta Git publica e pela inspecao local do workspace. Nenhum push, reset ou alteracao de historico remoto foi executado.

## LegislaGD

- Repositorio oficial: https://github.com/sertaodigitalorg/LegislaGD.git
- Diretorio local: `C:\LegislaGD`
- Branch local: `main`
- Status: publicado em `sertaodigitalorg/LegislaGD`, branch `main`
- Papel: agregador do ecossistema, documentacao, governanca, infraestrutura e integracoes
- Upstream externo: nao aplicavel

## SAPL-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/SAPL-SD.git
- Origem autorizada pelo usuario: https://github.com/interlegis/sapl.git
- Consulta ao repositorio oficial: sem branches publicas visiveis na consulta `git ls-remote`
- Branch local baixada: `3.1.x`
- Situacao: publicado em `sertaodigitalorg/SAPL-SD`, branch remota `main`
- Observacao: nao criar fork adicional sem confirmacao previa do usuario

## PortalModelo-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/PortalModelo-SD.git
- Origem autorizada pelo usuario: https://github.com/interlegis/portalmodelo.git
- Consulta ao repositorio oficial: sem branches publicas visiveis na consulta `git ls-remote`
- Branch local baixada: `master`
- Situacao: publicado em `sertaodigitalorg/PortalModelo-SD`, branch remota `main`
- Observacao: nao criar fork adicional sem confirmacao previa do usuario

## e-Cidade-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/e-Cidade-SD.git
- Fonte canonica: https://github.com/DBSeller/e-cidade.git
- Branch publica atual no repositorio oficial: `main`
- Branch local baixada: `master`
- Situacao: branch `main` reinicializada a partir da fonte canonica `DBSeller/e-cidade` com `--force-with-lease`
- Commit publicado: `000194437f016c436b26c656dd1eee7ab6778f8c`
- Verificacao: `sertaodigitalorg/e-Cidade-SD/main` e `DBSeller/e-cidade/master` apontam para o mesmo commit
- Observacao Windows: a checkout local apresenta modificacoes aparentes causadas por sensibilidade a maiusculas/minusculas; usar WSL/Linux ou diretorio case-sensitive para publicacao limpa.

## SIGI-SD

- Repositorio oficial: https://github.com/sertaodigitalorg/SIGI-SD.git
- Branch publica atual: `main`
- Origem upstream: nao aplicavel nesta etapa
- Situacao: sistema mantido pelas equipes do Sertao Digital; nao alterado nesta etapa

## Pendencias de inspecao profunda

- Inspecionar licencas, frameworks, bancos, Docker, pipelines, testes e dependencias nos diretorios baixados.
- Confirmar se `SAPL-SD` e `PortalModelo-SD` estao vazios ou privados com refs nao publicas.
- Definir procedimento autenticado para criar ou reinicializar forks na organizacao `sertaodigitalorg`, se necessario.
