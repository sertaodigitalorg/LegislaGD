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

## Limitacoes encontradas

- O ambiente possui `git`.
- O GitHub CLI foi instalado em `C:\Program Files\GitHub CLI\gh.exe`, mas ainda nao esta autenticado.
- Nao foi criado fork remoto no GitHub porque `gh auth status` informou ausencia de login.
- Nao foi executado push nem force push.
- `SAPL-SD` e `PortalModelo-SD` responderam sem refs publicas visiveis em `sertaodigitalorg`.
- Os diretorios irmaos foram baixados em `C:\SAPL-SD`, `C:\PortalModelo-SD`, `C:\e-Cidade-SD` e `C:\SIGI-SD`.
- O clone local do e-Cidade-SD no Windows apresenta 8 modificacoes aparentes por conflito de nomes sensiveis a maiusculas/minusculas e normalizacao de checkout. O Windows negou habilitar case-sensitive em `C:\e-Cidade-SD`.

## Repositorios baixados

- `C:\SAPL-SD`: base `interlegis/sapl`, branch local `3.1.x`, `origin` apontando para `sertaodigitalorg/SAPL-SD` e `upstream` apontando para `interlegis/sapl`.
- `C:\PortalModelo-SD`: base `interlegis/portalmodelo`, branch local `master`, `origin` apontando para `sertaodigitalorg/PortalModelo-SD` e `upstream` apontando para `interlegis/portalmodelo`.
- `C:\e-Cidade-SD`: base `DBSeller/e-cidade`, branch local `master`, `origin` apontando para `sertaodigitalorg/e-Cidade-SD` e `upstream` apontando para `DBSeller/e-cidade`; checkout local requer WSL/Linux ou diretorio case-sensitive para ficar totalmente limpa.
- `C:\SIGI-SD`: repositorio proprio `sertaodigitalorg/SIGI-SD`, branch local `main`.

## Proximos passos

1. Autenticar o GitHub CLI com uma conta que tenha permissao na organizacao `sertaodigitalorg`.
2. Confirmar procedimento autenticado para inicializar forks vazios em `sertaodigitalorg`.
3. Antes de reiniciar e-Cidade-SD remotamente, confirmar backup/irrelevancia do historico atual.
4. Executar inventario profundo de licencas, frameworks, bancos, Docker, pipelines, testes e dependencias.

## Comandos sugeridos para commit

```bash
git status --short
git add README.md docs scripts
git commit -m "docs: registra estrategia inicial de forks"
```
