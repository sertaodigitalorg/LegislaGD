# Matriz funcional — LegislaGD e SIGI-SD (CiRM)

**Estado:** decisões de arquitetura e requisitos para validação; **sem autorização para implementação**.  
**Data:** 2026-10-10.

## Contexto
O LegislaGD é a frente prioritária de desenvolvimento do Sertão Digital. SIGI-SD é produto independente e transversal, inicialmente utilizado pelo LegislaGD para atendimento e relacionamento com o cidadão. O Integration Core genérico e a PoC i-Educar não são prioridade de execução. A evolução do SIGI-SD ocorrerá sob demanda funcional real.

## Fontes internas existentes
- `README.md`: SAPL-SD é fonte legislativa; e-Cidade-SD é fonte administrativa; PortalModelo-SD é fachada pública; SIGI-SD é fonte de protocolos e atendimentos.
- `docs/sigi-sd/comunicacao-unica-camara.md`: desenho de Chatwoot, canais, webhook, protocolo, idempotência, perfis atuais e pendências.
- `docs/sigi-sd/atendimento-legislativo.md`, `ouvidoria.md`, `esic.md`, `integracao-sigi-sd.md`: requisitos resumidos, a detalhar.
- Pesquisa de software público/GOV.BR é insumo de planejamento, não autorização para integração.

## Matriz de responsabilidades e prioridades
| Caso de uso | Experiência pública | Fonte de verdade | Papel SIGI-SD | Prioridade documental |
|---|---|---|---|---|
| Contato institucional | PortalModelo-SD e canais oficiais | SIGI-SD/Chatwoot, conforme tipo de registro | Consolidar atendimento e protocolo | P0 |
| Atendimento omnichannel | Chatwoot | SIGI-SD para protocolos; Chatwoot para mensagens | Vincular conversa, agente, setor e histórico | P0 |
| Encaminhamento entre setores | Portal e operação interna | SIGI-SD | Classificar, distribuir, acompanhar e auditar | P0 |
| Ouvidoria legislativa | Portal/canais institucionais | SIGI-SD | Manifestação, classificação, resposta, prazos | P1 |
| Pedido LAI/e-SIC | Portal e canais adequados | SIGI-SD para pedido; órgão para decisão/resposta | Registrar pedido, prazos e recursos, conforme LAI | P1 |
| Consulta de proposições | PortalModelo-SD/SAPL-SD | SAPL-SD | Atendimento referencia URL/ID, não duplica proposição | P1 |
| Serviços administrativos | Portal/atendimento | e-Cidade-SD | Encaminhar/consultar mediante contrato autorizado | P2 |
| Avaliação de atendimento | Portal e encerramento | SIGI-SD | Pesquisa de satisfação e indicadores operacionais | P2 |
| Inteligência/BI | Painéis institucionais | Plataforma 360/Observatório | Disponibilizar dados minimizados/autorizados | P3 |

P0-P3 são **prioridades de análise funcional**, não cronograma de desenvolvimento.

## Limites de responsabilidade
1. LegislaGD agrega, governa e orquestra os módulos; não absorve bancos de dados de terceiros.
2. SAPL-SD administra proposições, tramitação e sessões; SIGI-SD não altera atos legislativos por atendimento.
3. Chatwoot opera conversas; SIGI-SD é fonte de protocolos e histórico de atendimento, com deduplicação.
4. PortalModelo-SD publica os canais oficiais, informações institucionais e acessos.
5. e-Cidade-SD mantém dados administrativos e funcionais.
6. Keycloak Legislativo trata identidade administrativa, conforme desenho de autenticação vigente.
7. Pedidos LAI, ouvidoria e solicitações comuns devem ser tipificados distintamente, com prazos, restrições e fluxos próprios.
8. LGPD, LAI e legislação de ouvidoria devem ser avaliadas por tipo de solicitação e competência do órgão.

## Questões a validar com a Câmara
- Quais canais são oficiais? Horários, SLA e mensagens de atendimento?
- Quais setores recebem manifestações, pedidos LAI e solicitações administrativas?
- Qual autoridade responde, revisa e decide recursos LAI?
- Quais tipos de manifestações exigem proteção de identidade, sigilo ou restrição de acesso?
- Quais perfis de operadores, supervisores e gestores precisam de permissões segregadas?
- Quais anexos, regras de retenção e publicização se aplicam?
- Que consultas ao SAPL-SD são públicas e quais exigem autorização?
- Que indicadores podem ser compartilhados com BI sem expor dados pessoais?

## Próximos passos — somente documentação
1. Validar esta matriz com o desenho de atendimento único já existente.
2. Elaborar jornadas funcionais: atendimento comum, ouvidoria, LAI, consulta legislativa.
3. Criar catálogo de capacidades necessárias do SIGI-SD para o LegislaGD e classificar como existente / parcial / ausente / a verificar após auditoria do código.
4. Registrar ADRs de fronteiras de domínio, privacidade e integração sob demanda.
5. Abrir issues de implementação **somente após** necessidade concreta, escopo aprovado e priorização.

## Decisão de implementação
**Não implementar nesta etapa** Integration Core, conectores federais, PoC i-Educar, novos papéis ou fluxos não validados. Preservar documentação e priorizar o LegislaGD.

## Avaliação específica: e-SIC Livre (2026-10-10)

**Referência:** https://github.com/esiclivre/esiclivre

**Constatações verificadas no repositório:** projeto originário da SEMPLA Natal/RN; licença GPL-2.0-only (`LICENSE.md`, `composer.json`); PHP ^7.4, PHPMailer ^6.0 e configuração MySQL; último push do repositório em 2023-03-02; README descreve instalação por importação SQL, Composer e NPM. A existência de API está **não confirmada**. Os parâmetros de exemplo incluem `verifyCertificates => false`; isso não deve ser copiado para produção.

**Decisão provisória de arquitetura:** candidato a reaproveitamento como solução externa e independente de e-SIC; **não adotar fork nem copiar código para dentro do SIGI-SD nesta etapa**. Primeiro avaliar licença, comunidade, superfície de ataque, dependências, migração tecnológica, manutenção e aderência à LAI e às normas locais. O PortalModelo-SD pode apontar para a aplicação especializada; qualquer sincronização com SIGI-SD dependerá de API/adaptador validado e autorização do órgão. SIGI-SD pode atender comunicação geral, mas e-SIC é fonte de verdade dos pedidos LAI enquanto essa solução estiver implantada.

**Alternativas para comparação:** (A) instalação externa com link institucional e operação isolada; (B) conector de referência/status se houver interface viável; (C) módulo LAI nativo no SIGI-SD, somente quando necessidade justificada. Confirmar obrigações da GPL-2.0 ao distribuir modificações ou incorporar trechos.

**Gate antes de implantação:** auditoria de segurança e atualização; autenticação, autorização, sanitização, correção de TLS, backups, retenção, acessibilidade, fluxo de recursos/prazos, dados pessoais e segregação por órgão. **Nenhuma implementação ou adoção de produção autorizada por este documento.**
