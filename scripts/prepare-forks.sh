#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
Este script e deliberadamente informativo e serve como referencia operacional.

Para publicar ou reinicializar forks remotos em sertaoDigitalorg:

1. Use GitHub CLI autenticado com permissao na organizacao.
2. Revise se o repositorio destino esta vazio ou se o historico pode ser substituido.
3. Execute push normal para repos vazios.
4. Use force push somente apos confirmacao explicita e backup ou quando a fonte canonica estiver formalmente definida.

Forks oficiais do Sertao Digital usados pelo LegislaGD:
- SAPL-SD: https://github.com/sertaodigitalorg/SAPL-SD.git
- PortalModelo-SD: https://github.com/sertaodigitalorg/PortalModelo-SD.git
- SIGI-SD: https://github.com/sertaodigitalorg/SIGI-SD.git
- e-Cidade-SD: https://github.com/sertaodigitalorg/e-Cidade-SD.git

Upstreams autorizados:
- SAPL-SD: https://github.com/interlegis/sapl.git
- PortalModelo-SD: https://github.com/interlegis/portalmodelo.git
- e-Cidade-SD: https://github.com/DBSeller/e-cidade.git

SIGI-SD e mantido pelas equipes do Sertao Digital e nao usa upstream externo nesta etapa.

O script clone-components.sh clona os forks oficiais usando a branch configurada
por LEGISLAGD_COMPONENT_BRANCH ou pelas variaveis especificas de cada modulo.
MSG
