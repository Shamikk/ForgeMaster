# ----------------------------------------
# ForgeMaster - .NET API Setup Script
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot from setup_master.ps1.
# 2. Ensures the correct directory structure.
# 3. Asks user whether to run the project.
# 4. If declined, provides instructions on how to run it manually.
# ----------------------------------------

# ✅ Accept $ProjectRoot from setup_master.ps1
param (
    [string]$ProjectRoot
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
Write-Host "[INFO] Creating .NET Core API project in '$DotnetApiPath'..." -ForegroundColor Cyan
dotnet new webapi --force

# ✅ Ask the user if they want to run the project
$RunProject = Read-Host "[INPUT] Do you want to run the project now? (yes/no)"

if ($RunProject.ToLower() -eq "yes") {
    Write-Host "[INFO] Running the .NET Core API project..." -ForegroundColor Green
    dotnet run
} else {
    Write-Host "[INFO] You can run the project manually later with the following commands:" -ForegroundColor Yellow
    Write-Host "`n  cd '$DotnetApiPath'" -ForegroundColor Cyan
    Write-Host "  dotnet run`n" -ForegroundColor Cyan
}
