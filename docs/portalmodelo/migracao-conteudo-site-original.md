# Migracao de conteudo do site original

Este roteiro orienta a migracao de informacoes de um Portal Modelo original da
Interlegis para o PortalModelo-SD local do LegislaGD.

## Estado atual

- Origem: pendente de URL e credenciais.
- Destino local esperado: `http://portal.legislagd.localhost/portal` ou
  `http://portalmodelo.localhost/portal`, conforme o modo de subida.
- Tecnologia: ambos os lados devem ser Portal Modelo/Plone da Interlegis.
- Carga inicial local: gerada pelo profile
  `interlegis.portalmodelo.policy:default`.

## Principio de migracao

Migrar primeiro informacoes institucionais e conteudo publico validado. Nao
migrar automaticamente configuracoes tecnicas, usuarios, permissoes, logs,
formularios com dados pessoais, arquivos temporarios ou historico privado.

## Informacoes necessarias antes de executar

| Campo | Necessario | Observacao |
| --- | --- | --- |
| URL publica do site original | Sim | Exemplo: `https://www.camara...leg.br` |
| Acesso administrativo do site original | Preferencial | Permite exportacao Plone mais fiel. |
| Acesso administrativo local | Sim | Padrao local documentado: `admin / interlegis`. |
| Escopo de conteudo | Sim | Institucional, noticias, parlamentares, transparencia, ouvidoria etc. |
| Regra de anexos | Sim | Validar LGPD e tamanho antes de importar. |
| Janela de homologacao | Sim | Necessaria para teste visual e conferencia manual. |

## Escopo inicial recomendado

1. Pagina inicial e chamadas principais.
2. Sobre a Camara.
3. Mesa Diretora.
4. Vereadores/parlamentares.
5. Comissoes.
6. Noticias.
7. Transparencia.
8. Ouvidoria e canais de atendimento.
9. Links para SAPL e normas.
10. Arquivos publicos anexados a paginas migradas.

## Conteudos fora do primeiro lote

- Usuarios e senhas.
- Permissoes locais.
- Logs, comentarios privados, formularios recebidos e protocolos antigos.
- Integracoes antigas sem contrato validado.
- Temas customizados nao versionados.
- Dados pessoais nao necessarios para publicacao.

## Estrategias tecnicas

### 1. Exportacao Plone autenticada

Preferida quando houver acesso administrativo ao site original. Deve usar
ferramenta compativel com a versao do Portal Modelo original, como exportacao
ZMI/Plone, pacote migrator ou pipeline transmogrifier disponivel no ambiente.

Validar antes:

- versao do Plone/Portal Modelo original;
- tipos de conteudo instalados;
- tamanho da ZODB e de blobs;
- encoding dos textos;
- paths que conflitam com a carga inicial local.

### 2. Inventario publico por crawling

Fallback quando nao houver acesso administrativo. Serve para levantar paginas,
noticias e anexos publicos, mas perde metadados internos, workflow, donos,
permissoes e alguns tipos ricos de conteudo.

Usar apenas para conteudo publico e conferir manualmente antes de publicar.

## Ordem de execucao

1. Registrar URL origem, URL destino e responsavel pela migracao.
2. Subir PortalModelo-SD local.
3. Rodar `make seed` somente se for aceitavel recriar o site local.
4. Fazer inventario do site original.
5. Classificar conteudo em migrar, revisar, descartar ou recriar manualmente.
6. Executar importacao em ambiente local.
7. Rodar teste visual desktop/mobile da pagina inicial e secoes principais.
8. Conferir links internos, anexos, imagens e acentos.
9. Registrar itens pendentes.
10. Promover para homologacao somente apos aceite.

## Checklist visual

| Area | Verificacao |
| --- | --- |
| Home | Logo, menu, banners, noticias e rodape sem sobreposicao. |
| Menu | Estrutura equivalente ao site original, sem links quebrados. |
| Noticias | Listagem, detalhe, imagem e data legiveis. |
| Paginas institucionais | Texto, tabelas e anexos preservados. |
| Transparencia | Links externos e documentos abrindo corretamente. |
| Atendimento | E-mail, WhatsApp, ouvidoria e webchat apontando para canais oficiais. |
| Mobile | Menu, cards, busca e rodape funcionais em largura pequena. |

## Validacoes tecnicas

```sh
cd modules/PortalModelo-SD
make ps
make logs
make url
```

Com a stack integrada do LegislaGD:

```sh
make ps portal
make logs portal
make initial-load-portal
```

`make initial-load-portal` ou `make seed` podem recriar conteudo local. Use
somente quando a perda do estado local atual for aceitavel.

## Registro da migracao

Durante a execucao, manter uma tabela com:

| Origem | Destino | Tipo | Status | Observacao |
| --- | --- | --- | --- | --- |
| `/` | `/portal` | Home | Pendente | Conferir capa. |

Modelo inicial versionado: `docs/portalmodelo/inventario-migracao-conteudo.csv`.

Status aceitos:

- `pendente`
- `migrado`
- `revisar`
- `descartado`
- `recriar-manual`

## Proxima entrada necessaria

Para iniciar a migracao real, informar:

1. URL do site original.
2. Se ha acesso administrativo ao site original.
3. Se posso recriar o PortalModelo-SD local com `make seed` antes de importar.
