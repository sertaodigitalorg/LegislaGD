# ADR-006: Fluxo Git e mantenedor unico

## Decisao

O LegislaGD adota o fluxo `feature/*`, `fix/*`, `bugfix/*` e `chore/*` para
`dev`, seguido de `dev -> hml -> main`.

Enquanto houver somente um mantenedor ativo, a exigencia de aprovacao humana por
outra pessoa fica suspensa, sem remover Pull Requests, checks automaticos ou
protecoes contra force push e exclusao.

## Contexto

O PR #5 valida a politica de branches e ocorre em uma fase de mantenedor unico.
Exigir aprovacao humana externa nesse momento bloquearia a manutencao sem
adicionar revisao efetiva. Ao mesmo tempo, atalhos de promocao e merges sem CI
continuam sendo riscos tecnicos.

## Consequencias

O fluxo de branches passa a ser validado por script versionado e pelo GitHub
Actions. Quando houver 2 ou mais mantenedores ativos, os rulesets devem ser
revistos para avaliar a reativacao de aprovacao humana obrigatoria.
