# ----------------------------------------
# ForgeMaster - Basic Project Test
# ----------------------------------------
# This script tests the basic project setup with one server and one client
# ----------------------------------------

# Store the starting directory
$startingDirectory = Get-Location

# Set the script directory (where this script is located)
$scriptDirectory = $PSScriptRoot

# Set the root directory (parent of the script directory)
$rootDirectory = Split-Path -Parent $scriptDirectory

# Import the base test module
$baseTestPath = Join-Path -Path $scriptDirectory -ChildPath "Test-Base.ps1"
. $baseTestPath

# Test parameters
$testName = "BasicProject"
$projectName = "BasicProject"
$serverProject = "dotnet-api"
$clientProject = "vue-nuxt"

# Create a temporary directory for testing
$testDirectory = New-TestDirectory -TestName $testName
$projectRoot = Join-Path -Path $testDirectory -ChildPath $projectName

# Define the mocked inputs for the test
$mockedInputs = @(
    $projectName, # Project name
    $testDirectory, # Base path
    "yes", # Add server?
    "1", # Select .NET API
    "yes", # Add client?
    "1", # Select Vue/Nuxt
    "no"                         # Add more projects?
)

try {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test: Basic Project Setup" -ForegroundColor Green
    Write-Host "Project Name: $projectName" -ForegroundColor Green
    Write-Host "Server Project: $serverProject" -ForegroundColor Green
    Write-Host "Client Project: $clientProject" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Run the test with mocked input
    Invoke-MockedTest -ScriptPath "$rootDirectory\setup_master.ps1" -MockedInputs $mockedInputs
    
    # Verify the project structure
    $testResult = Test-ProjectStructure -ProjectRoot $projectRoot -ServerProjects @($serverProject) -ClientProjects @($clientProject)
    
    # Display test result
    if ($testResult) {
        Write-Host "`nTest Passed: Basic Project Setup" -ForegroundColor Green
        $exitCode = 0
    }
    else {
        Write-Host "`nTest Failed: Basic Project Setup" -ForegroundColor Red
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