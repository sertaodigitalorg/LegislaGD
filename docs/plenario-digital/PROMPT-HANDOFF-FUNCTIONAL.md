# Prompt Handoff - Validacao funcional do Plenario Digital

Status: Completed by Google Drive validation  
Data: 2026-08-23  
Origem tecnica: `docs/plenario-digital/TECHNICAL-DECISION-GATE.md`

## Contexto

O Technical Decision Gate do Plenario Digital concluiu uma proposta tecnica para Core independente integrado ao SAPL por API. A analise gerou pontos com impacto funcional/institucional que foram validados na fonte MASTER funcional, isto e, Google Drive.

A validacao funcional foi concluida no Google Drive em 2026-08-23. Este handoff fica preservado apenas como registro historico da sincronizacao solicitada.

## Itens validados funcionalmente

1. Confirmar a regra funcional de descoberta de sessao corrente:
   - sessao iniciada e nao finalizada na data atual;
   - sessao com painel aberto;
   - sessao com votacao aberta;
   - sessao do dia mais recente nao finalizada;
   - fallback manual pelo operador.

2. Confirmar matriz inicial de autoridade:
   - Administrador;
   - Operador;
   - Presidente;
   - Secretario;
   - Vereador.

3. Confirmar que prontidao tecnologica nao altera presenca legislativa nem quorum.

4. Confirmar politica inicial de dispositivos:
   - dispositivo autorizado obrigatorio;
   - limite de dispositivos por parlamentar;
   - simultaneidade;
   - validade;
   - aprovacao;
   - revogacao;
   - estados `PENDENTE`, `AUTORIZADO`, `BLOQUEADO`, `REVOGADO`, `EXPIRADO`.

5. Confirmar politica inicial de voto:
   - SAPL como autoridade do voto;
   - Core sem armazenamento autoritativo de voto;
   - MVP usando voto individual existente;
   - sem voto offline/sincronizacao posterior nesta fase.

6. Confirmar niveis iniciais de mensagens:
   - `PUBLICO_DISPLAY`;
   - `PARLAMENTAR`;
   - `OPERACIONAL`;
   - `ADMINISTRATIVO`.

7. Confirmar cenarios de contingencia:
   - `LOCAL_COMPLETO`;
   - `REMOTO_COM_CACHE`;
   - `REMOTO_SEM_CONTINGENCIA`;
   - `HIBRIDO` reservado para evolucao futura.

## Decisao tecnica proposta para ciencia funcional

O SAPL controla o processo legislativo. O Plenario Digital controla a experiencia operacional do plenario.

O Core nao deve saber como o SAPL persiste seus dados; deve conhecer apenas contratos de integracao.

## Resultado esperado no Drive

Atualizar ou criar documento funcional do Plenario Digital registrando:

- escopo do MVP;
- papeis e responsabilidades;
- politicas de sessao, voto, dispositivo, prontidao e mensagens;
- limites de contingencia;
- decisoes pendentes para fases futuras.
