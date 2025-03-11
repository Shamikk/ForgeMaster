# Load themed messages from JSON
$MessagesFile = "$PSScriptRoot\messages.json"

if (!(Test-Path -Path $MessagesFile)) {
    Write-Host "Error: Missing messages.json file!" -ForegroundColor Red
    exit
}

$Messages = Get-Content -Path $MessagesFile | ConvertFrom-Json
$SelectedTheme = $Messages.themes | Get-Random

Write-Host $SelectedTheme.start -ForegroundColor Cyan

# Ask user where the scripts are located
$ScriptPath = Read-Host "Enter the full path where your setup scripts are saved (e.g., C:\Users\YourUser\Scripts)"

if (!(Test-Path -Path $ScriptPath)) {
    Write-Host "Error: The specified script directory does not exist!" -ForegroundColor Red
    exit
}

Write-Host $SelectedTheme.dir_creation -ForegroundColor Yellow
& "$ScriptPath\setup_project_directories.ps1"

$ProjectRoot = Read-Host "Enter the full path of the created project root (e.g., C:\Users\YourUser\source\repos\SurveyAIApp)"

if (!(Test-Path -Path $ProjectRoot)) {
    Write-Host "Error: The specified project directory does not exist!" -ForegroundColor Red
    exit
}

Write-Host $SelectedTheme.project_setup -ForegroundColor Cyan
& "$ScriptPath\setup_dotnet_api.ps1"

Write-Host $SelectedTheme.done -ForegroundColor Green
