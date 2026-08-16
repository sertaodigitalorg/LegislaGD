[CmdletBinding()]
param(
    [switch]$CloneIfMissing
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $projectRoot '.sdka.yaml'

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Manifesto SDKA nao encontrado: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw
$projectNameMatch = [regex]::Match($manifest, '(?ms)^project:\s*.*?^\s{2}name:\s*(?<value>[^#\r\n]+)')
$repositoryMatch = [regex]::Match($manifest, '(?ms)^knowledge:\s*.*?^\s{2}repository:\s*(?<value>[^#\r\n]+)')

if (-not $projectNameMatch.Success -or $projectNameMatch.Groups['value'].Value.Trim() -ne 'LegislaGD') {
    throw 'O projeto atual nao foi identificado como LegislaGD em .sdka.yaml.'
}

if (-not $repositoryMatch.Success) {
    throw 'knowledge.repository nao foi encontrado em .sdka.yaml.'
}

$knowledgeRepository = $repositoryMatch.Groups['value'].Value.Trim().Trim('"', "'")
$workspaceRoot = Split-Path -Parent $projectRoot
$knowledgeRoot = Join-Path $workspaceRoot 'SD-Knowledge'

function Normalize-GitRemote([string]$Remote) {
    return ($Remote.Trim() -replace '\.git$', '').TrimEnd('/').ToLowerInvariant()
}

if (Test-Path -LiteralPath $knowledgeRoot) {
    if (-not (Test-Path -LiteralPath (Join-Path $knowledgeRoot '.git'))) {
        throw "O caminho esperado existe, mas nao e um repositorio Git: $knowledgeRoot"
    }

    $origin = git -C $knowledgeRoot remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Nao foi possivel ler o remote origin de $knowledgeRoot"
    }

    if ((Normalize-GitRemote $origin) -ne (Normalize-GitRemote $knowledgeRepository)) {
        throw "O remote origin de $knowledgeRoot nao corresponde a $knowledgeRepository"
    }

    Write-Output "SD-Knowledge localizado e validado: $knowledgeRoot"
    exit 0
}

if (-not $CloneIfMissing) {
    throw "SD-Knowledge nao encontrado em $knowledgeRoot. Execute novamente com -CloneIfMissing apos obter autorizacao."
}

Write-Output "Clonando $knowledgeRepository em $knowledgeRoot"
git clone -- $knowledgeRepository $knowledgeRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Falha ao clonar o SD-Knowledge.'
}

Write-Output "SD-Knowledge clonado: $knowledgeRoot"
