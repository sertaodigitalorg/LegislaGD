# Fluxo Git e governanca de PRs

Este documento e a referencia tecnica do fluxo de branches do LegislaGD e o baseline de governanca Git a ser replicado, quando aplicavel, nos modulos do ecossistema legislativo do Sertao Digital.

## Politica de branches

As branches `dev`, `hml` e `main` sao permanentes. Nao devem ser apagadas, recriadas como pratica operacional, receber force push ou alteracoes diretas fora do fluxo protegido por Pull Request.

Branches de trabalho entram somente em `dev`:

- `feature/* -> dev`
- `fix/* -> dev`
- `bugfix/* -> dev`
- `chore/* -> dev`
- `docs/* -> dev`

A promocao entre ambientes ocorre somente nesta ordem:

```text
feature/* --\
fix/*     ---+--> dev --> hml --> main
bugfix/*  ---|
chore/*   ---|
docs/*    --/
```

Atalhos de promocao sao rejeitados. Em especial, `dev -> main`, `hml -> dev`, `main -> dev`, `main -> hml` e branches de trabalho diretamente para `hml` ou `main` nao fazem parte da politica.

## Protecoes obrigatorias

Os rulesets das branches permanentes devem manter, no minimo:

- bloqueio de exclusao;
- bloqueio de force push/non-fast-forward;
- Pull Request obrigatorio;
- pelo menos 1 aprovacao humana obrigatoria;
- invalidacao de aprovacoes anteriores quando novos commits forem enviados;
- resolucao das conversas de review antes do merge;
- merge por `squash`;
- check `Validate Branch Flow` obrigatorio e associado ao GitHub Actions;
- nenhuma permissao de bypass permanente.

O check `Validate Branch Flow` executa `scripts/validate-branch-flow.sh` em Pull Requests destinados a `dev`, `hml` e `main`. O mesmo script e coberto por `scripts/test-branch-flow.sh`.

## Segregacao de responsabilidade

A aprovacao humana e parte obrigatoria do processo. O autor do Pull Request nao substitui a funcao de revisor. Alteracoes posteriores a uma aprovacao invalidam a aprovacao anterior e exigem nova revisao.

Excecoes emergenciais nao devem ser tratadas por bypass permanente. Qualquer mecanismo excepcional futuro deve ser explicitamente documentado, temporario, auditavel e aprovado pela governanca tecnica.

## Replicacao nos modulos

Este fluxo e a referencia para repositorios ativos que componham o LegislaGD. Antes de replicar os rulesets em um modulo, deve-se confirmar que o repositorio adota formalmente as branches `dev`, `hml` e `main`, possui o workflow `Validate Branch Flow` funcional e nao depende de um fluxo upstream incompatível.
