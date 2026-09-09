# Credenciais RFID/NFC no Plenário Digital

Status: decisão arquitetural inicial / proposta de implementação incremental
Data: 2026-09-09

## Objetivo

Definir como o LegislaGD/Plenário Digital deverá tratar credenciais físicas RFID/NFC para identificação institucional em Câmaras Municipais, preservando a independência do projeto open source e evitando dependência obrigatória de serviços externos.

## Princípio arquitetural

O gerenciamento de identidade e credenciais físicas será nativo do LegislaGD.

O LegislaGD deverá continuar funcionando de forma independente, inclusive quando utilizar cartões, pulseiras, QR Codes, NFC ou outros meios de identificação. Nenhum serviço externo, incluindo WClick, será requisito obrigatório para autenticação ou identificação no Plenário Digital.

A WClick poderá atuar como fornecedora, integradora e mantenedora de hardware, credenciais, leitores, totens, provisionamento, instalação, personalização, treinamento, suporte e manutenção, sem criar lock-in no software.

## Casos de uso iniciais

- identificação de vereador no totem;
- registro de presença em sessão;
- habilitação de terminal individual;
- identificação de presidente, secretário, operador e servidor;
- credenciais para visitante, imprensa ou convidado;
- controle de acesso a áreas ou equipamentos;
- trilha de auditoria de apresentação e uso de credenciais.

## Kit de credenciais

O modelo inicial pode considerar um kit por parlamentar contendo:

- 1 cartão principal;
- 1 cartão reserva;
- 1 pulseira RFID/NFC.

As três credenciais podem pertencer ao mesmo usuário, mas devem possuir identificadores próprios e ciclos de vida independentes.

Exemplo:

```text
Vereador João da Silva
├── Cartão principal   -> ATIVO
├── Cartão reserva     -> ATIVO
└── Pulseira           -> ATIVA
```

A perda de uma mídia física não altera a identidade institucional do usuário. Apenas a credencial correspondente deve ser bloqueada ou revogada.

## Modelo de domínio

Não associar o UID diretamente ao identificador principal do usuário.

Estrutura conceitual:

```text
User / Pessoa institucional
    |
    +-- Credential
          - id interno UUID
          - user_id
          - type
          - technology
          - external_identifier / uid
          - status
          - issued_at
          - expires_at
          - revoked_at
          - last_used_at
          - metadata
```

Estados mínimos recomendados:

- ACTIVE
- BLOCKED
- LOST
- EXPIRED
- REVOKED
- REPLACED

## Abstração tecnológica

O domínio não deve ser acoplado a MIFARE Classic, NTAG ou qualquer fabricante específico.

Sugestão de abstração:

```text
CredentialProviderInterface
├── RfidUidProvider
├── NfcProvider
├── QrCodeProvider
├── PasskeyProvider
└── outros providers futuros
```

O restante do Plenário Digital deve perguntar essencialmente:

> Qual identidade institucional apresentou esta credencial e quais ações ela pode executar neste contexto?

## Fluxo do totem

```text
Cartão / Pulseira
        ↓
Leitor 13,56 MHz
        ↓
Totem / Plenário Digital
        ↓
Credential Resolver interno
        ↓
Identifica usuário
        ↓
Valida credencial + usuário + sessão + permissões
        ↓
Registra evento de auditoria
        ↓
Libera ou nega a função
```

Exemplo de experiência:

```text
APROXIME SUA CREDENCIAL
        ↓
Credencial reconhecida
        ↓
Vereador identificado
        ↓
Presença registrada
        ↓
Terminal habilitado
```

## Identificação não é voto

A apresentação de cartão ou pulseira pode ser suficiente para identificação, presença e habilitação de terminal, conforme política da Câmara.

Para operações sensíveis, principalmente votação, encerramento de sessão, alteração administrativa ou atos de maior impacto, o sistema deve permitir autenticação adicional.

Exemplos:

- RFID/NFC + confirmação explícita na tela;
- RFID/NFC + PIN;
- RFID/NFC + Passkey;
- RFID/NFC + biometria, se futuramente adotada e juridicamente/tecnicamente adequada.

A credencial física não deve ser tratada automaticamente como assinatura forte do voto.

## Hardware inicial para POC

Foi identificado no mercado um conjunto de pulseiras/cartões de 13,56 MHz. Um dos modelos observados informa:

- NFC/RFID 13,56 MHz;
- chip MIFARE Classic 1K;
- memória de 1 KB;
- UID próprio por pulseira;
- mídia passiva, sem bateria;
- possibilidade de regravação segundo o fabricante/anúncio.

Esse tipo de dispositivo é adequado para laboratório e prova de conceito, mas não deve definir a arquitetura definitiva do sistema.

Antes de homologação em produção, devem ser avaliados:

- compatibilidade do leitor;
- comportamento em Linux/Raspberry/mini-PC;
- velocidade e estabilidade de leitura;
- possibilidade de clonagem/emulação;
- política de segurança do UID;
- necessidade de tecnologia mais segura, como família MIFARE DESFire, em cenários de autenticação forte;
- compatibilidade com celulares quando houver uso NFC/NDEF.

## POC recomendada

Primeiro incremento técnico:

1. conectar leitor USB 13,56 MHz compatível ao ambiente do Plenário Digital;
2. ler o UID de cartão/pulseira;
3. cadastrar a credencial no LegislaGD;
4. vincular a credencial a um usuário;
5. aproximar a mídia no leitor;
6. resolver a identidade;
7. registrar presença;
8. exibir identificação no totem;
9. registrar evento na auditoria;
10. bloquear/revogar uma credencial e validar a negativa de acesso.

O objetivo da POC é validar o domínio e a integração com hardware, não implementar inicialmente controle de acesso completo ou autenticação criptográfica avançada.

## Independência open source e modelo comercial

### LegislaGD

Responsável por:

- cadastro de pessoas e usuários;
- cadastro e vínculo de credenciais;
- identificação e autorização;
- presença;
- regras de sessão;
- auditoria;
- revogação;
- integração com o Plenário Digital.

### WClick ou outros fornecedores

Podem fornecer:

- cartões;
- pulseiras;
- leitores RFID/NFC;
- totens;
- Raspberry/mini-PC;
- impressão e personalização;
- provisionamento;
- instalação;
- configuração;
- integração;
- treinamento;
- manutenção;
- suporte;
- reposição de credenciais;
- homologação de kits.

Regra: a Câmara deve poder utilizar hardware compatível de outro fornecedor sem depender da WClick para que o software LegislaGD continue operando.

## Compatibilidade e homologação

Sugestão futura de diferenciação:

- **Compatível com LegislaGD**: equipamento que implemente a interface/protocolo esperado pelo projeto;
- **Homologado para LegislaGD**: equipamento testado por processo de homologação, com documentação e matriz de compatibilidade;
- **Kit fornecido pela WClick**: pacote comercial de hardware, personalização, implantação e suporte, sem dependência proprietária no software.

## Fora do escopo inicial

Não implementar neste primeiro ciclo:

- ponto eletrônico trabalhista;
- controle predial completo;
- biometria;
- criptografia proprietária de cartão;
- gestão comercial da WClick dentro do LegislaGD;
- dependência de API externa de identidade;
- suporte a todas as famílias RFID/NFC existentes.

## Decisão

O LegislaGD deverá possuir um subsistema nativo e extensível de credenciais institucionais. Um usuário poderá possuir múltiplas credenciais físicas e digitais simultaneamente, cada uma com ciclo de vida independente. O Plenário Digital consumirá essas credenciais por meio de abstrações, sem acoplamento a chip, leitor, fabricante ou fornecedor específico.

A implementação deve começar por uma POC de RFID/NFC 13,56 MHz para identificação, presença e habilitação de terminal, evoluindo conforme requisitos reais e validações de segurança.
