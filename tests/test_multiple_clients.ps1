# ----------------------------------------
# ForgeMaster - Multiple Client Projects Test
# ----------------------------------------
# This script tests creating a project with multiple client applications
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
$projectName = "MultiClientProject"
$projectRoot = Join-Path -Path $tempDirectory -ChildPath $projectName
$clientProjects = @("vue-nuxt", "vue-vite")

try {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test: Multiple Client Projects" -ForegroundColor Green
    Write-Host "Project Name: $projectName" -ForegroundColor Green
    Write-Host "Client Projects: $($clientProjects -join ', ')" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Set up the automated responses for Read-Host
    # 1. Project name
    Mock-ReadHost -ExpectedPrompt "Enter the project name" -ReturnValue $projectName
    
    # 2. Base path (use temp directory)
    Mock-ReadHost -ExpectedPrompt "Enter the base path or press Enter to use" -ReturnValue $tempDirectory
    
    # First iteration
    # 3. Add server? (no)
    Mock-ReadHost -ExpectedPrompt "*server*" -ReturnValue "no"
    
    # 4. Add client? (yes)
    Mock-ReadHost -ExpectedPrompt "*client*" -ReturnValue "yes"
    
    # 5. Select client project (1 for Vue/Nuxt)
    Mock-ReadHost -ExpectedPrompt "Select a client project" -ReturnValue "1"
    
    # 6. Continue? (yes)
    Mock-ReadHost -ExpectedPrompt "*continue*" -ReturnValue "yes"
    
    # Second iteration
    # 7. Add server? (no)
    Mock-ReadHost -ExpectedPrompt "*server*" -ReturnValue "no"
    
    # 8. Add client? (yes)
    Mock-ReadHost -ExpectedPrompt "*client*" -ReturnValue "yes"
    
    # 9. Select client project (2 for Vue/Vite - option 1 is now taken)
    Mock-ReadHost -ExpectedPrompt "Select a client project" -ReturnValue "2"
    
    # 10. Continue? (no)
    Mock-ReadHost -ExpectedPrompt "*continue*" -ReturnValue "no"
    
    # Run the master script
    & "$rootDirectory\setup_master.ps1"
    
    # Verify project structure
    $testResult = Test-ProjectStructure -ProjectRoot $projectRoot -ClientProjects $clientProjects
    
    if ($testResult) {
        Write-Host "Test Passed: Multiple Client Projects" -ForegroundColor Green
    }
    else {
        Write-Host "Test Failed: Multiple Client Projects" -ForegroundColor Red
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