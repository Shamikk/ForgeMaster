# ----------------------------------------
# ForgeMaster - Project Directory Setup
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot and $MessagesJson from setup_master.ps1.
# 2. Checks if the directory already exists.
# 3. Asks user if they want to delete an existing project.
# 4. Requires explicit confirmation ("delete") before removing files.
# 5. Creates the full directory structure for the project.
# ----------------------------------------

# Accept parameters from setup_master.ps1
param (
    [string]$ProjectRoot,
    [PSObject]$MessagesJson
)

# Function to get a themed message
function Get-ThemedMessage {
    param (
        [string]$MessageType,
        [PSObject]$MessagesJson
    )
    
    # Get all available themes
    $themes = $MessagesJson.themes.PSObject.Properties.Name
    
    # Select a random theme
    $randomTheme = $themes | Get-Random
    
    # Return the message from the selected theme
    return $MessagesJson.themes.$randomTheme.$MessageType
}

# Validate input (ensure it's not empty)
if (-not $ProjectRoot -or $ProjectRoot -eq "") {
    Write-Host "ERROR: No project root provided! Exiting." -ForegroundColor Red
    exit
}

# Check if project directory already exists
if (Test-Path -Path $ProjectRoot) {
    Write-Host "WARNING: Project directory already exists at '$ProjectRoot'." -ForegroundColor Yellow
    $Confirmation = Read-Host "Do you want to delete it? (yes/no)"
    
    if ($Confirmation.ToLower() -ne "yes") {
        Write-Host "Setup cancelled. No changes were made." -ForegroundColor Red
        exit
    }

    # Require explicit "delete" confirmation
    Write-Host "WARNING: You are about to delete EVERYTHING in '$ProjectRoot'." -ForegroundColor Yellow
    $FinalConfirmation = Read-Host "Type 'delete' to confirm and erase all contents"
    
    if ($FinalConfirmation.ToLower() -ne "delete") {
        Write-Host "Deletion canceled. Exiting setup." -ForegroundColor Red
        exit
    }

    # Delete the existing directory
    Write-Host "Deleting existing project directory..." -ForegroundColor Yellow
    Remove-Item -Path $ProjectRoot -Recurse -Force
}

# Define the directory structure
$Directories = @(
    "apps/servers",
    "apps/clients",
    "workspace/designs",
    "workspace/reports",
    "workspace/ideas",
    "workspace/research",
    "infra/docker",
    "infra/scripts",
    "infra/configs",
    "libs/shared",
    "libs/ai",
    "tests/integration",
    "tests/unit",
    "docs"
)

# Function to create directories
function Create-Directories {
    param ($BasePath, $Dirs)
    foreach ($dir in $Dirs) {
        $fullPath = Join-Path -Path $BasePath -ChildPath $dir
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

# Create project directories
Write-Host "Creating project directory structure..." -ForegroundColor Cyan
Create-Directories -BasePath $ProjectRoot -Dirs $Directories

# Create a README.md file in the root directory
$ReadmePath = Join-Path -Path $ProjectRoot -ChildPath "README.md"
$ReadmeContent = "# $($ProjectRoot.Split('\')[-1]) Project`n`nCreated with ForgeMaster Project Setup Tool"
Set-Content -Path $ReadmePath -Value $ReadmeContent -Force

Write-Host (Get-ThemedMessage -MessageType "directory_created" -MessagesJson $MessagesJson) -ForegroundColor Green
