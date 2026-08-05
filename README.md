# LegislaGD

Plataforma publica e livre de Governo Digital para gestao legislativa, administrativa, financeira, transparencia, atendimento ao cidadao e soberania tecnologica das Camaras Municipais.

**Slogan:** Governo Digital para o Poder Legislativo.

## Repositorios oficiais

| Componente | Repositorio Sertao Digital | Origem upstream confirmada |
| --- | --- | --- |
| LegislaGD | https://github.com/sertaodigitalorg/LegislaGD.git | Repositorio agregador |
| SAPL-SD | https://github.com/sertaodigitalorg/SAPL-SD.git | https://github.com/interlegis/sapl.git |
| PortalModelo-SD | https://github.com/sertaodigitalorg/PortalModelo-SD.git | https://github.com/interlegis/portalmodelo.git |
| e-Cidade-SD | https://github.com/sertaodigitalorg/e-Cidade-SD.git | https://github.com/DBSeller/e-cidade.git |
| SIGI-SD | https://github.com/sertaodigitalorg/SIGI-SD.git | A confirmar antes de configurar fork/upstream |

O LegislaGD e a plataforma central legislativa aberta: concentra a experiencia de desenvolvimento, a documentacao, a governanca, a arquitetura, a infraestrutura local e a coordenacao de integracoes entre os componentes. SAPL-SD, PortalModelo-SD, SIGI-SD e e-Cidade-SD continuam independentes, com historico, licenca e evolucao proprios, mas sao operados pelo LegislaGD como modulos da plataforma.

## Missao

Oferecer uma base publica, livre e auditavel para que Camaras Municipais implantem Governo Digital com controle sobre codigo, dados, operacao e continuidade institucional.

## Principios

- Nao SaaS: cada instituicao pode instalar, hospedar, manter, exportar, migrar e operar sua propria instancia.
- Soberania tecnologica: codigo-fonte, banco de dados, documentos, configuracoes, backups e credenciais devem permanecer sob controle da instituicao.
- Integracao por contratos: APIs, eventos, webhooks, filas e exportacoes controladas sao preferidos.
- Sem acoplamento direto por banco: acesso irrestrito aos bancos internos dos sistemas nao deve ser usado como estrategia de integracao.
- Forks responsaveis: preservar licencas, creditos, autores e contribuicoes upstream nos componentes baseados em projetos de terceiros.
- Evolucao propria: SIGI-SD e mantido pelas equipes do Sertao Digital, sem dependencia de upstream externo nesta etapa.

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

- **SAPL-SD:** fonte oficial dos dados legislativos.
- **e-Cidade-SD:** fonte oficial dos dados administrativos, financeiros e funcionais.
- **PortalModelo-SD:** fachada publica institucional.
- **SIGI-SD:** fonte oficial dos protocolos e atendimentos, mantida pelas equipes do Sertao Digital.
- **LegislaGD:** agregador, orquestrador e camada de governanca.

## Roadmap

O roadmap esta organizado em ondas: fundacao, legislativo, portal, administracao, atendimento, integracoes e Camara inteligente.

## Contribuicao

Contribuicoes devem preservar licencas, creditos e rastreabilidade das origens. Mudancas em SAPL-SD, PortalModelo-SD e e-Cidade-SD devem considerar contribuicoes de volta aos mantenedores originais quando forem genericas.

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

A execucao padrao de `make up`, sem personalizacao no `.env`, usa `LEGISLAGD_ENV=development`, clona repositorios ausentes na branch `dev` e sobe PortalModelo-SD, SAPL-SD e SIGI-SD. Esse e o fluxo local esperado para desenvolvimento.

A subida principal inclui PortalModelo-SD, SAPL-SD e SIGI-SD por padrao. Cada modulo pode ser desabilitado no `.env` com `LEGISLAGD_ENABLE_PORTAL=0`, `LEGISLAGD_ENABLE_SAPL=0` ou `LEGISLAGD_ENABLE_SIGI=0`. O e-Cidade-SD permanece fora desta etapa ate a integracao administrativa ser preparada.

Quando um modulo ainda nao existe no workspace, o LegislaGD clona automaticamente o fork configurado no `.env` na branch definida: `dev` para desenvolvimento local, `hml` para homologacao ou `main` para base principal/producao. As URLs padrao apontam para a organizacao Sertao Digital, mas podem ser trocadas por outra fonte usando `PORTALMODELO_SD_GIT_URL`, `SAPL_SD_GIT_URL` e `SIGI_SD_GIT_URL`. Repositorios locais ja existentes sao preservados.

Tambem e possivel subir ou derrubar um modulo isolado sem perder o proxy central:

```bash
make up sapl
make up portal
make up sigi
make down sapl
```

Consulte `docs/implantacao/desenvolvimento-local.md` para comandos, URLs e detalhes da orquestracao.
