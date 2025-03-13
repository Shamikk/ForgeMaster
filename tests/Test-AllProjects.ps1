# ----------------------------------------
# ForgeMaster - All Projects Test
# ----------------------------------------
# This script tests the project setup with all available server and client projects
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
$testName = "AllProjects"
$projectName = "AllProjects"
$serverProjects = @("dotnet-api", "fastapi", "django-rest", "expressjs")
$clientProjects = @("vue-nuxt", "vue-vite", "react-nextjs")

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
    "yes", # Add more projects?
    "yes", # Add server?
    "1", # Select FastAPI (now option 1)
    "yes", # Add client?
    "1", # Select Vue/Vite (now option 1)
    "yes", # Add more projects?
    "yes", # Add server?
    "1", # Select Django REST (now option 1)
    "yes", # Add client?
    "1", # Select React/Next.js (now option 1)
    "yes", # Add more projects?
    "yes", # Add server?
    "1", # Select Express.js (now option 1)
    "no", # Add client? (all clients installed)
    "no"                         # Add more projects?
)

try {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Running Test: All Projects" -ForegroundColor Green
    Write-Host "Project Name: $projectName" -ForegroundColor Green
    Write-Host "Server Projects: $($serverProjects -join ', ')" -ForegroundColor Green
    Write-Host "Client Projects: $($clientProjects -join ', ')" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Run the test with mocked input
    Invoke-MockedTest -ScriptPath "$rootDirectory\setup_master.ps1" -MockedInputs $mockedInputs
    
    # Verify the project structure
    $testResult = Test-ProjectStructure -ProjectRoot $projectRoot -ServerProjects $serverProjects -ClientProjects $clientProjects
    
    # Display test result
    if ($testResult) {
        Write-Host "`nTest Passed: All Projects" -ForegroundColor Green
        $exitCode = 0
    }
    else {
        Write-Host "`nTest Failed: All Projects" -ForegroundColor Red
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