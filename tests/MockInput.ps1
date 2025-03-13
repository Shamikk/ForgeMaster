# ----------------------------------------
# ForgeMaster - Mock Input Utility
# ----------------------------------------
# This script provides functions to mock user input for automated testing
# ----------------------------------------

# Global variable to store predefined inputs
$script:MockInputs = @()
$script:InputIndex = 0

# Function to set up mock inputs
function Set-MockInputs {
    param (
        [string[]]$Inputs
    )
    
    $script:MockInputs = $Inputs
    $script:InputIndex = 0
}

# Function to mock Read-Host
function Mock-ReadHost {
    param (
        [string]$Prompt
    )
    
    # Display the prompt (for debugging)
    Write-Host "$Prompt" -ForegroundColor Yellow
    
    # Get the next input from the predefined list
    if ($script:InputIndex -lt $script:MockInputs.Count) {
        $input = $script:MockInputs[$script:InputIndex]
        $script:InputIndex++
        
        # Display the simulated input (for debugging)
        Write-Host $input -ForegroundColor Magenta
        
        return $input
    }
    else {
        Write-Host "ERROR: No more mock inputs available!" -ForegroundColor Red
        return ""
    }
}

# Export the functions
Export-ModuleMember -Function Set-MockInputs, Mock-ReadHost 