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
    "test_empty_project.ps1",
    "test_single_server.ps1",
    "test_single_client.ps1",
    "test_server_client.ps1",
    "test_multiple_servers.ps1",
    "test_multiple_clients.ps1",
    "test_all_projects.ps1"
)

# Initialize counters
$passedTests = 0
$failedTests = 0

# Run each test script
foreach ($testScript in $testScripts) {
    $testScriptPath = Join-Path -Path $scriptDirectory -ChildPath $testScript
    
    Write-Host "`nRunning test script: $testScript" -ForegroundColor Yellow
    
    # Run the test script and capture the result
    $testResult = & $testScriptPath
    
    # Update counters
    if ($testResult -eq $true) {
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
Write-Host "Total Tests: $($testScripts.Count)" -ForegroundColor White
Write-Host "Passed Tests: $passedTests" -ForegroundColor Green
Write-Host "Failed Tests: $failedTests" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

# Return to the starting directory
Set-Location -Path $startingDirectory

# Final message
if ($failedTests -eq 0) {
    Write-Host "All tests passed successfully!" -ForegroundColor Green
}
else {
    Write-Host "Some tests failed. Please check the output for details." -ForegroundColor Red
} 