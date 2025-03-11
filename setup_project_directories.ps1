# ----------------------------------------
# ForgeMaster - Project Directory Setup
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot from setup_master.ps1.
# 2. Checks if the directory already exists.
# 3. Asks user if they want to delete an existing project.
# 4. Requires explicit confirmation ("delete") before removing files.
# 5. Creates the full directory structure for the project.
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

# ✅ Check if project directory already exists
if (Test-Path -Path $ProjectRoot) {
    Write-Host "[WARN] The project directory '$ProjectRoot' already exists." -ForegroundColor Yellow
    $Confirmation = Read-Host "[INPUT] Do you want to delete it? (yes/no)"
    
    if ($Confirmation.ToLower() -ne "yes") {
        Write-Host "[ERROR] Exiting setup. No changes were made." -ForegroundColor Red
        exit
    }

    # ✅ Require explicit "delete" confirmation
    $FinalConfirmation = Read-Host "[INPUT] Type 'delete' to confirm and erase EVERYTHING in '$ProjectRoot'!"
    
    if ($FinalConfirmation.ToLower() -ne "delete") {
        Write-Host "[ERROR] Deletion canceled. Exiting setup." -ForegroundColor Red
        exit
    }

    # ✅ Delete the existing directory
    Write-Host "[DELETE] Deleting existing directory '$ProjectRoot'..." -ForegroundColor Yellow
    Remove-Item -Path $ProjectRoot -Recurse -Force
    Write-Host "[OK] Directory deleted successfully." -ForegroundColor Green
}

# ✅ Define the directory structure
$Directories = @(
    "apps/servers/dotnet-api",
    "apps/servers/python-api",
    "apps/servers/js-server",
    "apps/clients/vue-nuxt",
    "apps/clients/vue-vite",
    "apps/clients/react-next",
    "workspace/docs",
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
    "tests/unit"
)

# ✅ Function to create directories
function Create-Directories {
    param ($BasePath, $Dirs)
    foreach ($dir in $Dirs) {
        $fullPath = Join-Path -Path $BasePath -ChildPath $dir
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

# ✅ Create project directories
Write-Host "[INFO] Creating project directories at '$ProjectRoot'..." -ForegroundColor Cyan
Create-Directories -BasePath $ProjectRoot -Dirs $Directories

# ✅ Create a README.md file in the root directory
$ReadmePath = Join-Path -Path $ProjectRoot -ChildPath "README.md"
New-Item -ItemType File -Path $ReadmePath -Force | Out-Null

Write-Host "[OK] Project structure created successfully at '$ProjectRoot'." -ForegroundColor Green
