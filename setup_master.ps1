# ----------------------------------------
# ForgeMaster - Master Setup Script
# ----------------------------------------
# This script initializes a new project by:
# 1. Asking for project name and root directory.
# 2. Validating project name (only letters, numbers, _, -).
# 3. Selecting a random theme from messages.json.
# 4. Running the directory setup script.
# 5. Running the .NET Core API setup script.
# ----------------------------------------

# ✅ Save the original directory
$OriginalPath = Get-Location

# ✅ Set the base directory where projects will be created
$DefaultBasePath = "$env:USERPROFILE\source\repos"

# ✅ Ask for project name (validate input)
do {
    $ProjectName = Read-Host "[INPUT] Enter the project name (e.g., SurveyAIApp)"
    
    # Check if the name contains only valid characters
    if ($ProjectName -match "^[a-zA-Z0-9_-]+$") {
        break
    } else {
        Write-Host "[ERROR] Invalid project name! Only letters, numbers, hyphen (-), and underscore (_) are allowed." -ForegroundColor Red
    }
} while ($true)  # Loop until a valid project name is entered

# ✅ Ask for base directory (default to source/repos)
do {
    $BasePath = Read-Host "[INPUT] Enter the base path or press Enter to use [$DefaultBasePath]"
    
    # Trim spaces/tabs
    $BasePath = $BasePath.Trim()

    # Use default if empty
    if ($BasePath -eq "") {
        $BasePath = $DefaultBasePath
    }

    # Validate path format
    if (!(Test-Path -Path $BasePath -PathType Container)) {
        Write-Host "[WARN] The directory '$BasePath' does not exist." -ForegroundColor Yellow
        $CreateDir = Read-Host "[INPUT] Do you want to create it? (yes/no)"
        
        if ($CreateDir -eq "yes") {
            New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
            Write-Host "[OK] Directory '$BasePath' created successfully." -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Invalid path. Please enter a valid directory." -ForegroundColor Red
        }
    }
} while (!(Test-Path -Path $BasePath -PathType Container))  # Loop until a valid directory is entered

# ✅ Define the full project root path
$ProjectRoot = Join-Path -Path $BasePath -ChildPath $ProjectName

# ✅ Set the script directory (default to where this script is located)
$ScriptPath = $PSScriptRoot

# ✅ Load random theme from messages.json
$MessagesFile = Join-Path -Path $ScriptPath -ChildPath "messages.json"

if (!(Test-Path -Path $MessagesFile)) {
    Write-Host "[ERROR] messages.json file not found! Please ensure it exists in the script directory." -ForegroundColor Red
    exit
}

$Messages = Get-Content -Path $MessagesFile | ConvertFrom-Json
$SelectedTheme = $Messages.themes | Get-Random

# ✅ Display the startup message
Write-Host "[INFO] $($SelectedTheme.start)" -ForegroundColor Cyan

# ✅ Run the directory setup script
Write-Host "[INFO] $($SelectedTheme.dir_creation)" -ForegroundColor Yellow
& "$ScriptPath\setup_project_directories.ps1" -ProjectRoot $ProjectRoot

# ✅ Run the .NET Core API setup script (passing the correct project root)
Write-Host "[INFO] $($SelectedTheme.project_setup)" -ForegroundColor Cyan
& "$ScriptPath\setup_dotnet_api.ps1" -ProjectRoot $ProjectRoot

# ✅ Return to the original directory
Set-Location -Path $OriginalPath
Write-Host "[OK] Returning to '$OriginalPath'..." -ForegroundColor Green

# ✅ Final success message
Write-Host "[OK] $($SelectedTheme.done)" -ForegroundColor Green
