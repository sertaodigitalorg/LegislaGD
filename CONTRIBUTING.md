# Contribuindo

Obrigado por contribuir com o LegislaGD.

## Regras

- Preserve licencas, autores e creditos dos projetos originais.
- Nao envie segredos, tokens, senhas, certificados ou bases reais.
- Documente mudancas de arquitetura em ADRs quando afetarem mais de um componente.
- Em componentes derivados de terceiros, avalie se a melhoria deve voltar ao upstream.
- Em SIGI-SD, siga a governanca interna das equipes do Sertao Digital.

## Fluxo sugerido

1. Abra uma issue descrevendo contexto e impacto.
2. Crie uma branch curta e descritiva.
3. Inclua documentacao e validacoes proporcionais ao risco.
4. Solicite revisao antes de merge.

## Fluxo de branches

Branches de trabalho (`feature/*`, `fix/*`, `docs/*` e `chore/*`) devem ser
integradas em `dev`. A promocao entre ambientes ocorre somente nesta ordem:

```text
branch de trabalho -> dev -> hml -> main
```

O check `Validate Branch Flow` rejeita automaticamente Pull Requests de
promocao que nao sejam `dev -> hml` ou `hml -> main`. A origem tambem deve
pertencer a este repositorio; uma branch homonima criada em um fork nao e
aceita como branch de promocao.

### Configuracao dos Rulesets

Depois que o workflow tiver executado ao menos uma vez e o check estiver
disponivel no GitHub, habilite `Require status checks to pass` e selecione o
check exato `Validate Branch Flow` nos Rulesets que protegem `hml` e `main`.

O Ruleset atual agrupa `dev` e `hml`, mas este check e executado apenas para
Pull Requests destinados a `hml` ou `main`. Portanto, nao associe o check ao
Ruleset agrupado: isso deixaria Pull Requests para `dev` aguardando um check
que nao sera criado. Separe a exigencia em um Ruleset especifico para `hml`,
mantendo as demais protecoes compartilhadas com `dev`, ou crie um Ruleset
adicional destinado somente a `hml`.

Validacao manual esperada:

| Origem | Destino | Resultado |
| --- | --- | --- |
| `dev` | `hml` | permitido |
| `hml` | `main` | permitido |
| `feature/teste` | `hml` | negado |
| `fix/teste` | `hml` | negado |
| `dev` | `main` | negado |
| `feature/teste` | `main` | negado |
