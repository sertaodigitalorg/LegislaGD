# Relatorio da estrutura inicial

Data: 2026-08-02

## Arquivos criados

- `README.md`
- `docs/inventario-repositorios.md`
- `docs/governanca/estrategia-de-forks.md`
- `scripts/clone-components.sh`
- `scripts/check-repositories.sh`
- `docs/relatorio-estrutura-inicial.md`

## Decisoes registradas

- e-Cidade-SD pode ser reiniciado a partir de `https://github.com/DBSeller/e-cidade.git`, conforme autorizacao do usuario.
- SAPL-SD deve iniciar a partir de `https://github.com/interlegis/sapl.git`.
- PortalModelo-SD deve iniciar a partir de `https://github.com/interlegis/portalmodelo.git`.
- Qualquer outro fork deve ser perguntado ao usuario antes de ser criado ou configurado.
- SIGI-SD e mantido pelas equipes do Sertao Digital e nao depende de upstream externo nesta etapa.
- Scripts locais nao executam reset, nao apagam diretorios e nao alteram branches automaticamente.

## Publicacoes realizadas

- `sertaodigitalorg/LegislaGD`: publicado `main` com a estrutura inicial do agregador.
- `sertaodigitalorg/SAPL-SD`: publicado `main` a partir de `interlegis/sapl`, branch local `3.1.x`.
- `sertaodigitalorg/PortalModelo-SD`: publicado `main` a partir de `interlegis/portalmodelo`, branch local `master`.
- `sertaodigitalorg/e-Cidade-SD`: branch `main` reinicializada com `--force-with-lease` a partir de `DBSeller/e-cidade`, commit `000194437f016c436b26c656dd1eee7ab6778f8c`.
- `sertaodigitalorg/SIGI-SD`: preservado sem push, por ser repositorio proprio mantido pelas equipes do Sertao Digital.

## Limitacoes encontradas

- O ambiente possui `git`.
- O GitHub CLI foi instalado em `C:\Program Files\GitHub CLI\gh.exe` e autenticado como `wellingtoncs`.
- Antes da publicacao, `SAPL-SD` e `PortalModelo-SD` responderam sem refs publicas visiveis em `sertaodigitalorg`.
- Os diretorios irmaos foram baixados em `C:\SAPL-SD`, `C:\PortalModelo-SD`, `C:\e-Cidade-SD` e `C:\SIGI-SD`.
- O clone local do e-Cidade-SD no Windows apresenta 8 modificacoes aparentes por conflito de nomes sensiveis a maiusculas/minusculas e normalizacao de checkout. O Windows negou habilitar case-sensitive em `C:\e-Cidade-SD`.
- Ao publicar e-Cidade-SD, o GitHub alertou que `docker/database/ecidade_base.sql.gz` tem 68,90 MB, acima da recomendacao de 50 MB. O arquivo foi aceito, mas deve ser avaliado para Git LFS ou outra estrategia futura.

## Repositorios baixados

- `C:\SAPL-SD`: base `interlegis/sapl`, branch local `3.1.x`, `origin` apontando para `sertaodigitalorg/SAPL-SD` e `upstream` apontando para `interlegis/sapl`.
- `C:\PortalModelo-SD`: base `interlegis/portalmodelo`, branch local `master`, `origin` apontando para `sertaodigitalorg/PortalModelo-SD` e `upstream` apontando para `interlegis/portalmodelo`.
- `C:\e-Cidade-SD`: base `DBSeller/e-cidade`, branch local `master`, `origin` apontando para `sertaodigitalorg/e-Cidade-SD` e `upstream` apontando para `DBSeller/e-cidade`; checkout local requer WSL/Linux ou diretorio case-sensitive para ficar totalmente limpa.
- `C:\SIGI-SD`: repositorio proprio `sertaodigitalorg/SIGI-SD`, branch local `main`.

## Proximos passos

1. Executar inventario profundo de licencas, frameworks, bancos, Docker, pipelines, testes e dependencias.
2. Avaliar Git LFS ou estrategia alternativa para arquivos grandes do e-Cidade-SD.
3. Configurar protecoes de branch e revisoes obrigatorias nos repositorios publicados.
4. Definir licenca final do agregador apos compatibilidade entre componentes.

## Comandos sugeridos para commit

```bash
git status --short
git add README.md docs scripts
git commit -m "docs: registra estrategia inicial de forks"
```
