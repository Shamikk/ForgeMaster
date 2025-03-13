# ----------------------------------------
# ForgeMaster - Run All Tests
# ----------------------------------------
# This script runs all individual test scripts for the ForgeMaster project setup tool
# ----------------------------------------

# Store the starting directory
$startingDirectory = Get-Location

# Set the script directory (where this script is located)
$scriptDirectory = $PSScriptRoot

# Display header
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ForgeMaster - Running All Tests" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Define all test scripts
$testScripts = @(
    "Test-NoProjects.ps1"
    # Uncomment the following lines after Test-NoProjects.ps1 is confirmed to work
    # "Test-BasicProject.ps1",
    # "Test-MultiServerProject.ps1",
    # "Test-MultiClientProject.ps1",
    # "Test-AllProjects.ps1"
)

# Initialize counters
$passedTests = 0
$failedTests = 0

# Run each test script
foreach ($testScript in $testScripts) {
    $testScriptPath = Join-Path -Path $scriptDirectory -ChildPath $testScript
    
    Write-Host "`nRunning test script: $testScript" -ForegroundColor Yellow
    
    # Run the test script
    $result = pwsh -NoProfile -ExecutionPolicy Bypass -File $testScriptPath
    
    # Check the exit code
    if ($LASTEXITCODE -eq 0) {
        $passedTests++
    }
    else {
        $failedTests++
    }
    
    # Display the test output
    $result | ForEach-Object { Write-Host $_ }
}

# Display test results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Tests: $($testScripts.Count)" -ForegroundColor White
Write-Host "Passed Tests: $passedTests" -ForegroundColor Green
Write-Host "Failed Tests: $failedTests" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

# Return to the starting directory
Set-Location -Path $startingDirectory

# Final message
if ($failedTests -eq 0) {
    Write-Host "All tests passed successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "Some tests failed. Please check the output for details." -ForegroundColor Red
    exit 1
} 