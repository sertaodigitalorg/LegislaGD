# AGENTS.md — LegislaGD

Este repositório contém a implementação técnica específica do LegislaGD.

## Bootstrap de contexto

Ao trabalhar neste repositório, o agente deve:

1. detectar e ler `.sdka.yaml`;
2. carregar `SD-Knowledge/AGENTS.md` no outro root do workspace;
3. carregar `SD-Knowledge/skills/sertaodigital-core/SKILL.md`;
4. carregar `SD-Knowledge/skills/legislagd/SKILL.md`;
5. ler este `AGENTS.md`, a documentação e os ADRs locais;
6. analisar as integrações e o código atual antes de decidir ou alterar.

A governança transversal e as Skills são mantidas em
<https://github.com/sertaodigitalorg/SD-Knowledge>. Use referências; não copie
as políticas ou Skills para este repositório.

## Autoridade

LegislaGD é MASTER para:

- código e arquitetura específica;
- ADRs e APIs próprias;
- deploy e configuração técnica local;
- decisões técnicas específicas do produto.

SD-Knowledge é MASTER para:

- governança SDKA e regras transversais;
- Skills;
- conhecimento técnico reutilizável entre produtos;
- manifestos de produtos, repositórios e fontes.

Google Drive é MASTER para conhecimento funcional, institucional, estratégico,
administrativo, jurídico e comercial. `GPT_SOURCE`, Markdown exportado e chat
são derivados: não consolidam decisões técnicas ou funcionais isoladamente.

## Technical Decision Gate

Antes de consolidar uma decisão técnica relevante:

1. carregue os AGENTS e as Skills indicados no bootstrap;
2. analise código, documentação, ADRs e histórico relevantes;
3. analise integrações, compatibilidade e impacto em outros repositórios;
4. avalie segurança, privacidade e menor privilégio;
5. registre ADR quando a decisão for arquitetural;
6. execute o Cross-Layer Impact Check.

## Evolução coordenada do conhecimento

Classifique conhecimento novo descoberto no desenvolvimento:

- específico da implementação: mantenha no LegislaGD;
- técnico reutilizável ou transversal: proponha atualização no SD-Knowledge;
- funcional ou institucional: atualize o Drive somente com acesso e autorização;
  caso contrário, gere Prompt Handoff conforme o padrão do SD-Knowledge.

Uma mudança local que exija atualização de Skill deve usar branch, commit e PR
separados no SD-Knowledge. Os PRs dos dois repositórios devem se referenciar
mutuamente com os números reais, sem misturar arquivos ou históricos Git.
Não edite o SD-Knowledge automaticamente sem verificar impacto e autorização.

Fluxo esperado:

```text
Mudança no LegislaGD
        ↓
Technical Decision Gate
        ↓
Implementação + testes + ADR, quando aplicável
        ↓
Cross-Layer Impact Check
        ↓
Conhecimento reutilizável mudou?
        ├── não: finalizar no LegislaGD
        └── sim: PR separado no SD-Knowledge
```

Se houver impacto funcional, atualize o Drive com acesso e autorização ou gere
um Prompt Handoff. Ausência de acesso não elimina a responsabilidade de registrar
a sincronização pendente.

## Independência dos repositórios

- não copie nem faça fork local do SD-Knowledge dentro do LegislaGD;
- não transforme SD-Knowledge em dependência de runtime;
- não use Git submodule nesta etapa;
- não duplique Skills;
- mantenha branch, commit, PR e histórico próprios para cada repositório.

## Segurança

Não inclua secrets, tokens, senhas, credenciais, arquivos `.env` reais ou dados
pessoais desnecessários. Capacidade técnica de escrita não substitui autorização.
