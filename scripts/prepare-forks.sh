#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
Este script e deliberadamente informativo.

Para publicar ou reinicializar forks remotos em sertaoDigitalorg, e necessario:

1. Ter GitHub CLI instalado e autenticado com permissao na organizacao.
2. Revisar se o repositorio destino esta vazio ou se o historico pode ser substituido.
3. Executar push normal para repos vazios.
4. Usar force push somente apos confirmacao explicita e backup.

Origens autorizadas:
- SAPL-SD: https://github.com/interlegis/sapl.git
- PortalModelo-SD: https://github.com/interlegis/portalmodelo.git
- e-Cidade-SD: https://github.com/DBSeller/e-cidade.git

SIGI-SD e mantido pelas equipes do Sertao Digital e nao usa upstream externo nesta etapa.
MSG
