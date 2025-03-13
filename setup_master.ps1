# ----------------------------------------
# ForgeMaster - Master Setup Script
# ----------------------------------------
# This script initializes a new project by:
# 1. Asking for project name and root directory.
# 2. Validating project name (only letters, numbers, _, -).
# 3. Loading messages from messages.json.
# 4. Running the directory setup script.
# 5. Running the server project setup script.
# 6. Running the client project setup script.
# 7. Displaying completion message.
# ----------------------------------------

# Save the original directory
$OriginalPath = Get-Location

# Set the base directory where projects will be created
$DefaultBasePath = "$env:USERPROFILE\source\repos"

# Set the script directory (where this script is located)
$ScriptPath = $PSScriptRoot

# Load messages from messages.json
$MessagesFile = Join-Path -Path $ScriptPath -ChildPath "messages.json"

if (!(Test-Path -Path $MessagesFile)) {
    Write-Host "ERROR: messages.json file not found! Please ensure it exists in the script directory." -ForegroundColor Red
    exit
}

$MessagesJson = Get-Content -Path $MessagesFile -Raw | ConvertFrom-Json

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

# Display welcome message
Write-Host (Get-ThemedMessage -MessageType "welcome" -MessagesJson $MessagesJson) -ForegroundColor Cyan

# Ask for project name (validate input)
do {
    $ProjectName = Read-Host "Enter the project name"
    
    # Check if the name contains only valid characters
    if ($ProjectName -match "^[a-zA-Z0-9_-]+$") {
        break
    }
    else {
        Write-Host "Invalid project name! Only letters, numbers, hyphen (-), and underscore (_) are allowed." -ForegroundColor Red
    }
} while ($true)  # Loop until a valid project name is entered

# Ask for base directory (default to source/repos)
do {
    $BasePath = Read-Host "Enter the base path or press Enter to use [$DefaultBasePath]"
    
    # Trim spaces/tabs
    $BasePath = $BasePath.Trim()

    # Use default if empty
    if ($BasePath -eq "") {
        $BasePath = $DefaultBasePath
    }

    # Validate path format
    if (!(Test-Path -Path $BasePath -PathType Container)) {
        Write-Host "The directory '$BasePath' does not exist." -ForegroundColor Yellow
        $CreateDir = Read-Host "Do you want to create it? (yes/no)"
        
        if ($CreateDir -eq "yes") {
            New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
            Write-Host "Directory '$BasePath' created successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Invalid path. Please enter a valid directory." -ForegroundColor Red
        }
    }
} while (!(Test-Path -Path $BasePath -PathType Container))  # Loop until a valid directory is entered

# Define the full project root path
$ProjectRoot = Join-Path -Path $BasePath -ChildPath $ProjectName

# Run the directory setup script
Write-Host "Setting up project directories..." -ForegroundColor Yellow
& "$ScriptPath\setup_project_directories.ps1" -ProjectRoot $ProjectRoot -MessagesJson $MessagesJson

# Initialize arrays to track installed projects
$installedServerProjects = @()
$installedClientProjects = @()

# Main loop for project selection
$continueSetup = $true
while ($continueSetup) {
    # Run the server project setup script
    $installedServerProjects = & "$ScriptPath\setup_server_project.ps1" -ProjectRoot $ProjectRoot -MessagesJson $MessagesJson -InstalledProjects $installedServerProjects
    
    # Run the client project setup script
    $installedClientProjects = & "$ScriptPath\setup_client_project.ps1" -ProjectRoot $ProjectRoot -MessagesJson $MessagesJson -InstalledProjects $installedClientProjects
    
    # Check if all projects are installed
    $allServerProjectsInstalled = ($installedServerProjects.Count -eq 4)  # 4 server projects available
    $allClientProjectsInstalled = ($installedClientProjects.Count -eq 3)  # 3 client projects available
    
    if ($allServerProjectsInstalled -and $allClientProjectsInstalled) {
        Write-Host "`nAll projects have been installed." -ForegroundColor Green
        $continueSetup = $false
    }
    else {
        # Ask if user wants to continue
        $continue = Read-Host (Get-ThemedMessage -MessageType "continue_prompt" -MessagesJson $MessagesJson)
        if ($continue.ToLower() -ne "yes") {
            $continueSetup = $false
        }
    }
}

# Return to the original directory
Set-Location -Path $OriginalPath

# Display completion message
Write-Host "`n" + (Get-ThemedMessage -MessageType "completion" -MessagesJson $MessagesJson) -ForegroundColor Green

# Final message with project path
Write-Host "Project created at: $ProjectRoot" -ForegroundColor Cyan

