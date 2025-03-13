# ----------------------------------------
# ForgeMaster - Single Server Project Test
# ----------------------------------------
# This script tests creating a project with a single server application
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

# Import test utilities
$utilsPath = Join-Path -Path $scriptDirectory -ChildPath "test_utils.ps1"
Import-Module -Name $utilsPath -Force

# Test parameters
$projectName = "SingleServerProject"
$projectRoot = Join-Path -Path $tempDirectory -ChildPath $projectName
$serverProject = "dotnet-api"

try {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test: Single Server Project" -ForegroundColor Green
    Write-Host "Project Name: $projectName" -ForegroundColor Green
    Write-Host "Server Project: $serverProject" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Set up the automated responses for Read-Host
    # 1. Project name
    Mock-ReadHost -ExpectedPrompt "Enter the project name" -ReturnValue $projectName
    
    # 2. Base path (use temp directory)
    Mock-ReadHost -ExpectedPrompt "Enter the base path or press Enter to use" -ReturnValue $tempDirectory
    
    # 3. Add server? (yes)
    Mock-ReadHost -ExpectedPrompt "*server*" -ReturnValue "yes"
    
    # 4. Select server project (1 for .NET API)
    Mock-ReadHost -ExpectedPrompt "Select a server project" -ReturnValue "1"
    
    # 5. Add client? (no)
    Mock-ReadHost -ExpectedPrompt "*client*" -ReturnValue "no"
    
    # 6. Continue? (no)
    Mock-ReadHost -ExpectedPrompt "*continue*" -ReturnValue "no"
    
    # Run the master script
    & "$rootDirectory\setup_master.ps1"
    
    # Verify project structure
    $testResult = Test-ProjectStructure -ProjectRoot $projectRoot -ServerProjects @($serverProject)
    
    if ($testResult) {
        Write-Host "Test Passed: Single Server Project" -ForegroundColor Green
    }
    else {
        Write-Host "Test Failed: Single Server Project" -ForegroundColor Red
    }
}
catch {
    Write-Host "Test Failed with error: $_" -ForegroundColor Red
    $testResult = $false
}
finally {
    # Restore original Read-Host function
    Restore-ReadHost
    
    # Clean up
    Remove-TestProject -ProjectRoot $projectRoot
    
    # Return to the starting directory
    Set-Location -Path $startingDirectory
}

# Return test result for use in run_all_tests.ps1
return $testResult 