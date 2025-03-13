# ----------------------------------------
# ForgeMaster - No Projects Test
# ----------------------------------------
# This script tests the project setup with no server or client projects
# ----------------------------------------

# Store the starting directory
$startingDirectory = Get-Location

# Set the script directory (where this script is located)
$scriptDirectory = $PSScriptRoot

# Set the root directory (parent of the script directory)
$rootDirectory = Split-Path -Parent $scriptDirectory

# Import the base test module and helper
$baseTestPath = Join-Path -Path $scriptDirectory -ChildPath "Test-Base.ps1"
. $baseTestPath

$helperPath = Join-Path -Path $scriptDirectory -ChildPath "AutoTest-Helper.ps1"
. $helperPath

# Test parameters
$testName = "NoProjects"
$projectName = "EmptyProject"
$serverProjects = @()
$clientProjects = @()

# Create a temporary directory for testing
$testDirectory = New-TestDirectory -TestName $testName
$projectRoot = Join-Path -Path $testDirectory -ChildPath $projectName

# Define the automated inputs for the test
$automatedInputs = @(
    $projectName, # Project name
    $testDirectory, # Base path
    "no", # Add server?
    "no", # Add client?
    "no"                         # Add more projects?
)

try {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test: No Projects" -ForegroundColor Green
    Write-Host "Project Name: $projectName" -ForegroundColor Green
    Write-Host "Server Projects: None" -ForegroundColor Green
    Write-Host "Client Projects: None" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Run the test with automated input
    $masterScriptPath = Join-Path -Path $rootDirectory -ChildPath "setup_master.ps1"
    Invoke-AutomatedTest -ScriptPath $masterScriptPath -Inputs $automatedInputs
    
    # Verify the project structure
    $testResult = Test-ProjectStructure -ProjectRoot $projectRoot -ServerProjects $serverProjects -ClientProjects $clientProjects
    
    # Display test result
    if ($testResult) {
        Write-Host "`nTest Passed: No Projects" -ForegroundColor Green
        $exitCode = 0
    }
    else {
        Write-Host "`nTest Failed: No Projects" -ForegroundColor Red
        $exitCode = 1
    }
}
catch {
    Write-Host "Error during test execution: $_" -ForegroundColor Red
    $exitCode = 1
}
finally {
    # Clean up
    Remove-TestDirectory -TestDirectory $testDirectory
    
    # Return to the starting directory
    Set-Location -Path $startingDirectory
}

exit $exitCode 