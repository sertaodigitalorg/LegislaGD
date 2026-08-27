# Scripts

Scripts seguros e idempotentes para gerenciamento do workspace.

## Bootstrap da SDKA

`bootstrap-sdka.ps1` localiza e valida o `SD-Knowledge` como repositório irmão do
LegislaGD. A execução padrão é somente leitura:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-sdka.ps1
```

Se o repositório estiver ausente, o clone deve ser autorizado explicitamente:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-sdka.ps1 -CloneIfMissing
```
