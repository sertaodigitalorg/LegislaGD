.PHONY: check clone validate

check:
	./scripts/check-repositories.sh

clone:
	./scripts/clone-components.sh

validate:
	./scripts/validate-environment.sh
