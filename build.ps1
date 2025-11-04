#!/usr/bin/env pwsh
# CarOS Profile Switcher - Build Script
# Creates a release ZIP for Magisk installation

param(
    [Parameter(Mandatory=$false)]
    [string]$Version = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Show-Help {
    Write-Host @"
CarOS Profile Switcher Build Script
====================================

Usage: .\build.ps1 [-Version <version>] [-Help]

Options:
  -Version   Specify version number (e.g., "0.2.4")
             If not provided, will extract from module.prop
  -Help      Show this help message

Examples:
  .\build.ps1                    # Auto-detect version from module.prop
  .\build.ps1 -Version "0.2.4"   # Build with specific version

The script will:
1. Read or use the provided version number
2. Create the rel/ directory if needed
3. Package all necessary files into a ZIP
4. Save to rel/CarOS_Profile_Switcher-v{VERSION}.zip

"@
    exit 0
}

if ($Help) {
    Show-Help
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "🚗 CarOS Profile Switcher - Build Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Extract version from module.prop if not provided
if ([string]::IsNullOrEmpty($Version)) {
    if (Test-Path "module.prop") {
        $content = Get-Content "module.prop"
        $versionLine = $content | Where-Object { $_ -match "^version=" }
        if ($versionLine) {
            $Version = ($versionLine -split "=")[1].Trim()
            Write-Host "📋 Version detected from module.prop: $Version" -ForegroundColor Green
        } else {
            Write-Host "❌ Error: Could not find version in module.prop" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Error: module.prop not found!" -ForegroundColor Red
        exit 1
    }
}

# Validate required files exist
$RequiredFiles = @(
    "caros_config.sh",
    "module.prop",
    "post-fs-data.sh",
    "service.sh",
    "system.prop",
    "grant_permissions.sh",
    "META-INF\com\google\android\update-binary",
    "META-INF\com\google\android\updater-script"
)

$MissingFiles = @()
foreach ($file in $RequiredFiles) {
    if (-not (Test-Path $file)) {
        $MissingFiles += $file
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host "❌ Error: Missing required files:" -ForegroundColor Red
    $MissingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "✅ All required files found" -ForegroundColor Green

# Create rel directory if it doesn't exist
if (-not (Test-Path "rel")) {
    New-Item -ItemType Directory -Path "rel" | Out-Null
    Write-Host "📁 Created rel/ directory" -ForegroundColor Yellow
}

# Define output file
$OutputFile = "rel\CarOS_Profile_Switcher-v$Version.zip"

# Remove existing file if present
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
    Write-Host "🗑️  Removed existing release file" -ForegroundColor Yellow
}

# Create the ZIP archive
Write-Host "📦 Creating release package..." -ForegroundColor Cyan

try {
    Compress-Archive -Path @(
        "caros_config.sh",
        "module.prop",
        "post-fs-data.sh",
        "service.sh",
        "system.prop",
        "grant_permissions.sh",
        "META-INF"
    ) -DestinationPath $OutputFile -CompressionLevel Optimal
    
    Write-Host ""
    Write-Host "✅ SUCCESS! Release created:" -ForegroundColor Green
    Write-Host "   📄 $OutputFile" -ForegroundColor White
    
    # Get file size
    $FileSize = (Get-Item $OutputFile).Length
    $FileSizeKB = [math]::Round($FileSize / 1KB, 2)
    Write-Host "   📊 Size: $FileSizeKB KB" -ForegroundColor White
    Write-Host ""
    Write-Host "📤 Ready to install via Magisk Manager!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ Error creating ZIP archive:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
