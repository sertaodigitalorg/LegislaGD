# Visao geral da arquitetura

O LegislaGD e a plataforma central legislativa aberta. Ele coordena componentes independentes por contratos, APIs, infraestrutura compartilhada de desenvolvimento e processos auditaveis.

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
