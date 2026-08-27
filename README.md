# LegislaGD

Plataforma publica e livre de Governo Digital para gestao legislativa, administrativa, financeira, transparencia, atendimento ao cidadao e soberania tecnologica das Camaras Municipais.

**Slogan:** Governo Digital para o Poder Legislativo.

> **Autoridade documental:** missão, escopo funcional, limites institucionais e papéis dos produtos derivam dos MASTERs funcionais no Google Drive. Este repositório é a fonte de verdade técnica do LegislaGD para arquitetura, integração, infraestrutura, segurança, desenvolvimento, testes, CI/CD e ADRs.

## Repositorios oficiais

| Componente | Repositorio Sertao Digital | Origem/upstream |
| --- | --- | --- |
| LegislaGD | https://github.com/sertaodigitalorg/LegislaGD.git | Repositorio agregador |
| SAPL-SD | https://github.com/sertaodigitalorg/SAPL-SD.git | https://github.com/interlegis/sapl.git |
| PortalModelo-SD | https://github.com/sertaodigitalorg/PortalModelo-SD.git | https://github.com/interlegis/portalmodelo.git |
| Plenario-Digital-Core | https://github.com/sertaodigitalorg/Plenario-Digital-Core.git | Componente proprio |
| e-Cidade-SD | https://github.com/sertaodigitalorg/e-Cidade-SD.git | upstream tecnico institucional: https://github.com/DBSeller/e-cidade.git |
| SIGI-SD | https://github.com/sertaodigitalorg/SIGI-SD.git | Plataforma propria, sem upstream |

O LegislaGD concentra a experiencia de desenvolvimento, governanca tecnica, arquitetura, infraestrutura local e coordenacao de integracoes entre componentes independentes. O escopo funcional detalhado de cada produto deve ser consultado nas fichas funcionais do Google Drive.

## Missao

A missão funcional vigente é mantida no MASTER funcional do LegislaGD no Google Drive. Em termos técnicos, este repositório implementa uma base pública, livre e auditável para operação do ecossistema legislativo com controle sobre código, dados, operação e continuidade institucional.

## Principios tecnicos

- Nao SaaS obrigatorio: cada instituicao deve poder instalar, hospedar, manter, exportar, migrar e operar sua propria instancia.
- Soberania tecnologica: codigo-fonte, banco de dados, documentos, configuracoes, backups e credenciais devem permanecer sob controle da instituicao.
- Integracao por contratos: APIs, eventos, webhooks, filas e exportacoes controladas sao preferidos.
- Sem acoplamento direto por banco: acesso irrestrito aos bancos internos dos sistemas nao deve ser usado como estrategia de integracao.
- Forks responsaveis: preservar licencas, creditos, autores e contribuicoes upstream nos componentes baseados em projetos de terceiros.
- Evolucao propria: SIGI-SD e produto proprio do Sertao Digital e nao possui upstream.

## Arquitetura logica

```text
Cidadao e servidores
        |
        v
PortalModelo-SD
        |
        +-------------------+
        |                   |
        v                   v
    SAPL-SD              SIGI-SD
        |                   |
        +---------+---------+
                  |
                  v
        Camada de integracao
                  |
                  v
             e-Cidade-SD
                  |
                  v
 Dados, transparencia e auditoria
```

## Responsabilidades

A descrição funcional detalhada está nos MASTERs do Drive. A arquitetura técnica de responsabilidades e autoridade de dados está em `docs/arquitetura/responsabilidades.md`.

- **SAPL-SD:** autoridade dos dados e atos legislativos oficiais no seu domínio.
- **Plenario-Digital-Core:** experiencia operacional do plenario, sem substituir a autoridade legislativa do SAPL.
- **e-Cidade-SD:** autoridade administrativa/financeira/funcional conforme módulos habilitados.
- **PortalModelo-SD:** fachada pública institucional e publicadora de conteúdo.
- **SIGI-SD:** autoridade de protocolos, histórico de atendimento e dados próprios de relacionamento/orquestração.
- **LegislaGD:** agregador, orquestrador e camada de governanca tecnica.

## Roadmap

O roadmap técnico está versionado neste repositório. Roadmap funcional e prioridades institucionais devem permanecer alinhados ao Drive.

## Contribuicao

Contribuicoes devem preservar licencas, creditos e rastreabilidade das origens. Mudancas em SAPL-SD, PortalModelo-SD e e-Cidade-SD devem considerar contribuicoes de volta aos mantenedores originais quando forem genericas.

Fluxo Git adotado: `feature/*`, `fix/*`, `bugfix/*` e `chore/*` -> `dev` -> `hml` -> `main`, por Pull Request e respeitando as proteções vigentes.

## Seguranca

Vulnerabilidades criticas nao devem ser abertas em issues publicas. Use o processo descrito em `SECURITY.md`.

## Licenca e creditos

A licenca do agregador deve ser definida apos a inspecao completa das licencas dos componentes. SAPL, Portal Modelo e e-Cidade preservam suas licencas, historicos e creditos originais.

## Desenvolvimento

Use os scripts em `scripts/` para clonar e inspecionar componentes sem sobrescrever repositorios existentes:

```bash
./scripts/clone-components.sh
./scripts/check-repositories.sh
```

Esses scripts nao executam `reset`, nao alteram branches automaticamente e nao apagam diretorios.

### Plataforma local integrada

O LegislaGD sobe a plataforma central de desenvolvimento com Traefik e nomes locais amigaveis:

```bash
make up
make urls
```

A execucao padrao de `make up`, sem personalizacao no `.env`, usa `LEGISLAGD_ENV=development`, clona repositorios ausentes na branch configurada e sobe PortalModelo-SD, SAPL-SD, SIGI-SD e Plenario-Digital-Core. Esse e o fluxo local esperado para desenvolvimento.

A plataforma integrada usa um unico PostgreSQL central do LegislaGD. SAPL-SD, Plenario-Digital-Core, SIGI-SD e Chatwoot usam bases e usuarios separados dentro desse mesmo container.

A autenticacao unificada usa Keycloak self-hosted como autoridade central de identidade do domínio Legislativo. Legislativo e Executivo permanecem domínios de identidade independentes.

A subida principal inclui PortalModelo-SD, SAPL-SD, Plenario-Digital-Core, SIGI-SD e e-Cidade-SD por padrao. Cada modulo pode ser desabilitado no `.env` com `LEGISLAGD_ENABLE_PORTAL=0`, `LEGISLAGD_ENABLE_SAPL=0`, `LEGISLAGD_ENABLE_PLENARIO=0`, `LEGISLAGD_ENABLE_SIGI=0` ou `LEGISLAGD_ENABLE_ECIDADE=0`.

Quando um modulo ainda nao existe no workspace, o LegislaGD clona automaticamente o fork configurado no `.env` na branch definida: `dev` para desenvolvimento local, `hml` para homologacao ou `main` para base principal/producao. Repositorios locais ja existentes sao preservados.

Tambem e possivel subir ou derrubar um modulo isolado sem perder o proxy central:

```bash
make up sapl
make up portal
make up sigi
make up plenario
make down sapl
```

Consulte `docs/implantacao/desenvolvimento-local.md` para comandos, URLs e detalhes da orquestracao.

### Identidade e Single Sign-On

O Keycloak e a autoridade central de identidade legislativa. A implantacao e incremental e preserva permissões detalhadas em cada aplicação.

Documentos principais:

- `docs/architecture/sso-analysis.md`
- `docs/architecture/sso-implementation-plan.md`
- `docs/implantacao/desenvolvimento-local.md`

## Auditoria documental

A separação Drive × GitHub foi revisada em 2026-08-27. Consulte `docs/documentation-audit-2026-08-27.md`.
