# Fluxo Git e governanca de PRs

Este documento e a referencia tecnica do fluxo de branches do LegislaGD.

## Politica de branches

Branches de trabalho entram somente em `dev`:

- `feature/* -> dev`
- `fix/* -> dev`
- `bugfix/* -> dev`
- `chore/* -> dev`

A promocao entre ambientes ocorre somente nesta ordem:

```text
feature/* --\
fix/*     ---+--> dev --> hml --> main
bugfix/*  ---/
chore/*   --/
```

Atalhos de promocao sao rejeitados. Em especial, `dev -> main`, `hml -> dev`,
`main -> dev`, `main -> hml` e branches de trabalho diretamente para `hml` ou
`main` nao fazem parte da politica.

O check `Validate Branch Flow` executa `scripts/validate-branch-flow.sh` em
Pull Requests destinados a `dev`, `hml` e `main`. O mesmo script e coberto por
`scripts/test-branch-flow.sh`.

## Governanca temporaria de mantenedor unico

Enquanto houver somente um mantenedor/desenvolvedor ativo com responsabilidade
de escrita e manutencao no LegislaGD, a exigencia de aprovacao humana por outro
usuario fica temporariamente suspensa.

Essa excecao nao altera o fluxo por Pull Request nem reduz as protecoes
tecnicas: checks automaticos, protecao contra force push, protecao contra
exclusao de branches e demais rulesets aplicaveis devem permanecer ativos.

Quando o projeto passar a ter 2 ou mais mantenedores/desenvolvedores ativos com
responsabilidade de escrita e manutencao, as protecoes do repositorio devem ser
revistas. Salvo decisao tecnica posterior em contrario, a revisao deve avaliar
a reativacao de pelo menos 1 aprovacao humana e, quando aplicavel, aprovacao
por pessoa diferente do ultimo autor do push.
