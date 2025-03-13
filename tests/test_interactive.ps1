# ----------------------------------------
# ForgeMaster - Interactive Test Script
# ----------------------------------------
# This script tests the ForgeMaster project setup tool interactively by:
# 1. Creating a temporary directory for testing
# 2. Simulating user input to test the full interactive experience
# 3. Cleaning up the temporary directory after testing
# ----------------------------------------

# Store the starting directory
$startingDirectory = Get-Location

# Set the script directory (where this script is located)
$scriptDirectory = $PSScriptRoot

# Set the root directory (parent of the script directory)
$rootDirectory = Split-Path -Parent $scriptDirectory

# Create a temporary directory for testing
$tempDirectory = Join-Path -Path $scriptDirectory -ChildPath "tmp"
if (Test-Path -Path $tempDirectory) {
    Write-Host "Removing existing temporary directory..." -ForegroundColor Yellow
    Remove-Item -Path $tempDirectory -Recurse -Force
}

Write-Host "Creating temporary directory for testing..." -ForegroundColor Cyan
New-Item -Path $tempDirectory -ItemType Directory -Force | Out-Null

# Define test scenarios
$testScenarios = @(
    @{
        Name        = "Basic Project"
        ProjectName = "BasicProject"
        Inputs      = @(
            "BasicProject", # Project name
            "", # Base path (use default)
            "yes", # Add server?
            "1", # Select .NET API
            "yes", # Add client?
            "1", # Select Vue/Nuxt
            "no"             # Add more projects?
        )
    },
    @{
        Name        = "Multiple Projects"
        ProjectName = "MultiProject"
        Inputs      = @(
            "MultiProject", # Project name
            "", # Base path (use default)
            "yes", # Add server?
            "1", # Select .NET API
            "yes", # Add client?
            "1", # Select Vue/Nuxt
            "yes", # Add more projects?
            "yes", # Add server?
            "2", # Select FastAPI
            "yes", # Add client?
            "2", # Select Vue/Vite
            "no"             # Add more projects?
        )
    },
    @{
        Name        = "All Projects"
        ProjectName = "CompleteProject"
        Inputs      = @(
            "CompleteProject", # Project name
            "", # Base path (use default)
            "yes", # Add server?
            "1", # Select .NET API
            "yes", # Add client?
            "1", # Select Vue/Nuxt
            "yes", # Add more projects?
            "yes", # Add server?
            "1", # Select FastAPI (now option 1 since .NET API is installed)
            "yes", # Add client?
            "1", # Select Vue/Vite (now option 1 since Vue/Nuxt is installed)
            "yes", # Add more projects?
            "yes", # Add server?
            "1", # Select Django REST (now option 1)
            "yes", # Add client?
            "1", # Select React/Next.js (now option 1)
            "yes", # Add more projects?
            "yes", # Add server?
            "1", # Select Express.js (now option 1)
            "no", # Add client? (all clients installed)
            "no"                # Add more projects?
        )
    }
)

# Function to run a test scenario
function Run-TestScenario {
    param (
        [string]$Name,
        [string]$ProjectName,
        [string[]]$Inputs
    )
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test Scenario: $Name" -ForegroundColor Green
    Write-Host "Project Name: $ProjectName" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Set up the test environment
    $projectBasePath = Join-Path -Path $tempDirectory -ChildPath $ProjectName
    
    # Create a temporary script that will run the master script with simulated input
    $tempScriptPath = Join-Path -Path $tempDirectory -ChildPath "temp_$($ProjectName)_script.ps1"
    
    # Create the content for the temporary script
    $scriptContent = @"
# Temporary script to run the master script with simulated input
`$inputIndex = 0
`$inputs = @(
$($Inputs | ForEach-Object { "    `"$_`"" } | Out-String)
)

# Override Read-Host to use our predefined inputs
function Read-Host {
    param (
        [string]`$Prompt
    )
    
    Write-Host "`$Prompt" -ForegroundColor Yellow
    `$input = `$inputs[`$inputIndex]
    Write-Host `$input -ForegroundColor Magenta
    `$inputIndex++
    return `$input
}

# Run the master script
& "$rootDirectory\setup_master.ps1"
"@
    
    # Write the temporary script to disk
    Set-Content -Path $tempScriptPath -Value $scriptContent
    
    # Run the temporary script
    Write-Host "Running test scenario with simulated input..." -ForegroundColor Yellow
    pwsh -NoProfile -ExecutionPolicy Bypass -File $tempScriptPath
    
    # Verify the project structure
    Write-Host "Verifying project structure..." -ForegroundColor Yellow
    
    # Check if project directory exists
    $projectDirectory = Join-Path -Path "$env:USERPROFILE\source\repos" -ChildPath $ProjectName
    if (!(Test-Path -Path $projectDirectory)) {
        Write-Host "ERROR: Project directory not created at $projectDirectory!" -ForegroundColor Red
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
        $dirPath = Join-Path -Path $projectDirectory -ChildPath $dir
        if (!(Test-Path -Path $dirPath)) {
            Write-Host "ERROR: Required directory $dir not created!" -ForegroundColor Red
            return $false
        }
    }
    
    # Clean up the project directory
    Write-Host "Cleaning up project directory..." -ForegroundColor Yellow
    Remove-Item -Path $projectDirectory -Recurse -Force
    
    Write-Host "Test Scenario Passed: $Name" -ForegroundColor Green
    return $true
}

# Run test scenarios
$passedTests = 0
$failedTests = 0

foreach ($scenario in $testScenarios) {
    $result = Run-TestScenario -Name $scenario.Name -ProjectName $scenario.ProjectName -Inputs $scenario.Inputs
    
    if ($result) {
        $passedTests++
    }
    else {
        $failedTests++
    }
}

# Display test results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Scenarios: $($testScenarios.Count)" -ForegroundColor White
Write-Host "Passed Scenarios: $passedTests" -ForegroundColor Green
Write-Host "Failed Scenarios: $failedTests" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

# Clean up
Write-Host "Cleaning up temporary directory..." -ForegroundColor Yellow
Remove-Item -Path $tempDirectory -Recurse -Force

# Return to the starting directory
Set-Location -Path $startingDirectory

# Final message
if ($failedTests -eq 0) {
    Write-Host "All test scenarios passed successfully!" -ForegroundColor Green
}
else {
    Write-Host "Some test scenarios failed. Please check the output for details." -ForegroundColor Red
} 