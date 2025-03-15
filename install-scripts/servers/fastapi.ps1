# ----------------------------------------
# ForgeMaster - FastAPI Server Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new FastAPI project
# 2. Sets up virtual environment
# 3. Installs dependencies
# 4. Creates basic project structure
# ----------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Ensure the target directory exists
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/fastapi"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create project directory
    Write-Host "Creating FastAPI project structure..." -ForegroundColor Cyan
    New-Item -Path $ProjectName -ItemType Directory -Force | Out-Null
    Set-Location $ProjectName
    
    # Create virtual environment
    Write-Host "Setting up Python virtual environment..." -ForegroundColor Cyan
    python -m venv venv
    
    # Activate virtual environment
    if ($IsWindows -or $env:OS -match "Windows") {
        Write-Host "Activating virtual environment..." -ForegroundColor Cyan
        & .\venv\Scripts\Activate.ps1
    } else {
        Write-Host "Activating virtual environment..." -ForegroundColor Cyan
        & ./venv/bin/activate
    }
    
    # Create requirements.txt
    $requirementsContent = @"
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.4.2
sqlalchemy==2.0.23
python-dotenv==1.0.0
pytest==7.4.3
httpx==0.25.1
alembic==1.12.1
"@
    Set-Content -Path "requirements.txt" -Value $requirementsContent
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    if ($IsWindows -or $env:OS -match "Windows") {
        & .\venv\Scripts\pip.exe install -r requirements.txt
    } else {
        & ./venv/bin/pip install -r requirements.txt
    }
    
    # Create project structure
    $directories = @(
        "app/api/endpoints",
        "app/api/dependencies",
        "app/core",
        "app/db",
        "app/models",
        "app/schemas",
        "app/services",
        "tests/api",
        "tests/services"
    )
    
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    # Create main.py
    $mainContent = @"
from fastapi import FastAPI
from app.api.endpoints import items, users

app = FastAPI(
    title="$ProjectName",
    description="FastAPI project created with ForgeMaster",
    version="0.1.0"
)

app.include_router(items.router, prefix="/api/items", tags=["items"])
app.include_router(users.router, prefix="/api/users", tags=["users"])

@app.get("/")
async def root():
    return {"message": "Welcome to $ProjectName API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
"@
    Set-Content -Path "main.py" -Value $mainContent
    
    # Create config.py
    $configContent = @"
import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    API_V1_STR: str = "/api"
    PROJECT_NAME: str = "$ProjectName"
    
    # Database settings
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./app.db")
    
    # CORS settings
    BACKEND_CORS_ORIGINS: list[str] = ["*"]

settings = Settings()
"@
    New-Item -Path "app/core" -ItemType Directory -Force | Out-Null
    Set-Content -Path "app/core/config.py" -Value $configContent
    
    # Create items.py endpoint
    $itemsContent = @"
from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel

router = APIRouter()

# Sample Item model
class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price: float

# Sample data
items_db = [
    Item(id=1, name="Item 1", description="This is item 1", price=10.99),
    Item(id=2, name="Item 2", description="This is item 2", price=20.50)
]

@router.get("/", response_model=List[Item])
async def read_items():
    return items_db

@router.get("/{item_id}", response_model=Item)
async def read_item(item_id: int):
    item = next((item for item in items_db if item.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return item

@router.post("/", response_model=Item, status_code=status.HTTP_201_CREATED)
async def create_item(item: Item):
    items_db.append(item)
    return item
"@
    New-Item -Path "app/api/endpoints" -ItemType Directory -Force | Out-Null
    Set-Content -Path "app/api/endpoints/items.py" -Value $itemsContent
    
    # Create users.py endpoint
    $usersContent = @"
from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, EmailStr

router = APIRouter()

# Sample User model
class User(BaseModel):
    id: int
    username: str
    email: str
    is_active: bool = True

# Sample data
users_db = [
    User(id=1, username="user1", email="user1@example.com"),
    User(id=2, username="user2", email="user2@example.com")
]

@router.get("/", response_model=List[User])
async def read_users():
    return users_db

@router.get("/{user_id}", response_model=User)
async def read_user(user_id: int):
    user = next((user for user in users_db if user.id == user_id), None)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user
"@
    Set-Content -Path "app/api/endpoints/users.py" -Value $usersContent
    
    # Create __init__.py files
    $initFiles = @(
        "app/__init__.py",
        "app/api/__init__.py",
        "app/api/endpoints/__init__.py",
        "app/api/dependencies/__init__.py",
        "app/core/__init__.py",
        "app/db/__init__.py",
        "app/models/__init__.py",
        "app/schemas/__init__.py",
        "app/services/__init__.py"
    )
    
    foreach ($file in $initFiles) {
        New-Item -Path $file -ItemType File -Force | Out-Null
    }
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - FastAPI Server

This is a FastAPI project created with the ForgeMaster setup tool.

## Getting Started

1. Navigate to the project directory:
   ```
   cd $projectPath/$ProjectName
   ```

2. Activate the virtual environment:
   - Windows:
     ```
     .\venv\Scripts\activate
     ```
   - Linux/Mac:
     ```
     source venv/bin/activate
     ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Run the application:
   ```
   uvicorn main:app --reload
   ```

5. Access the API documentation:
   ```
   http://localhost:8000/docs
   ```

## Project Structure

- **app/api/endpoints/**: API route handlers
- **app/api/dependencies/**: Dependency injection functions
- **app/core/**: Core application settings
- **app/db/**: Database setup and session management
- **app/models/**: SQLAlchemy ORM models
- **app/schemas/**: Pydantic models for request/response validation
- **app/services/**: Business logic
- **tests/**: Test modules

## Dependencies

- FastAPI
- Uvicorn
- SQLAlchemy
- Pydantic
- Alembic (for migrations)
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "FastAPI server project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 