# ----------------------------------------
# ForgeMaster - Client Project Setup
# ----------------------------------------
# This script:
# 1. Accepts $ProjectRoot, $MessagesJson, and $InstalledProjects from setup_master.ps1.
# 2. Displays available client projects.
# 3. Allows user to select a client project to install.
# 4. Installs the selected client project.
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

# Function to install a client project
function Install-ClientProject {
    param (
        [string]$ProjectType,
        [string]$ProjectName,
        [string]$ProjectRoot,
        [PSObject]$MessagesJson
    )
    
    $projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/$ProjectName"
    
    # Create project directory
    New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
    
    # Create a placeholder file to simulate project installation
    $placeholderContent = "# $ProjectType Client Project`nThis is a placeholder for the $ProjectType client project."
    Set-Content -Path "$projectPath/README.md" -Value $placeholderContent
    
    Write-Host (Get-ThemedMessage -MessageType "client_installed" -MessagesJson $MessagesJson) -ForegroundColor Green
}

# Define available client projects
$clientProjects = @(
    @{Name = "Vue/Nuxt"; DirectoryName = "vue-nuxt" },
    @{Name = "Vue/Vite"; DirectoryName = "vue-vite" },
    @{Name = "React/Next.js"; DirectoryName = "react-nextjs" }
)

# Ask if user wants to add a client application
$addClient = Get-ValidatedInput -Prompt (Get-ThemedMessage -MessageType "client_prompt" -MessagesJson $MessagesJson) -ValidOptions @("yes", "no") -MessagesJson $MessagesJson

if ($addClient -eq "yes") {
    # Display available client projects
    Write-Host "`nAvailable client projects:" -ForegroundColor Cyan
    $index = 1
    $availableClientProjects = @()
    
    foreach ($project in $clientProjects) {
        if ($InstalledProjects -notcontains $project.DirectoryName) {
            Write-Host "$index. $($project.Name)" -ForegroundColor White
            $availableClientProjects += $project
            $index++
        }
    }
    
    # Display installed client projects
    if ($InstalledProjects.Count -gt 0) {
        Write-Host "`nAlready installed client projects:" -ForegroundColor DarkGray
        foreach ($installedProject in $InstalledProjects) {
            $projectName = ($clientProjects | Where-Object { $_.DirectoryName -eq $installedProject }).Name
            if ($projectName) {
                Write-Host "[x] $projectName" -ForegroundColor Red
            }
        }
    }
    
    # Add Cancel option
    Write-Host "$index. Cancel" -ForegroundColor Yellow
    
    # Get user selection
    $maxOption = $availableClientProjects.Count + 1
    $validOptions = 1..$maxOption | ForEach-Object { $_.ToString() }
    $clientSelection = Get-ValidatedInput -Prompt "Select a client project (1-$maxOption)" -ValidOptions $validOptions -MessagesJson $MessagesJson
    
    # Process selection
    if ([int]$clientSelection -eq $maxOption) {
        Write-Host "Client project selection cancelled." -ForegroundColor Yellow
    }
    else {
        $selectedProject = $availableClientProjects[[int]$clientSelection - 1]
        Install-ClientProject -ProjectType $selectedProject.Name -ProjectName $selectedProject.DirectoryName -ProjectRoot $ProjectRoot -MessagesJson $MessagesJson
        $InstalledProjects += $selectedProject.DirectoryName
    }
}

# Return the updated list of installed projects
return $InstalledProjects 