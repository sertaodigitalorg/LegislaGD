# ADR-008: Modelo operacional do Plenario Digital

Status: Proposed  
Data: 2026-08-24

## Contexto

A fonte funcional MASTER do Plenario Digital validou novos requisitos para o
piloto: presenca legislativa separada de conexao/autenticacao/dispositivo,
multiplas chamadas de presenca, rito configuravel por Casa Legislativa e tipo de
sessao, separacao entre estado institucional, participante, sincronizacao e
operacional, e Saude Operacional independente da sessao legislativa.

O SAPL/SAPL-SD permanece autoridade de sessao, presenca legislativa oficial,
pauta, materia, votacao, voto, resultado, quorum e cargo exercido na sessao. O
Core do Plenario Digital controla apenas a experiencia operacional.

## Decisao

O Plenario Digital Core deve usar boundaries logicos dentro do bounded context
`Plenary Operations`, sem criar microservicos no MVP.

As maquinas de estado devem ser separadas:

1. estado institucional observado, derivado do SAPL;
2. workflow operacional da sessao e do rito;
3. estado de participante/dispositivo;
4. estado de sincronizacao e Saude Operacional.

O rito deve ser configurado por template e instanciado por sessao como snapshot
historico. Alteracoes futuras no template nao podem alterar a instancia ja
executada.

Presenca deve ser processo com chamada, confirmacao explicita e reconciliacao,
nao booleano permanente. Uma sessao pode ter multiplas chamadas de presenca. O
resultado oficial continua autoridade do SAPL quando suportado.

Saude Operacional deve combinar monitoramento passivo e diagnostico ativo sob
demanda, incluindo teste interativo que diferencie dispositivo conectado,
mensagem entregue e usuario confirmou visualizacao. Diagnostico durante sessao
nao pode alterar presenca, voto, fala, resultado, rito ou estado legislativo.

Eventos operacionais devem ser registrados em event log auditavel. Event
Sourcing completo nao sera adotado neste momento; usar modelo transacional com
event log, outbox/inbox e idempotency keys quando houver integracoes assincronas
ou comandos sensiveis.

Realtime deve ser incremental: polling no MVP, SSE como proximo passo e
WebSocket/broker apenas mediante necessidade comprovada.

## Consequencias positivas

- Evita confundir falha tecnica com ato legislativo.
- Evita tratar conexao como presenca oficial.
- Preserva SAPL como fonte de verdade legislativa.
- Permite configuracao por Casa sem hardcode de rito.
- Permite diagnostico durante sessao sem interferencia legislativa.
- Mantem evolucao incremental e compativel com SAPL Interlegis remoto.

## Consequencias negativas

- Exige modelagem adicional no Core para rito, diagnostico, eventos e
  reconciliacao.
- Exige contratos SAPL-SD futuros para capabilities, contexto de cargo,
  presenca oficial e comandos idempotentes.
- A UI precisa lidar com mais de uma dimensao de estado.
- O MVP deve comunicar claramente capacidades indisponiveis por provider.

## Alternativas consideradas

Uma unica state machine global: rejeitada por misturar estado legislativo,
tecnico, sincronizacao e participante.

Event Sourcing completo: rejeitado neste momento por complexidade e porque a
fonte legislativa oficial permanece externa no SAPL.

Rito hardcoded: rejeitado por conflitar com variacao regimental entre Casas e
tipos de sessao.

Roles permanentes `plenario.presidente` e `plenario.secretario`: rejeitadas; os
cargos sao contextuais e devem ser derivados do SAPL.

## Decisoes futuras relacionadas

- endpoints canonicos `/api/sd/plenario/...` no SAPL-SD;
- comandos legislativos por API;
- voto por API;
- uso de biometria, fotografia, NFC forte ou passkeys como fator obrigatorio;
- WebSocket, broker e filas para realtime/fan-out;
- politicas de retencao de auditoria operacional por Casa Legislativa.
