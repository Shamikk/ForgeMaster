# ----------------------------------------
# ForgeMaster - Automated Test Helper
# ----------------------------------------
# This script provides functions to automate testing by temporarily modifying
# the original scripts to use predefined inputs
# ----------------------------------------

# Function to create a backup of a file
function Backup-File {
    param (
        [string]$FilePath
    )
    
    $backupPath = "$FilePath.bak"
    Copy-Item -Path $FilePath -Destination $backupPath -Force
    return $backupPath
}

# Function to restore a file from backup
function Restore-File {
    param (
        [string]$FilePath
    )
    
    $backupPath = "$FilePath.bak"
    if (Test-Path -Path $backupPath) {
        Copy-Item -Path $backupPath -Destination $FilePath -Force
        Remove-Item -Path $backupPath -Force
    }
}

# Function to modify a script to use automated inputs
function Set-AutomatedInputs {
    param (
        [string]$ScriptPath,
        [string[]]$Inputs
    )
    
    # Backup the original script
    $backupPath = Backup-File -FilePath $ScriptPath
    
    # Read the original script content
    $originalContent = Get-Content -Path $backupPath -Raw
    
    # Create the automated input code
    $automatedInputCode = @"
# ----------------------------------------
# AUTOMATED TEST MODE - DO NOT MODIFY
# ----------------------------------------
# This section is automatically added for testing purposes
# It will be removed after testing is complete
# ----------------------------------------

# Define automated inputs
`$script:AutomatedInputs = @(
$($Inputs | ForEach-Object { "    `"$_`"" } | Out-String)
)
`$script:InputIndex = 0

# Override Read-Host function
function Read-Host {
    param (
        [string]`$Prompt
    )
    
    # Display the prompt
    Write-Host "`$Prompt" -ForegroundColor Yellow
    
    # Get the next input from the predefined list
    if (`$script:InputIndex -lt `$script:AutomatedInputs.Count) {
        `$input = `$script:AutomatedInputs[`$script:InputIndex]
        `$script:InputIndex++
        
        # Display the simulated input
        Write-Host `$input -ForegroundColor Magenta
        
        return `$input
    }
    else {
        Write-Host "ERROR: No more automated inputs available!" -ForegroundColor Red
        return ""
    }
}

# ----------------------------------------
# END OF AUTOMATED TEST MODE
# ----------------------------------------

"@
    
    # Combine the automated input code with the original script
    $modifiedContent = $automatedInputCode + $originalContent
    
    # Write the modified content back to the script
    Set-Content -Path $ScriptPath -Value $modifiedContent
}

# Function to run an automated test
function Invoke-AutomatedTest {
    param (
        [string]$ScriptPath,
        [string[]]$Inputs,
        [hashtable]$Parameters = @{}
    )
    
    try {
        # Modify the script to use automated inputs
        Set-AutomatedInputs -ScriptPath $ScriptPath -Inputs $Inputs
        
        # Build the parameter string
        $paramString = ""
        foreach ($key in $Parameters.Keys) {
            $value = $Parameters[$key]
            $paramString += " -$key `"$value`""
        }
        
        # Run the modified script
        $command = "pwsh -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"$paramString"
        $result = Invoke-Expression $command
        
        return $result
    }
    finally {
        # Restore the original script
        Restore-File -FilePath $ScriptPath
    }
}

# Export functions
Export-ModuleMember -Function Backup-File, Restore-File, Set-AutomatedInputs, Invoke-AutomatedTest 