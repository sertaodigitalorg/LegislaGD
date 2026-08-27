# Prompt Handoff Funcional - Papeis do Plenario Digital

Data: 2026-08-24

## Contexto

Durante a implantacao incremental do MVP do Plenario Digital, foi identificada
uma separacao necessaria entre papeis tecnicos de acesso ao Core e cargos
legislativos exercidos em uma sessao.

## Decisao tecnica aplicada

O Plenario-Digital-Core passa a tratar como papeis tecnicos proprios:

- `plenario.admin`;
- `plenario.operador`;
- `plenario.parlamentar`.

O Core nao tera roles proprias `plenario.presidente` ou
`plenario.secretario`.

## Premissa funcional a validar/registrar no Drive

Presidente, Secretario, presenca legislativa, quorum, direito de voto e cargo
exercido pelo parlamentar em uma sessao devem permanecer autoridade do SAPL.

Assim, uma pessoa pode ter acesso tecnico ao Core como parlamentar, mas o Core
nao deve concluir que ela e presidente ou secretario da sessao sem informacao
autoritativa do SAPL.

## Impacto no MVP

- Administrador e Operador continuam papeis tecnicos do Core.
- Parlamentar passa a ser papel tecnico de acesso ao Core.
- Presidente e Secretario continuam perfis funcionais, mas sua identificacao em
  sessao sera derivada do SAPL quando houver contrato/API adequada.
- O MVP continua sem voto por API, sem comando legislativo por API e sem voto
  offline.

## Pedido ao funcional

Registrar/validar que, no Plenario Digital, cargos exercidos em sessao nao sao
configurados como roles permanentes do Core. Eles devem ser lidos do SAPL,
permitindo que a mesma pessoa tenha atribuicoes diferentes conforme a sessao,
comissao, pasta ou contexto legislativo.
