# ----------------------------------------
# ForgeMaster - Interactive Test Script
# ----------------------------------------
# This script tests the interactive experience of the ForgeMaster solution
# by simulating user input for various scenarios
# ----------------------------------------

param (
    [switch]$ShowDetails = $true,
    [string]$OutputMode = "Detailed"
)

# Store the starting directory
$startingDirectory = Get-Location

# Set the script directory (where this script is located)
$scriptDirectory = $PSScriptRoot

# Set the root directory (parent of the script directory)
$rootDirectory = Split-Path -Parent $scriptDirectory

# Create a temporary directory for testing
$tempDirName = "TestForgeMaster_Interactive_$([Guid]::NewGuid().ToString().Substring(0, 8))"
$tempDirPath = Join-Path -Path $scriptDirectory -ChildPath $tempDirName

# Function to write output based on mode
function Write-TestOutput {
    param (
        [string]$Message,
        [string]$ForegroundColor = "White",
        [switch]$NoNewLine = $false
    )
    
    if ($OutputMode -eq "Detailed" -or $ShowDetails) {
        Write-Host $Message -ForegroundColor $ForegroundColor -NoNewLine:$NoNewLine
    }
    elseif ($OutputMode -eq "Progress") {
        # For progress mode, we'll just output specific markers that the parent script can parse
        if ($Message -match "^Test Scenario (Passed|Failed): (.+)$") {
            Write-Output $Message
        }
    }
}

# Check if the temporary directory already exists and remove it
if (Test-Path -Path $tempDirPath) {
    Write-TestOutput "Removing existing temporary directory: $tempDirPath" -ForegroundColor Yellow
    Remove-Item -Path $tempDirPath -Recurse -Force
}

# Create the temporary directory
Write-TestOutput "Creating temporary directory for testing: $tempDirPath" -ForegroundColor Cyan
New-Item -Path $tempDirPath -ItemType Directory | Out-Null

# Change to the root directory
Set-Location -Path $rootDirectory

# Load messages.json for user messages
$messagesJsonPath = Join-Path -Path $rootDirectory -ChildPath "messages.json"
$messagesJson = Get-Content -Path $messagesJsonPath -Raw | ConvertFrom-Json

# Function to simulate user input
function Simulate-UserInput {
    param (
        [string[]]$Inputs
    )
    
    $script:inputQueue = $Inputs
    $script:inputIndex = 0
    
    # Mock the Read-Host cmdlet
    function global:Read-Host {
        param (
            [string]$Prompt
        )
        
        if ($script:inputIndex -lt $script:inputQueue.Count) {
            $input = $script:inputQueue[$script:inputIndex]
            $script:inputIndex++
            
            if ($ShowDetails) {
                Write-Host "$Prompt $input"
            }
            
            return $input
        }
        else {
            throw "No more simulated inputs available"
        }
    }
}

# Function to restore the original Read-Host
function Restore-ReadHost {
    if (Test-Path function:global:Read-Host) {
        Remove-Item function:global:Read-Host -Force
    }
}

# Define test scenarios
$testScenarios = @(
    @{
        Name = "Basic Project"
        ProjectName = "BasicProject"
        Inputs = @(
            # Project directory
            (Join-Path -Path $tempDirPath -ChildPath "BasicProject"),
            # Confirm directory creation
            "y",
            # Server projects
            "y",
            ".NET API",
            "done",
            # Client projects
            "y",
            "Vue/Nuxt",
            "done"
        )
    },
    @{
        Name = "Multiple Projects"
        ProjectName = "MultipleProjects"
        Inputs = @(
            # Project directory
            (Join-Path -Path $tempDirPath -ChildPath "MultipleProjects"),
            # Confirm directory creation
            "y",
            # Server projects
            "y",
            ".NET API",
            "FastAPI",
            "done",
            # Client projects
            "y",
            "Vue/Nuxt",
            "React/Next.js",
            "done"
        )
    },
    @{
        Name = "No Projects"
        ProjectName = "NoProjects"
        Inputs = @(
            # Project directory
            (Join-Path -Path $tempDirPath -ChildPath "NoProjects"),
            # Confirm directory creation
            "y",
            # Server projects
            "n",
            # Client projects
            "n"
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
    
    Write-TestOutput "`n========================================" -ForegroundColor Cyan
    Write-TestOutput "Running Test Scenario: $Name" -ForegroundColor Cyan
    Write-TestOutput "========================================" -ForegroundColor Cyan
    
    # Simulate user input
    Simulate-UserInput -Inputs $Inputs
    
    try {
        # Run the setup_master.ps1 script
        $setupMasterPath = Join-Path -Path $rootDirectory -ChildPath "setup_master.ps1"
        
        if ($ShowDetails) {
            & $setupMasterPath
        }
        else {
            & $setupMasterPath | Out-Null
        }
        
        # Verify the project structure
        $projectDir = Join-Path -Path $tempDirPath -ChildPath $ProjectName
        $success = $true
        $errors = @()
        
        # Check if the project directory exists
        if (-not (Test-Path -Path $projectDir)) {
            $success = $false
            $errors += "Project directory was not created: $projectDir"
        }
        
        # Output the result
        if ($success) {
            Write-TestOutput "Test Scenario Passed: $Name" -ForegroundColor Green
            return $true
        }
        else {
            Write-TestOutput "Test Scenario Failed: $Name" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-TestOutput "  - $error" -ForegroundColor Red
            }
            return $false
        }
    }
    finally {
        # Restore the original Read-Host
        Restore-ReadHost
    }
}

# Run the test scenarios
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
    
    # Add a small delay to make the progress visible in progress bar mode
    if ($OutputMode -eq "Progress") {
        Start-Sleep -Milliseconds 300
    }
}

# Output the results
Write-TestOutput "`n========================================" -ForegroundColor Cyan
Write-TestOutput "Test Results" -ForegroundColor Cyan
Write-TestOutput "========================================" -ForegroundColor Cyan
Write-TestOutput "Passed: $passedTests" -ForegroundColor Green
Write-TestOutput "Failed: $failedTests" -ForegroundColor ($failedTests -gt 0 ? "Red" : "Green")
Write-TestOutput "Total: $($passedTests + $failedTests)" -ForegroundColor Cyan

# Clean up
Write-TestOutput "`nCleaning up temporary directory..." -ForegroundColor Yellow
Remove-Item -Path $tempDirPath -Recurse -Force

# Return to the starting directory
Set-Location -Path $startingDirectory

# Exit with appropriate code
if ($failedTests -eq 0) {
    exit 0
}
else {
    exit 1
} 