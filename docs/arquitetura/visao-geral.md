# Visao geral da arquitetura

O LegislaGD coordena componentes independentes por contratos, APIs e processos auditaveis.

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
