# ADR — Reutilização e integração prioritária de software público e aberto

**Data:** 2026-10-10  
**Status:** diretriz estratégica adotada; implementação sob demanda  
**Abrangência:** Sertão Digital, LegislaGD, SIGI-SD, ExecutaGD e novos produtos.

## Contexto
O Sertão Digital busca reduzir retrabalho, custo de manutenção, dependência tecnológica e tempo de implantação. O desenvolvimento de sistemas próprios deve se concentrar em diferenciais e lacunas não atendidas por soluções públicas ou livres.

## Decisão
Antes de aprovar o desenvolvimento de uma funcionalidade ou subsistema:
1. **Reutilizar** uma solução existente e adequada.
2. **Integrar** solução independente por interfaces autorizadas, contratos versionados e padrões abertos.
3. **Adaptar** quando necessário, preservando licenças e buscando contribuição upstream.
4. **Desenvolver do zero** apenas após registrar por que as alternativas anteriores não são viáveis ou suficientes.

A preferência por software público brasileiro é estratégica, **não automática**: avaliar maturidade, segurança, comunidade, acessibilidade, conformidade legal, integração, portabilidade, custo total e manutenção. Soluções sem licença verificável não devem ser tratadas como open source.

## Gate de decisão / matriz mínima
Para cada alternativa registrar: problema e requisito; projeto e fonte oficial; licença e compatibilidade; última manutenção; documentação/API; segurança e dependências; aderência funcional; LGPD e normas setoriais; custo de integração e operação; possibilidade de contribuição upstream; risco de descontinuidade; decisão justificada e responsável.

## Aplicação ao LegislaGD
- **SAPL-SD:** reaproveitamento do SAPL/Interlegis para processos legislativos.
- **PortalModelo-SD:** reaproveitamento do Portal Modelo/Interlegis.
- **e-Cidade-SD:** reaproveitamento do e-Cidade para processos administrativos.
- **e-SIC Livre:** candidato prioritário a integração como sistema especializado LAI, independente do SIGI-SD; condicionado à auditoria técnica e legal.
- **SIGI-SD:** produto transversal próprio para relacionamento e atendimento, integrando serviços especializados em vez de duplicá-los.
- **Plenário Digital:** componente próprio onde requisitos específicos não forem atendidos por soluções existentes; documentar avaliações.

## Governança
- Pesquisa e arquitetura podem avançar sem autorizar desenvolvimento.
- Nenhum conector, fork, modernização ou implantação é iniciado automaticamente por este ADR.
- Demandas concretas geram análise de alternativas e, após aprovação, issues de implementação.
- Respeitar `dev -> hml -> main`, PRs, revisão, auditoria e rastreabilidade.
- Preservar dados sob controle institucional e evitar integração direta aos bancos como contrato padrão.
- Este ADR é uma diretriz geral proposta a ser replicada nos demais repositórios institucionais após revisão, sem alterar automaticamente sua documentação.

## Próxima etapa
Manter catálogo de soluções reutilizáveis e aplicar o gate às necessidades concretas do LegislaGD, começando pela análise de viabilidade do e-SIC Livre.

## Alcance institucional e desenvolvimento de comunidade — decisão complementar (2026-10-10)

**Regra do Centro de Inovação e Tecnologia Sertão Digital (CIT SD):** a priorização de software público, livre e de código aberto é política institucional de engenharia e inovação para as duas frentes de Governo Digital: **LegislaGD (Legislativo)** e **ExecutaGD (Executivo)**. O mesmo princípio orienta seus componentes transversais, inclusive SIGI-SD.

**Objetivo adicional:** cada reutilização ou integração deve ser examinada também como oportunidade de ampliar a comunidade do Sertão Digital e a colaboração com mantenedores, desenvolvedores, órgãos públicos, universidades, organizações e empresas. Oportunidades incluem intercâmbio técnico, contribuição upstream, formação, parcerias institucionais, suporte, serviços e inovação compartilhada; não pressupõem parceria ou benefício comercial automático.

**Práticas recomendadas:**
1. Identificar origem, licença, mantenedores e canais oficiais da comunidade do projeto avaliado.
2. Priorizar integrações desacopladas, padrões abertos, interoperabilidade e soberania de dados.
3. Registrar possibilidades de contribuição upstream (documentação, testes, correções e melhorias), respeitando governança, licenças e segurança.
4. Documentar oportunidades de relacionamento e capacitação sem confundir cooperação comunitária com contratação ou compromisso institucional.
5. Comparar esforço de manter forks com alternativas de integração e contribuição ao projeto original.
6. Registrar justificativa técnica, jurídica, operacional e estratégica sempre que a equipe decidir desenvolver algo novo.

**Governança documental:** esta decisão tem alcance institucional. Seu registro neste repositório não significa que já foi propagada aos repositórios do ExecutaGD, SIGI-SD ou ao acervo central de políticas do CIT SD; a sincronização deve ser controlada e rastreável. Nenhum desenvolvimento é autorizado automaticamente.
