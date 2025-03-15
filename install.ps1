# ----------------------------------------
# ForgeMaster - Main Installation Script
# ----------------------------------------
# This script:
# 1. Sets up the project directory structure
# 2. Allows selection of server and client projects to install
# 3. Executes the appropriate installation scripts
# ----------------------------------------

# Define project root directory
$ForgeMasterRoot = $PSScriptRoot

# Load messages from JSON file
function Load-Messages {
    param (
        [string]$Theme = "standard"
    )
    
    $messagesPath = Join-Path -Path $ForgeMasterRoot -ChildPath "messages.json"
    if (Test-Path $messagesPath) {
        $messagesJson = Get-Content -Path $messagesPath -Raw | ConvertFrom-Json
        if ($messagesJson.themes.$Theme) {
            return $messagesJson.themes.$Theme
        }
    }
    
    # Default messages if file not found or theme not available
    return @{
        welcome           = "Welcome to the ForgeMaster Project Setup Tool"
        directory_created = "Directory structure created successfully"
        server_prompt     = "Would you like to add a server application? (yes/no)"
        client_prompt     = "Would you like to add a client application? (yes/no)"
        continue_prompt   = "Would you like to add another project? (yes/no)"
        invalid_input     = "Invalid input. Please try again."
        server_installed  = "Server application installed successfully"
        client_installed  = "Client application installed successfully"
        completion        = "Project setup completed successfully. Your development environment is ready!"
    }
}

# Check if directory structure exists
function Test-DirectoryStructure {
    param (
        [string]$ProjectRoot
    )
    
    $directories = @(
        "apps/servers",
        "apps/clients",
        "docs",
        "scripts",
        "tools"
    )
    
    foreach ($dir in $directories) {
        $path = Join-Path -Path $ProjectRoot -ChildPath $dir
        if (Test-Path $path) {
            return $true
        }
    }
    
    return $false
}

# Create base directory structure
function Create-DirectoryStructure {
    param (
        [string]$ProjectRoot,
        [object]$Messages
    )
    
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
    
    Write-Host $Messages.directory_created -ForegroundColor Green
}

# Display available server options
function Show-ServerOptions {
    Write-Host "`nAvailable server options:" -ForegroundColor Cyan
    Write-Host "1. .NET API"
    Write-Host "2. FastAPI (Python)"
    Write-Host "3. Django REST Framework"
    Write-Host "4. Express.js (Node.js)"
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
        [string]$ProjectRoot,
        [string]$ProjectName,
        [object]$Messages
    )
    
    switch ($Option) {
        1 {
            Write-Host "`nInstalling .NET API server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/servers/dotnet-api.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.server_installed -ForegroundColor Green
        }
        2 {
            Write-Host "`nInstalling FastAPI server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/servers/fastapi.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.server_installed -ForegroundColor Green
        }
        3 {
            Write-Host "`nInstalling Django REST Framework server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/servers/django-rest.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.server_installed -ForegroundColor Green
        }
        4 {
            Write-Host "`nInstalling Express.js server..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/servers/expressjs.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.server_installed -ForegroundColor Green
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
        [string]$ProjectRoot,
        [string]$ProjectName,
        [object]$Messages
    )
    
    switch ($Option) {
        1 {
            Write-Host "`nInstalling Vue/Nuxt client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/clients/vue-nuxt.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.client_installed -ForegroundColor Green
        }
        2 {
            Write-Host "`nInstalling Vue/Vite client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/clients/vue-vite.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.client_installed -ForegroundColor Green
        }
        3 {
            Write-Host "`nInstalling React/Next.js client..." -ForegroundColor Cyan
            $scriptPath = Join-Path -Path $ForgeMasterRoot -ChildPath "install-scripts/clients/react-nextjs.ps1"
            & $scriptPath -ProjectRoot $ProjectRoot -ProjectName $ProjectName
            Write-Host $Messages.client_installed -ForegroundColor Green
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
    # Load messages with default theme
    $Messages = Load-Messages -Theme "standard"
    
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       $($Messages.welcome)        " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Get project name
    $ProjectName = Read-Host "`nEnter project name"
    if ([string]::IsNullOrWhiteSpace($ProjectName)) {
        $ProjectName = "ForgeMasterProject"
        Write-Host "Using default project name: $ProjectName" -ForegroundColor Yellow
    }
    
    # Get target directory
    $defaultPath = "C:\Users\$env:USERNAME\source\repos\$ProjectName"
    $targetDir = Read-Host "`nEnter target directory for the project [$defaultPath]"
    if ([string]::IsNullOrWhiteSpace($targetDir)) {
        $targetDir = $defaultPath
        Write-Host "Using default target directory: $targetDir" -ForegroundColor Yellow
    }
    
    # Create the target directory if it doesn't exist
    if (!(Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        Write-Host "Created target directory: $targetDir" -ForegroundColor Green
    }
    else {
        # Check if directory structure already exists
        if (Test-DirectoryStructure -ProjectRoot $targetDir) {
            Write-Host "Warning: Project structure already exists in $targetDir" -ForegroundColor Yellow
            $continue = Read-Host "Do you want to continue with this directory? (yes/no)"
            
            if ($continue -ne "yes" -and $continue -ne "y") {
                Write-Host "Installation cancelled. Please run the script again with a different target directory." -ForegroundColor Red
                return
            }
            
            Write-Host "Continuing with existing directory structure..." -ForegroundColor Cyan
        }
    }
    
    # Create directory structure in the target directory
    Create-DirectoryStructure -ProjectRoot $targetDir -Messages $Messages
    
    # Server selection
    Show-ServerOptions
    $serverOption = Read-Host "`nSelect server option (0-4)"
    try {
        $serverOption = [int]$serverOption
    }
    catch {
        $serverOption = 0
        Write-Host $Messages.invalid_input -ForegroundColor Red
        Write-Host "Skipping server installation." -ForegroundColor Yellow
    }
    
    # Client selection
    Show-ClientOptions
    $clientOption = Read-Host "`nSelect client option (0-3)"
    try {
        $clientOption = [int]$clientOption
    }
    catch {
        $clientOption = 0
        Write-Host $Messages.invalid_input -ForegroundColor Red
        Write-Host "Skipping client installation." -ForegroundColor Yellow
    }
    
    # Install selected components
    Install-Server -Option $serverOption -ProjectRoot $targetDir -ProjectName $ProjectName -Messages $Messages
    Install-Client -Option $clientOption -ProjectRoot $targetDir -ProjectName $ProjectName -Messages $Messages
    
    # Installation complete
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "       Installation Complete!           " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
    Write-Host "`nProject '$ProjectName' has been set up successfully at: $targetDir" -ForegroundColor Green
    Write-Host "Server: $(if($serverOption -eq 0){"None"}elseif($serverOption -eq 1){".NET API"}elseif($serverOption -eq 2){"FastAPI"}elseif($serverOption -eq 3){"Django REST Framework"}else{"Express.js"})"
    Write-Host "Client: $(if($clientOption -eq 0){"None"}elseif($clientOption -eq 1){"Vue/Nuxt"}elseif($clientOption -eq 2){"Vue/Vite"}else{"React/Next.js"})"
    
    Write-Host "`nTo get started, navigate to your project directories:" -ForegroundColor Cyan
    
    if ($serverOption -ne 0) {
        $serverPath = "apps/servers/$(if($serverOption -eq 1){"dotnet-api"}elseif($serverOption -eq 2){"fastapi"}elseif($serverOption -eq 3){"django-rest"}else{"expressjs"})/$ProjectName"
        Write-Host "Server: $targetDir\$serverPath"
    }
    
    if ($clientOption -ne 0) {
        $clientPath = "apps/clients/$(if($clientOption -eq 1){"vue-nuxt"}elseif($clientOption -eq 2){"vue-vite"}else{"react-nextjs"})/$ProjectName"
        Write-Host "Client: $targetDir\$clientPath"
    }
    
    Write-Host "`n$($Messages.completion)" -ForegroundColor Green
}

# Start the installation process
Start-Installation 