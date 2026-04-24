param(
  [string]$SinceRef = "",
  [string]$OutFile = ""
)

function ExecGit([string[]]$GitArgs) {
  $output = & git @GitArgs 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed: $output"
  }
  return ($output | Out-String).TrimEnd()
}

try {
  $repoRoot = (& git rev-parse --show-toplevel 2>$null | Out-String).Trim()
  if (-not $repoRoot) {
    Write-Error "No estás dentro de un repositorio git. Ejecuta este script desde el repo."
    exit 1
  }

  Set-Location $repoRoot

  $branch = ExecGit @('rev-parse', '--abbrev-ref', 'HEAD')
  $head = ExecGit @('rev-parse', 'HEAD')

  $statePath = Join-Path $repoRoot 'tools/.memoria_state.json'
  $lastHead = ""
  if (Test-Path $statePath) {
    try {
      $state = Get-Content $statePath -Raw -Encoding utf8 | ConvertFrom-Json
      $lastHead = ($state.lastHead | Out-String).Trim()
    } catch {
      $lastHead = ""
    }
  }

  $range = ""
  $base = ""

  if ($SinceRef -and $SinceRef.Contains('..')) {
    $range = $SinceRef
  } elseif ($SinceRef) {
    $base = ExecGit @('rev-parse', $SinceRef)
    $range = "$base..HEAD"
  } elseif ($lastHead) {
    # Use last generated HEAD as baseline, if it exists.
    $base = ExecGit @('rev-parse', $lastHead)
    $range = "$base..HEAD"
  } else {
    $hasOriginMain = $false
    & git show-ref --verify --quiet refs/remotes/origin/main
    if ($LASTEXITCODE -eq 0) { $hasOriginMain = $true }

    if ($hasOriginMain) {
      $base = ExecGit @('merge-base', 'HEAD', 'origin/main')
      $range = "$base..HEAD"
    } else {
      # Fallback: últimos 20 commits (si el repo es pequeño, esto suele ser suficiente)
      $base = ExecGit @('rev-parse', 'HEAD~20')
      $range = "$base..HEAD"
    }
  }

  $today = Get-Date -Format 'yyyy-MM-dd'
  if (-not $OutFile) {
    # Single stable draft file (overwrite each run) to avoid creating many files.
    $inRepoMemoria = Join-Path $repoRoot 'docs/memoria'
    if (Test-Path $inRepoMemoria) {
      $OutFile = Join-Path $repoRoot "docs/memoria/borradores/memoria_git_borrador.md"
    } else {
      $outside = Join-Path $repoRoot '..\\Documentación\\memoria\\borradores'
      $OutFile = Join-Path $outside "memoria_git_borrador.md"
    }
  }

  $outDir = Split-Path -Parent $OutFile
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null

  $commitCount = ExecGit @('rev-list', '--count', $range)
  $log = ExecGit @('log', '--oneline', '--no-decorate', $range)
  $diffStat = ExecGit @('diff', '--stat', $range)
  $nameStatus = ExecGit @('diff', '--name-status', $range)

  $status = (& git status --porcelain | Out-String).TrimEnd()
  $wtStat = ""
  $wtFiles = ""
  if ($status) {
    $wtStat = (& git diff --stat | Out-String).TrimEnd()
    $wtFiles = (& git diff --name-status | Out-String).TrimEnd()
  }

  $content = @()
  $content += "# Memoria - borrador automatico (overwrite)"
  $content += ""
  $content += "## Contexto"
  $content += "- Rama: $branch"
  $content += "- HEAD: $head"
  $content += "- Rango: $range"
  $content += "- Num commits en el rango: $commitCount"
  $content += ""
  $content += "## Resumen (rellenar)"
  $content += "- Qué se ha hecho hoy:"
  $content += "- Qué se ha validado (flutter test/analyze, APK, Firebase/Azure):"
  $content += "- Qué queda pendiente:"
  $content += ""
  $content += "## Commits incluidos"
  $content += '```'
  $content += $log
  $content += '```'
  $content += ""
  $content += "## Cambios (diff --stat)"
  $content += '```'
  $content += $diffStat
  $content += '```'
  $content += ""
  $content += "## Archivos tocados (name-status)"
  $content += '```'
  $content += $nameStatus
  $content += '```'

  if ($status) {
    $content += ""
    $content += "## Cambios sin commitear (working tree)"
    $content += '```'
    $content += $status
    $content += '```'

    if ($wtStat) {
      $content += ""
      $content += "### Working tree (diff --stat)"
      $content += '```'
      $content += $wtStat
      $content += '```'
    }

    if ($wtFiles) {
      $content += ""
      $content += "### Working tree (name-status)"
      $content += '```'
      $content += $wtFiles
      $content += '```'
    }
  }

  $content += ""
  $content += "## Evidencias sugeridas (anadir capturas/links)"
  $content += "- Captura: Firestore `users/{uid}/routines/{routineId}` con 2-3 rutinas."
  $content += "- Captura: pantalla 'Mi perfil' + documento `users/{uid}` con nombre/edad/zonaPrincipalId."
  $content += "- Captura: chat (aviso medico) + ejemplo de generacion `rutina hombro` -> `guardar rutina`."
  $content += "- Salidas: `flutter analyze` y `flutter test` en verde."
  $content += ""
  $content += "## Riesgos / decisiones (rellenar)"
  $content += "- Riesgos:"
  $content += "- Decisiones técnicas tomadas:"
  $content += "- Mejoras futuras (premium/admin/límites server-side):"

  Set-Content -Path $OutFile -Value ($content -join "`n") -Encoding utf8

  # Persist state for next run (local file, should be gitignored)
  try {
    $stateObj = [ordered]@{
      lastHead = $head
      lastRange = $range
      lastOutFile = $OutFile
      updatedAt = (Get-Date).ToString('o')
    }
    $stateJson = ($stateObj | ConvertTo-Json -Depth 3)
    $stateDir = Split-Path -Parent $statePath
    New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
    Set-Content -Path $statePath -Value $stateJson -Encoding utf8
  } catch {
    # ignore state write errors
  }

  Write-Host "Generado: $OutFile"
} catch {
  Write-Error $_
  exit 1
}
