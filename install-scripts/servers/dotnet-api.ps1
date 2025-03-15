# ----------------------------------------
# ForgeMaster - .NET API Server Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new .NET API project
# 2. Sets up basic project structure
# 3. Adds common dependencies
# ----------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Ensure the target directory exists
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/dotnet-api"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create a new .NET Web API project
    Write-Host "Creating new .NET Web API project..." -ForegroundColor Cyan
    dotnet new webapi -n $ProjectName
    
    # Move into the project directory
    Set-Location $ProjectName
    
    # Add common NuGet packages
    Write-Host "Adding common dependencies..." -ForegroundColor Cyan
    dotnet add package Microsoft.EntityFrameworkCore
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer
    dotnet add package Microsoft.EntityFrameworkCore.Design
    dotnet add package AutoMapper
    dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
    dotnet add package Swashbuckle.AspNetCore
    
    # Create standard project structure
    Write-Host "Setting up project structure..." -ForegroundColor Cyan
    $directories = @(
        "Controllers",
        "Models",
        "Data",
        "Services",
        "DTOs",
        "Middleware",
        "Extensions"
    )
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory | Out-Null
        }
    }
    
    # Create a sample entity model
    $sampleModelContent = @"
namespace $ProjectName.Models
{
    public class SampleEntity
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
"@
    Set-Content -Path "Models\SampleEntity.cs" -Value $sampleModelContent
    
    # Create a sample controller
    $sampleControllerContent = @"
using Microsoft.AspNetCore.Mvc;
using $ProjectName.Models;

namespace $ProjectName.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SampleController : ControllerBase
    {
        private static readonly List<SampleEntity> _samples = new List<SampleEntity>
        {
            new SampleEntity { Id = 1, Name = "Sample 1", Description = "This is sample 1" },
            new SampleEntity { Id = 2, Name = "Sample 2", Description = "This is sample 2" }
        };

        [HttpGet]
        public ActionResult<IEnumerable<SampleEntity>> GetAll()
        {
            return Ok(_samples);
        }

        [HttpGet("{id}")]
        public ActionResult<SampleEntity> GetById(int id)
        {
            var sample = _samples.FirstOrDefault(s => s.Id == id);
            if (sample == null)
                return NotFound();
                
            return Ok(sample);
        }
    }
}
"@
    Set-Content -Path "Controllers\SampleController.cs" -Value $sampleControllerContent
    
    # Create a README with instructions
    $readmeContent = @"
# $ProjectName - .NET API Server

This is a .NET Web API project created with the ForgeMaster setup tool.

## Getting Started

1. Navigate to the project directory:
   ```
   cd $projectPath/$ProjectName
   ```

2. Run the project:
   ```
   dotnet run
   ```

3. Access the Swagger UI:
   ```
   https://localhost:5001/swagger
   ```

## Project Structure

- **Controllers/**: API endpoints
- **Models/**: Data models/entities
- **Data/**: Database context and repositories
- **Services/**: Business logic
- **DTOs/**: Data Transfer Objects
- **Middleware/**: Custom middleware components
- **Extensions/**: Extension methods

## Dependencies

- Entity Framework Core
- AutoMapper
- Swashbuckle (Swagger)
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host ".NET API server project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 