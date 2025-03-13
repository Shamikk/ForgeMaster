# ----------------------------------------
# ForgeMaster - Test Utilities
# ----------------------------------------
# This script provides utility functions for automated testing
# ----------------------------------------

# Function to mock Read-Host for automated testing
function Mock-ReadHost {
    param (
        [string]$ExpectedPrompt,
        [string]$ReturnValue
    )
    
    # Create a script block that will replace Read-Host
    $global:mockReadHostScript = {
        param([string]$Prompt)
        
        # Output the prompt and our simulated response
        Write-Host "$Prompt" -ForegroundColor Yellow
        Write-Host "[AUTOMATED] $ReturnValue" -ForegroundColor Magenta
        
        return $ReturnValue
    }
    
    # Replace the Read-Host function with our mock
    Set-Item -Path function:global:Read-Host -Value $global:mockReadHostScript -Force
}

# Function to restore the original Read-Host function
function Restore-ReadHost {
    # Remove our mock if it exists
    if ($global:mockReadHostScript) {
        Remove-Item -Path function:global:Read-Host -Force
        Remove-Variable -Name mockReadHostScript -Scope Global -Force
    }
}

# Function to verify project structure
function Test-ProjectStructure {
    param (
        [string]$ProjectRoot,
        [string[]]$ServerProjects = @(),
        [string[]]$ClientProjects = @()
    )
    
    # Check if project directory exists
    if (!(Test-Path -Path $ProjectRoot)) {
        Write-Host "ERROR: Project directory not created at $ProjectRoot!" -ForegroundColor Red
        return $false
    }
    
    # Check if basic directory structure exists
    $requiredDirs = @(
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
    
    foreach ($dir in $requiredDirs) {
        $dirPath = Join-Path -Path $ProjectRoot -ChildPath $dir
        if (!(Test-Path -Path $dirPath)) {
            Write-Host "ERROR: Required directory $dir not created!" -ForegroundColor Red
            return $false
        }
    }
    
    # Check if server projects were installed
    foreach ($serverProject in $ServerProjects) {
        $serverProjectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/$serverProject"
        if (!(Test-Path -Path $serverProjectPath)) {
            Write-Host "ERROR: Server project $serverProject not installed!" -ForegroundColor Red
            return $false
        }
    }
    
    # Check if client projects were installed
    foreach ($clientProject in $ClientProjects) {
        $clientProjectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/$clientProject"
        if (!(Test-Path -Path $clientProjectPath)) {
            Write-Host "ERROR: Client project $clientProject not installed!" -ForegroundColor Red
            return $false
        }
    }
    
    return $true
}

# Function to clean up test directories
function Remove-TestProject {
    param (
        [string]$ProjectRoot
    )
    
    if (Test-Path -Path $ProjectRoot) {
        Write-Host "Cleaning up test project directory..." -ForegroundColor Yellow
        Remove-Item -Path $ProjectRoot -Recurse -Force
    }
}

# Export functions
Export-ModuleMember -Function Mock-ReadHost, Restore-ReadHost, Test-ProjectStructure, Remove-TestProject 