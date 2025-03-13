# ----------------------------------------
# ForgeMaster - Test Script
# ----------------------------------------
# This script tests the ForgeMaster project setup tool by:
# 1. Creating a temporary directory for testing
# 2. Testing all possible combinations of server and client installations
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

# Load messages.json
$messagesJsonPath = Join-Path -Path $rootDirectory -ChildPath "messages.json"
$messagesJson = Get-Content -Path $messagesJsonPath -Raw | ConvertFrom-Json

# Function to simulate user input
function Simulate-UserInput {
    param (
        [string]$Input
    )
    
    # This function will be used to simulate user input in a real testing framework
    # For now, we'll just output what would be input
    Write-Host "Simulated Input: $Input" -ForegroundColor Magenta
    return $Input
}

# Function to run a test case
function Run-TestCase {
    param (
        [string]$TestName,
        [string]$ProjectName,
        [string[]]$ServerProjects,
        [string[]]$ClientProjects
    )
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test Case: $TestName" -ForegroundColor Green
    Write-Host "Project Name: $ProjectName" -ForegroundColor Green
    Write-Host "Server Projects: $($ServerProjects -join ', ')" -ForegroundColor Green
    Write-Host "Client Projects: $($ClientProjects -join ', ')" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Create project directory
    $projectDirectory = Join-Path -Path $tempDirectory -ChildPath $ProjectName
    
    # Run setup_project_directories.ps1
    Write-Host "Setting up project directories..." -ForegroundColor Yellow
    & "$rootDirectory\setup_project_directories.ps1" -ProjectRoot $projectDirectory -MessagesJson $messagesJson
    
    # Initialize arrays to track installed projects
    $installedServerProjects = @()
    $installedClientProjects = @()
    
    # Install server projects
    foreach ($serverProject in $ServerProjects) {
        Write-Host "Installing server project: $serverProject" -ForegroundColor Yellow
        $installedServerProjects = & "$rootDirectory\setup_server_project.ps1" -ProjectRoot $projectDirectory -MessagesJson $messagesJson -InstalledProjects $installedServerProjects
    }
    
    # Install client projects
    foreach ($clientProject in $ClientProjects) {
        Write-Host "Installing client project: $clientProject" -ForegroundColor Yellow
        $installedClientProjects = & "$rootDirectory\setup_client_project.ps1" -ProjectRoot $projectDirectory -MessagesJson $messagesJson -InstalledProjects $installedClientProjects
    }
    
    # Verify project structure
    Write-Host "Verifying project structure..." -ForegroundColor Yellow
    
    # Check if project directory exists
    if (!(Test-Path -Path $projectDirectory)) {
        Write-Host "ERROR: Project directory not created!" -ForegroundColor Red
        return $false
    }
    
    # Check if server projects were installed
    foreach ($serverProject in $ServerProjects) {
        $serverProjectPath = Join-Path -Path $projectDirectory -ChildPath "apps/servers/$serverProject"
        if (!(Test-Path -Path $serverProjectPath)) {
            Write-Host "ERROR: Server project $serverProject not installed!" -ForegroundColor Red
            return $false
        }
    }
    
    # Check if client projects were installed
    foreach ($clientProject in $ClientProjects) {
        $clientProjectPath = Join-Path -Path $projectDirectory -ChildPath "apps/clients/$clientProject"
        if (!(Test-Path -Path $clientProjectPath)) {
            Write-Host "ERROR: Client project $clientProject not installed!" -ForegroundColor Red
            return $false
        }
    }
    
    Write-Host "Test Case Passed: $TestName" -ForegroundColor Green
    return $true
}

# Define test cases
$testCases = @(
    @{
        TestName       = "No Projects"
        ProjectName    = "EmptyProject"
        ServerProjects = @()
        ClientProjects = @()
    },
    @{
        TestName       = "Single Server Project"
        ProjectName    = "ServerOnlyProject"
        ServerProjects = @("dotnet-api")
        ClientProjects = @()
    },
    @{
        TestName       = "Single Client Project"
        ProjectName    = "ClientOnlyProject"
        ServerProjects = @()
        ClientProjects = @("vue-nuxt")
    },
    @{
        TestName       = "One Server, One Client"
        ProjectName    = "BasicProject"
        ServerProjects = @("fastapi")
        ClientProjects = @("react-nextjs")
    },
    @{
        TestName       = "Multiple Server Projects"
        ProjectName    = "MultiServerProject"
        ServerProjects = @("dotnet-api", "django-rest")
        ClientProjects = @()
    },
    @{
        TestName       = "Multiple Client Projects"
        ProjectName    = "MultiClientProject"
        ServerProjects = @()
        ClientProjects = @("vue-nuxt", "vue-vite")
    },
    @{
        TestName       = "All Server Projects"
        ProjectName    = "AllServersProject"
        ServerProjects = @("dotnet-api", "fastapi", "django-rest", "expressjs")
        ClientProjects = @()
    },
    @{
        TestName       = "All Client Projects"
        ProjectName    = "AllClientsProject"
        ServerProjects = @()
        ClientProjects = @("vue-nuxt", "vue-vite", "react-nextjs")
    },
    @{
        TestName       = "All Projects"
        ProjectName    = "CompleteProject"
        ServerProjects = @("dotnet-api", "fastapi", "django-rest", "expressjs")
        ClientProjects = @("vue-nuxt", "vue-vite", "react-nextjs")
    }
)

# Run test cases
$passedTests = 0
$failedTests = 0

foreach ($testCase in $testCases) {
    $result = Run-TestCase -TestName $testCase.TestName -ProjectName $testCase.ProjectName -ServerProjects $testCase.ServerProjects -ClientProjects $testCase.ClientProjects
    
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
Write-Host "Total Tests: $($testCases.Count)" -ForegroundColor White
Write-Host "Passed Tests: $passedTests" -ForegroundColor Green
Write-Host "Failed Tests: $failedTests" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

# Clean up
Write-Host "Cleaning up temporary directory..." -ForegroundColor Yellow
Remove-Item -Path $tempDirectory -Recurse -Force

# Return to the starting directory
Set-Location -Path $startingDirectory

# Final message
if ($failedTests -eq 0) {
    Write-Host "All tests passed successfully!" -ForegroundColor Green
}
else {
    Write-Host "Some tests failed. Please check the output for details." -ForegroundColor Red
} 