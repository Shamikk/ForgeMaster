# ----------------------------------------
# ForgeMaster - Main Installation Script
# ----------------------------------------
# This script:
# 1. Sets up the project directory structure
# 2. Allows selection of server and client projects to install
# 3. Executes the appropriate installation scripts
# ----------------------------------------

# Define project root directory
$ProjectRoot = $PSScriptRoot

# Create base directory structure
function Create-DirectoryStructure {
    Write-Host "Creating project directory structure..." -ForegroundColor Cyan
    
    $directories = @(
        "apps/servers",
        "apps/clients",
        "docs",
        "scripts",
        "tools"
    )
    
    foreach ($dir in $directories) {
        $path = Join-Path -Path $ProjectRoot -ChildPath $dir
        if (!(Test-Path $path)) {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
        }
    }
    
    Write-Host "Directory structure created successfully!" -ForegroundColor Green
}

# Display available server options
function Show-ServerOptions {
    Write-Host "`nAvailable server options:" -ForegroundColor Cyan
    Write-Host "1. .NET API"
    Write-Host "2. FastAPI (Python)"
    Write-Host "3. Django REST Framework"
    Write-Host "0. Skip server installation"
}

# Display available client options
function Show-ClientOptions {
    Write-Host "`nAvailable client options:" -ForegroundColor Cyan
    Write-Host "1. Vue/Nuxt"
    Write-Host "2. Vue/Vite"
    Write-Host "3. React/Next.js"
    Write-Host "0. Skip client installation"
}

# Install selected server
function Install-Server {
    param (
        [int]$Option,
        [string]$ProjectName
    )
    
    switch ($Option) {
        1 {
            Write-Host "`nInstalling .NET API server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/servers/dotnet-api.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        2 {
            Write-Host "`nInstalling FastAPI server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/servers/fastapi.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        3 {
            Write-Host "`nInstalling Django REST Framework server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/servers/django-rest.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        0 {
            Write-Host "`nSkipping server installation." -ForegroundColor Yellow
        }
        default {
            Write-Host "`nInvalid option. Skipping server installation." -ForegroundColor Red
        }
    }
}

# Install selected client
function Install-Client {
    param (
        [int]$Option,
        [string]$ProjectName
    )
    
    switch ($Option) {
        1 {
            Write-Host "`nInstalling Vue/Nuxt client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/clients/vue-nuxt.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        2 {
            Write-Host "`nInstalling Vue/Vite client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/clients/vue-vite.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        3 {
            Write-Host "`nInstalling React/Next.js client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ProjectRoot -ChildPath "install-scripts/clients/react-nextjs.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
        }
        0 {
            Write-Host "`nSkipping client installation." -ForegroundColor Yellow
        }
        default {
            Write-Host "`nInvalid option. Skipping client installation." -ForegroundColor Red
        }
    }
}

# Main installation process
function Start-Installation {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       ForgeMaster Project Setup        " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Create directory structure
    Create-DirectoryStructure
    
    # Get project name
    $ProjectName = Read-Host "`nEnter project name"
    if ([string]::IsNullOrWhiteSpace($ProjectName)) {
        $ProjectName = "ForgeMasterProject"
        Write-Host "Using default project name: $ProjectName" -ForegroundColor Yellow
    }
    
    # Server selection
    Show-ServerOptions
    $serverOption = Read-Host "`nSelect server option (0-3)"
    try {
        $serverOption = [int]$serverOption
    } catch {
        $serverOption = 0
        Write-Host "Invalid input. Skipping server installation." -ForegroundColor Red
    }
    
    # Client selection
    Show-ClientOptions
    $clientOption = Read-Host "`nSelect client option (0-3)"
    try {
        $clientOption = [int]$clientOption
    } catch {
        $clientOption = 0
        Write-Host "Invalid input. Skipping client installation." -ForegroundColor Red
    }
    
    # Install selected components
    Install-Server -Option $serverOption -ProjectName $ProjectName
    Install-Client -Option $clientOption -ProjectName $ProjectName
    
    # Installation complete
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "       Installation Complete!           " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
    Write-Host "`nProject '$ProjectName' has been set up successfully!" -ForegroundColor Green
    Write-Host "Server: $(if($serverOption -eq 0){"None"}elseif($serverOption -eq 1){".NET API"}elseif($serverOption -eq 2){"FastAPI"}else{"Django REST Framework"})"
    Write-Host "Client: $(if($clientOption -eq 0){"None"}elseif($clientOption -eq 1){"Vue/Nuxt"}elseif($clientOption -eq 2){"Vue/Vite"}else{"React/Next.js"})"
    
    Write-Host "`nTo get started, navigate to your project directories:" -ForegroundColor Cyan
    
    if ($serverOption -ne 0) {
        $serverPath = "apps/servers/$(if($serverOption -eq 1){"dotnet-api"}elseif($serverOption -eq 2){"fastapi"}else{"django-rest"})/$ProjectName"
        Write-Host "Server: $serverPath"
    }
    
    if ($clientOption -ne 0) {
        $clientPath = "apps/clients/$(if($clientOption -eq 1){"vue-nuxt"}elseif($clientOption -eq 2){"vue-vite"}else{"react-nextjs"})/$ProjectName"
        Write-Host "Client: $clientPath"
    }
}

# Start the installation process
Start-Installation 