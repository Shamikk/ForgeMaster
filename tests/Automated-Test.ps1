# ----------------------------------------
# ForgeMaster - Automated Test Script
# ----------------------------------------
# This script tests all scenarios of the ForgeMaster solution
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
$tempDirName = "TestForgeMaster_$([Guid]::NewGuid().ToString().Substring(0, 8))"
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
        if ($Message -match "^Test Case (Passed|Failed): (.+)$") {
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

# Function to run a test case
function Run-TestCase {
    param (
        [string]$TestName,
        [string]$ProjectName,
        [string[]]$ServerProjects,
        [string[]]$ClientProjects
    )
    
    Write-TestOutput "`n========================================" -ForegroundColor Cyan
    Write-TestOutput "Running Test Case: $TestName" -ForegroundColor Cyan
    Write-TestOutput "========================================" -ForegroundColor Cyan
    
    # Create a project directory for this test
    $projectDir = Join-Path -Path $tempDirPath -ChildPath $ProjectName
    New-Item -Path $projectDir -ItemType Directory | Out-Null
    
    # Prepare inputs for setup_project_directories.ps1
    $inputs = @(
        $projectDir,  # Project directory
        "y"           # Confirm directory creation
    )
    
    # Add server project selections
    if ($ServerProjects.Count -gt 0) {
        $inputs += "y"  # Yes to server projects
        
        # Add each server project
        foreach ($project in $ServerProjects) {
            $inputs += $project
        }
        
        $inputs += "done"  # Done selecting server projects
    }
    else {
        $inputs += "n"  # No to server projects
    }
    
    # Add client project selections
    if ($ClientProjects.Count -gt 0) {
        $inputs += "y"  # Yes to client projects
        
        # Add each client project
        foreach ($project in $ClientProjects) {
            $inputs += $project
        }
        
        $inputs += "done"  # Done selecting client projects
    }
    else {
        $inputs += "n"  # No to client projects
    }
    
    # Simulate user input
    Simulate-UserInput -Inputs $inputs
    
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
        $success = $true
        $errors = @()
        
        # Check if the project directory exists
        if (-not (Test-Path -Path $projectDir)) {
            $success = $false
            $errors += "Project directory was not created: $projectDir"
        }
        
        # Check if the src directory exists
        $srcDir = Join-Path -Path $projectDir -ChildPath "src"
        if (-not (Test-Path -Path $srcDir)) {
            $success = $false
            $errors += "src directory was not created: $srcDir"
        }
        
        # Check if server projects were installed
        if ($ServerProjects.Count -gt 0) {
            $serverDir = Join-Path -Path $srcDir -ChildPath "server"
            if (-not (Test-Path -Path $serverDir)) {
                $success = $false
                $errors += "server directory was not created: $serverDir"
            }
            else {
                foreach ($project in $ServerProjects) {
                    $projectDir = Join-Path -Path $serverDir -ChildPath $project
                    if (-not (Test-Path -Path $projectDir)) {
                        $success = $false
                        $errors += "Server project was not installed: $project"
                    }
                }
            }
        }
        
        # Check if client projects were installed
        if ($ClientProjects.Count -gt 0) {
            $clientDir = Join-Path -Path $srcDir -ChildPath "client"
            if (-not (Test-Path -Path $clientDir)) {
                $success = $false
                $errors += "client directory was not created: $clientDir"
            }
            else {
                foreach ($project in $ClientProjects) {
                    $projectDir = Join-Path -Path $clientDir -ChildPath $project
                    if (-not (Test-Path -Path $projectDir)) {
                        $success = $false
                        $errors += "Client project was not installed: $project"
                    }
                }
            }
        }
        
        # Output the result
        if ($success) {
            Write-TestOutput "Test Case Passed: $TestName" -ForegroundColor Green
            return $true
        }
        else {
            Write-TestOutput "Test Case Failed: $TestName" -ForegroundColor Red
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

# Define test cases
$testCases = @(
    @{
        TestName = "No Projects"
        ProjectName = "NoProjects"
        ServerProjects = @()
        ClientProjects = @()
    },
    @{
        TestName = "Single Server Project - .NET API"
        ProjectName = "SingleServerDotNet"
        ServerProjects = @(".NET API")
        ClientProjects = @()
    },
    @{
        TestName = "Single Server Project - FastAPI"
        ProjectName = "SingleServerFastAPI"
        ServerProjects = @("FastAPI")
        ClientProjects = @()
    },
    @{
        TestName = "Single Client Project - Vue/Nuxt"
        ProjectName = "SingleClientVueNuxt"
        ServerProjects = @()
        ClientProjects = @("Vue/Nuxt")
    },
    @{
        TestName = "Single Client Project - React/Next.js"
        ProjectName = "SingleClientReactNext"
        ServerProjects = @()
        ClientProjects = @("React/Next.js")
    },
    @{
        TestName = "One Server, One Client"
        ProjectName = "OneServerOneClient"
        ServerProjects = @(".NET API")
        ClientProjects = @("Vue/Nuxt")
    },
    @{
        TestName = "Multiple Server Projects"
        ProjectName = "MultipleServers"
        ServerProjects = @(".NET API", "FastAPI")
        ClientProjects = @()
    },
    @{
        TestName = "Multiple Client Projects"
        ProjectName = "MultipleClients"
        ServerProjects = @()
        ClientProjects = @("Vue/Nuxt", "React/Next.js")
    },
    @{
        TestName = "Multiple Server and Client Projects"
        ProjectName = "MultipleServerClient"
        ServerProjects = @(".NET API", "FastAPI")
        ClientProjects = @("Vue/Nuxt", "React/Next.js")
    }
)

# Run the test cases
$passedTests = 0
$failedTests = 0

foreach ($testCase in $testCases) {
    $result = Run-TestCase @testCase
    
    if ($result) {
        $passedTests++
    }
    else {
        $failedTests++
    }
    
    # Add a small delay to make the progress visible in progress bar mode
    if ($OutputMode -eq "Progress") {
        Start-Sleep -Milliseconds 100
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