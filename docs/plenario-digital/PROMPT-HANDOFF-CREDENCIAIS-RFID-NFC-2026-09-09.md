# Prompt de Handoff — Credenciais RFID/NFC no LegislaGD

Use este texto para continuar a discussão em outro chat/projeto do LegislaGD.

---

Estamos evoluindo o **LegislaGD / Plenário Digital** para suportar credenciais físicas RFID/NFC usadas em totens, presença e identificação institucional.

## Decisão já tomada

O LegislaGD é um sistema **independente e open source**. Portanto:

- o gerenciamento de identidade e credenciais deve existir **dentro do próprio LegislaGD**;
- não deve depender de WClick nem de qualquer serviço externo para funcionar;
- a WClick pode atuar comercialmente como fornecedora de cartões, pulseiras, leitores, totens, hardware, provisionamento, personalização, integração, implantação, manutenção e suporte;
- o software deve continuar funcionando com hardware compatível fornecido por terceiros, evitando lock-in.

## Cenário de uso prioritário

Na Câmara Municipal, cada parlamentar pode receber um kit físico de identificação, por exemplo:

- 1 cartão principal;
- 1 cartão reserva;
- 1 pulseira RFID/NFC.

As três mídias podem pertencer ao mesmo vereador, mas cada credencial deve possuir identificador e ciclo de vida independente.

Exemplo:

```text
Vereador João da Silva
├── Cartão principal   -> ATIVO
├── Cartão reserva     -> ATIVO
└── Pulseira           -> ATIVA
```

Se um cartão for perdido, ele é revogado sem alterar o usuário nem as outras credenciais.

## Fluxo esperado no totem

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
Registra auditoria
        ↓
Libera ou nega a função
```

Casos iniciais:

- identificar vereador;
- registrar presença;
- habilitar terminal;
- identificar presidente, secretário, operador e servidor;
- registrar eventos de auditoria;
- bloquear/revogar credenciais.

## Regra importante

**Identificação não é voto.**

A leitura de RFID/NFC pode ser suficiente para presença e habilitação de terminal. Para operações sensíveis, especialmente votação, o sistema deve permitir confirmação adicional, como:

- RFID/NFC + confirmação explícita na tela;
- RFID/NFC + PIN;
- futuramente Passkey ou outro fator forte.

Não tratar UID simples como assinatura forte do voto.

## Hardware observado para POC

Foi encontrado no mercado hardware de 13,56 MHz, incluindo pulseira com especificações anunciadas como:

- NFC/RFID 13,56 MHz;
- MIFARE Classic 1K;
- 1 KB de memória;
- UID próprio;
- passiva, sem bateria;
- regravável segundo anúncio.

Esse hardware deve ser tratado apenas como **POC/laboratório**, não como definição arquitetural definitiva.

## Modelo de domínio desejado

Não armazenar o UID como identidade do usuário.

Sugestão:

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

Estados mínimos:

- ACTIVE
- BLOCKED
- LOST
- EXPIRED
- REVOKED
- REPLACED

## Abstração tecnológica

O domínio não deve ficar preso a MIFARE Classic, NTAG, fabricante ou leitor específico.

Avaliar algo como:

```text
CredentialProviderInterface
├── RfidUidProvider
├── NfcProvider
├── QrCodeProvider
├── PasskeyProvider
└── outros futuros
```

O Plenário Digital deve trabalhar com o conceito de credencial e identidade, não com um chip específico.

## POC recomendada

Implementar o menor incremento útil:

1. conectar leitor USB 13,56 MHz ao ambiente Linux/Raspberry/mini-PC;
2. ler UID;
3. cadastrar credencial no LegislaGD;
4. vincular ao usuário;
5. reconhecer a credencial no totem;
6. registrar presença;
7. mostrar o usuário identificado;
8. registrar auditoria;
9. revogar a credencial;
10. comprovar que a credencial revogada não é mais aceita.

## O que quero que você faça neste chat

Continue a partir dessas decisões e:

1. analise a documentação atual do LegislaGD e do Plenário Digital antes de propor implementação;
2. identifique onde esse subsistema de credenciais deve ficar na arquitetura existente;
3. proponha entidades, tabelas, interfaces, eventos e APIs;
4. proponha como o leitor físico deve conversar com o Plenário Digital sem acoplamento a fabricante;
5. separe claramente identificação, presença, autenticação e autorização de voto;
6. defina uma POC incremental sem inflar o MVP;
7. levante riscos de segurança do uso de UID/MIFARE Classic;
8. sugira critérios de homologação de hardware;
9. crie issues no GitHub para tudo que precisar ser implementado, conforme a política de governança do projeto;
10. preserve a independência open source do LegislaGD e não introduza dependência obrigatória da WClick.

A documentação-base criada para esta decisão é:

`docs/plenario-digital/CREDENCIAIS-RFID-NFC.md`

Leia esse arquivo antes de continuar.
