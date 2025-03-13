# ----------------------------------------
# ForgeMaster - Base Test Script
# ----------------------------------------
# This script provides common functions for all test cases
# ----------------------------------------

# Function to verify project structure
function Test-ProjectStructure {
    param (
        [string]$ProjectRoot,
        [string[]]$ServerProjects = @(),
        [string[]]$ClientProjects = @()
    )
    
    Write-Host "Verifying project structure..." -ForegroundColor Yellow
    $testsPassed = $true
    
    # Check if project directory exists
    if (!(Test-Path -Path $ProjectRoot)) {
        Write-Host "ERROR: Project directory not created at $ProjectRoot!" -ForegroundColor Red
        return $false
    }
    
    # Check if basic directory structure exists
    $requiredDirs = @(
        "apps/servers",
        "apps/clients",
        "workspace/designs",
        "workspace/reports",
        "workspace/ideas",
        "workspace/research",
        "infra/docker",
        "infra/scripts",
        "infra/configs",
        "libs/shared",
        "libs/ai",
        "tests/integration",
        "tests/unit",
        "docs"
    )
    
    foreach ($dir in $requiredDirs) {
        $dirPath = Join-Path -Path $ProjectRoot -ChildPath $dir
        if (!(Test-Path -Path $dirPath)) {
            Write-Host "ERROR: Required directory $dir not created!" -ForegroundColor Red
            $testsPassed = $false
        }
    }
    
    # Check if server projects were installed
    foreach ($serverProject in $ServerProjects) {
        $serverProjectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/$serverProject"
        if (!(Test-Path -Path $serverProjectPath)) {
            Write-Host "ERROR: Server project $serverProject not installed!" -ForegroundColor Red
            $testsPassed = $false
        }
    }
    
    # Check if client projects were installed
    foreach ($clientProject in $ClientProjects) {
        $clientProjectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/$clientProject"
        if (!(Test-Path -Path $clientProjectPath)) {
            Write-Host "ERROR: Client project $clientProject not installed!" -ForegroundColor Red
            $testsPassed = $false
        }
    }
    
    return $testsPassed
}

# Function to create a temporary directory for testing
function New-TestDirectory {
    param (
        [string]$TestName
    )
    
    $tempDirectory = Join-Path -Path $PSScriptRoot -ChildPath "tmp"
    $testDirectory = Join-Path -Path $tempDirectory -ChildPath $TestName
    
    # Create the temp directory if it doesn't exist
    if (!(Test-Path -Path $tempDirectory)) {
        New-Item -Path $tempDirectory -ItemType Directory -Force | Out-Null
    }
    
    # Remove the test directory if it exists
    if (Test-Path -Path $testDirectory) {
        Remove-Item -Path $testDirectory -Recurse -Force
    }
    
    # Create the test directory
    New-Item -Path $testDirectory -ItemType Directory -Force | Out-Null
    
    return $testDirectory
}

# Function to clean up test directory
function Remove-TestDirectory {
    param (
        [string]$TestDirectory
    )
    
    if (Test-Path -Path $TestDirectory) {
        Remove-Item -Path $TestDirectory -Recurse -Force
    }
}

# Function to run a test with mocked input
function Invoke-MockedTest {
    param (
        [string]$ScriptPath,
        [string[]]$MockedInputs,
        [hashtable]$Parameters = @{}
    )
    
    # Create a temporary script that will run the target script with mocked input
    $tempScriptPath = Join-Path -Path $env:TEMP -ChildPath "temp_mocked_script_$([Guid]::NewGuid().ToString()).ps1"
    
    # Create the content for the temporary script
    $scriptContent = @"
# Temporary script to run with mocked input
`$inputIndex = 0
`$inputs = @(
$($MockedInputs | ForEach-Object { "    `"$_`"" } | Out-String)
)

# Override Read-Host to use our predefined inputs
function Read-Host {
    param (
        [string]`$Prompt
    )
    
    Write-Host "`$Prompt" -ForegroundColor Yellow
    `$input = `$inputs[`$inputIndex]
    Write-Host `$input -ForegroundColor Magenta
    `$inputIndex++
    return `$input
}

# Run the target script with parameters
`$params = @{
$($Parameters.GetEnumerator() | ForEach-Object { "    $($_.Key) = `"$($_.Value)`"" } | Out-String)
}

& "$ScriptPath" @params
"@
    
    # Write the temporary script to disk
    Set-Content -Path $tempScriptPath -Value $scriptContent
    
    # Run the temporary script
    $result = pwsh -NoProfile -ExecutionPolicy Bypass -File $tempScriptPath
    
    # Clean up
    Remove-Item -Path $tempScriptPath -Force
    
    return $result
}

# Export functions
Export-ModuleMember -Function Test-ProjectStructure, New-TestDirectory, Remove-TestDirectory, Invoke-MockedTest 