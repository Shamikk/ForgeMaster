# ----------------------------------------
# ForgeMaster - .NET API Setup Script
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot and $SelectedTheme from setup_master.ps1.
# 2. Ensures the correct directory structure.
# 3. Asks user whether to run the project.
# 4. If declined, provides instructions on how to run it manually.
# ----------------------------------------

# ✅ Accept parameters from setup_master.ps1
param (
    [string]$ProjectRoot,
    [PSObject]$SelectedTheme
)

# ✅ Validate input (ensure it's not empty)
if (-not $ProjectRoot -or $ProjectRoot -eq "") {
    Write-Host "[ERROR] No project root provided! Exiting." -ForegroundColor Red
    exit
}

# ✅ Define the correct directory for .NET API
$DotnetApiPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/dotnet-api"

# ✅ Ensure the directory exists
if (!(Test-Path -Path $DotnetApiPath)) {
    New-Item -ItemType Directory -Path $DotnetApiPath -Force | Out-Null
}

# ✅ Navigate to the correct directory
Set-Location -Path $DotnetApiPath

# ✅ Create a new .NET Web API project in this directory
Write-Host "[INFO] $($SelectedTheme.dotnet.create)" -ForegroundColor Cyan
dotnet new webapi --force

# ✅ Ask the user if they want to run the project
Write-Host "[INPUT] $($SelectedTheme.dotnet.run_prompt)" -ForegroundColor Yellow
$RunProject = Read-Host

if ($RunProject.ToLower() -eq "yes") {
    Write-Host "[INFO] $($SelectedTheme.dotnet.running)" -ForegroundColor Green
    dotnet run
}
else {
    Write-Host "[INFO] $($SelectedTheme.dotnet.manual)" -ForegroundColor Yellow
    Write-Host "`n  cd '$DotnetApiPath'" -ForegroundColor Cyan
    Write-Host "  dotnet run`n" -ForegroundColor Cyan
}
