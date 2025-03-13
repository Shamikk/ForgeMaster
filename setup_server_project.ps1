# ----------------------------------------
# ForgeMaster - Server Project Setup
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot, $MessagesJson, and $InstalledProjects from setup_master.ps1.
# 2. Displays available server projects.
# 3. Allows user to select a server project to install.
# 4. Installs the selected server project.
# 5. Returns the updated list of installed projects.
# ----------------------------------------

# Accept parameters from setup_master.ps1
param (
    [string]$ProjectRoot,
    [PSObject]$MessagesJson,
    [string[]]$InstalledProjects = @()
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

# Function to get user input with validation
function Get-ValidatedInput {
    param (
        [string]$Prompt,
        [string[]]$ValidOptions,
        [PSObject]$MessagesJson
    )
    
    $input = ""
    $isValid = $false
    
    while (-not $isValid) {
        $input = Read-Host -Prompt $Prompt
        if ($ValidOptions -contains $input.ToLower()) {
            $isValid = $true
        }
        else {
            Write-Host (Get-ThemedMessage -MessageType "invalid_input" -MessagesJson $MessagesJson) -ForegroundColor Yellow
        }
    }
    
    return $input.ToLower()
}

# Function to install a server project
function Install-ServerProject {
    param (
        [string]$ProjectType,
        [string]$ProjectName,
        [string]$ProjectRoot,
        [PSObject]$MessagesJson
    )
    
    $projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/$ProjectName"
    
    # Create project directory
    New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
    
    # Create a placeholder file to simulate project installation
    $placeholderContent = "# $ProjectType Server Project`nThis is a placeholder for the $ProjectType server project."
    Set-Content -Path "$projectPath/README.md" -Value $placeholderContent
    
    Write-Host (Get-ThemedMessage -MessageType "server_installed" -MessagesJson $MessagesJson) -ForegroundColor Green
}

# Define available server projects
$serverProjects = @(
    @{Name = ".NET API"; DirectoryName = "dotnet-api" },
    @{Name = "FastAPI"; DirectoryName = "fastapi" },
    @{Name = "Django REST"; DirectoryName = "django-rest" },
    @{Name = "Express.js"; DirectoryName = "expressjs" }
)

# Ask if user wants to add a server application
$addServer = Get-ValidatedInput -Prompt (Get-ThemedMessage -MessageType "server_prompt" -MessagesJson $MessagesJson) -ValidOptions @("yes", "no") -MessagesJson $MessagesJson

if ($addServer -eq "yes") {
    # Display available server projects
    Write-Host "`nAvailable server projects:" -ForegroundColor Cyan
    $index = 1
    $availableServerProjects = @()
    
    foreach ($project in $serverProjects) {
        if ($InstalledProjects -notcontains $project.DirectoryName) {
            Write-Host "$index. $($project.Name)" -ForegroundColor White
            $availableServerProjects += $project
            $index++
        }
    }
    
    # Display installed server projects
    if ($InstalledProjects.Count -gt 0) {
        Write-Host "`nAlready installed server projects:" -ForegroundColor DarkGray
        foreach ($installedProject in $InstalledProjects) {
            $projectName = ($serverProjects | Where-Object { $_.DirectoryName -eq $installedProject }).Name
            if ($projectName) {
                Write-Host "[x] $projectName" -ForegroundColor Red
            }
        }
    }
    
    # Add Cancel option
    Write-Host "$index. Cancel" -ForegroundColor Yellow
    
    # Get user selection
    $maxOption = $availableServerProjects.Count + 1
    $validOptions = 1..$maxOption | ForEach-Object { $_.ToString() }
    $serverSelection = Get-ValidatedInput -Prompt "Select a server project (1-$maxOption)" -ValidOptions $validOptions -MessagesJson $MessagesJson
    
    # Process selection
    if ([int]$serverSelection -eq $maxOption) {
        Write-Host "Server project selection cancelled." -ForegroundColor Yellow
    }
    else {
        $selectedProject = $availableServerProjects[[int]$serverSelection - 1]
        Install-ServerProject -ProjectType $selectedProject.Name -ProjectName $selectedProject.DirectoryName -ProjectRoot $ProjectRoot -MessagesJson $MessagesJson
        $InstalledProjects += $selectedProject.DirectoryName
    }
}

# Return the updated list of installed projects
return $InstalledProjects 