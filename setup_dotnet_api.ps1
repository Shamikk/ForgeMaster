$ProjectRoot = Read-Host "Enter the full path of your project root (e.g., C:\Users\YourUser\source\repos\SurveyAIApp)"

if (!(Test-Path -Path $ProjectRoot)) {
    Write-Host "Error: The specified project directory does not exist!" -ForegroundColor Red
    exit
}

$DotnetApiPath = Join-Path -Path $ProjectRoot -ChildPath "apps\servers\dotnet-api"

if (!(Test-Path -Path $DotnetApiPath)) {
    New-Item -ItemType Directory -Path $DotnetApiPath -Force | Out-Null
}

Set-Location -Path $DotnetApiPath

Write-Host "Creating .NET Core API project in $DotnetApiPath..." -ForegroundColor Cyan
dotnet new webapi --force

# List of files that may not exist (to avoid red errors)
$FilesToRemove = @(
    "$DotnetApiPath\WeatherForecast.cs",
    "$DotnetApiPath\Controllers\WeatherForecastController.cs"
)

foreach ($file in $FilesToRemove) {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file -Force
        Write-Host "Removed $file" -ForegroundColor Green
    } else {
        Write-Host "File $file not found - skipping" -ForegroundColor Blue
    }
}

Write-Host "Initializing Git repository..." -ForegroundColor Cyan
git init
git add .
git commit -m "Initial commit - .NET Core API setup"

Write-Host "Running the .NET Core API project..." -ForegroundColor Green
dotnet run
