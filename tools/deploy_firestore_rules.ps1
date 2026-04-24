#!/usr/bin/env pwsh
# Script: Deploy Firestore Rules para FisioIA
# Objetivo: desplegar firestore.rules a tu proyecto Firebase de forma automatizada

param(
    [switch]$SkipLogin,
    [switch]$Verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Step { Write-Host "`n[•] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[✓] $args" -ForegroundColor Green }
function Write-Error { Write-Host "[✗] $args" -ForegroundColor Red }

$RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommandPath)
$AppPath = Join-Path $RootPath "app"

Write-Host "`n=== FisioIA Firestore Rules Deployment ===" -ForegroundColor Yellow

# 1. Verificar Firebase CLI
Write-Step "Verificando Firebase CLI..."
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Error "Firebase CLI no está instalado."
    Write-Host "Instálalo con: npm install -g firebase-tools"
    exit 1
}
Write-Success "Firebase CLI detectado"

# 2. Verificar archivos
Write-Step "Verificando archivos de configuración..."
$RulesFile = Join-Path $AppPath "firestore.rules"
$JsonFile = Join-Path $AppPath "firebase.json"

if (-not (Test-Path $RulesFile)) {
    Write-Error "firestore.rules no encontrado en $RulesFile"
    exit 1
}
Write-Success "✓ firestore.rules"

if (-not (Test-Path $JsonFile)) {
    Write-Error "firebase.json no encontrado en $JsonFile"
    exit 1
}
Write-Success "✓ firebase.json"

# 3. Login (opcional)
if (-not $SkipLogin) {
    Write-Step "Comprobando autenticación Firebase..."
    $AuthStatus = & firebase auth:export --project test 2>&1
    if ($AuthStatus -like "*not authenticated*") {
        Write-Step "Se requiere autenticación. Abriendo navegador..."
        & firebase login
    } else {
        Write-Success "Ya autenticado"
    }
}

# 4. Configurar proyecto (si no está configurado)
Write-Step "Comprobando configuración del proyecto..."
Push-Location $AppPath
try {
    $CurrentProject = & firebase projects:list --json 2>&1 | ConvertFrom-Json | Select-Object -First 1
    if ($null -eq $CurrentProject) {
        Write-Step "No hay proyecto configurado. Ejecutando 'firebase use --add'..."
        & firebase use --add
    } else {
        Write-Success "Proyecto ya configurado: $($CurrentProject.name)"
    }
} finally {
    Pop-Location
}

# 5. Desplegar
Write-Step "Desplegando reglas de Firestore..."
Write-Host "  Esto puede tardar 10-30 segundos..." -ForegroundColor Gray

Push-Location $AppPath
try {
    $DeployOutput = & firebase deploy --only firestore:rules 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Despliegue fallido. Salida:"
        Write-Host $DeployOutput -ForegroundColor Red
        exit 1
    }
    Write-Success "¡Despliegue completado exitosamente!"
    Write-Host $DeployOutput
} finally {
    Pop-Location
}

# 6. Resumen
Write-Host "`n=== Resumen ===" -ForegroundColor Yellow
Write-Host "✓ Reglas desplegadas en Firestore"
Write-Host "✓ Cada usuario puede acceder solo a sus datos (RLS)"
Write-Host ""
Write-Host "Próximo paso:" -ForegroundColor Cyan
Write-Host "  1. Lee 'firestore_security_deployment.md' para plan de pruebas"
Write-Host "  2. Ejecuta los tests de seguridad (Test 1-5)"
Write-Host "  3. Documenta resultados para defensa del proyecto"
Write-Host ""
Write-Host "Firebase Console: https://console.firebase.google.com/" -ForegroundColor Gray
