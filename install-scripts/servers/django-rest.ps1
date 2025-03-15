# ----------------------------------------
# ForgeMaster - Django REST Framework Server Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new Django project
# 2. Sets up virtual environment
# 3. Installs Django REST Framework
# 4. Creates a sample API app
# ----------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Ensure the target directory exists
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/django-rest"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
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
    
    # Install Django and Django REST Framework
    Write-Host "Installing Django and Django REST Framework..." -ForegroundColor Cyan
    if ($IsWindows -or $env:OS -match "Windows") {
        & .\venv\Scripts\pip.exe install django djangorestframework django-cors-headers django-filter
    } else {
        & ./venv/bin/pip install django djangorestframework django-cors-headers django-filter
    }
    
    # Create requirements.txt
    $requirementsContent = @"
Django==4.2.7
djangorestframework==3.14.0
django-cors-headers==4.3.0
django-filter==23.3
pytest==7.4.3
pytest-django==4.5.2
drf-yasg==1.21.7
"@
    Set-Content -Path "requirements.txt" -Value $requirementsContent
    
    # Create Django project
    Write-Host "Creating Django project..." -ForegroundColor Cyan
    if ($IsWindows -or $env:OS -match "Windows") {
        & .\venv\Scripts\django-admin.exe startproject $ProjectName .
    } else {
        & ./venv/bin/django-admin startproject $ProjectName .
    }
    
    # Create API app
    Write-Host "Creating API app..." -ForegroundColor Cyan
    if ($IsWindows -or $env:OS -match "Windows") {
        & .\venv\Scripts\python.exe manage.py startapp api
    } else {
        & ./venv/bin/python manage.py startapp api
    }
    
    # Update settings.py
    $settingsPath = Join-Path -Path $ProjectName -ChildPath "settings.py"
    $settingsContent = Get-Content -Path $settingsPath -Raw
    
    # Add REST Framework and CORS to INSTALLED_APPS
    $installedAppsPattern = "INSTALLED_APPS = \["
    $installedAppsReplacement = @"
INSTALLED_APPS = [
    'rest_framework',
    'corsheaders',
    'drf_yasg',
    'api',
"@
    $settingsContent = $settingsContent -replace $installedAppsPattern, $installedAppsReplacement
    
    # Add CORS middleware
    $middlewarePattern = "MIDDLEWARE = \["
    $middlewareReplacement = @"
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
"@
    $settingsContent = $settingsContent -replace $middlewarePattern, $middlewareReplacement
    
    # Add REST Framework settings
    $restFrameworkSettings = @"

# Django REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10
}

# CORS settings
CORS_ALLOW_ALL_ORIGINS = True
"@
    $settingsContent += $restFrameworkSettings
    
    # Write updated settings
    Set-Content -Path $settingsPath -Value $settingsContent
    
    # Create models.py in api app
    $modelsContent = @"
from django.db import models

class Item(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
"@
    Set-Content -Path "api/models.py" -Value $modelsContent
    
    # Create serializers.py in api app
    $serializersContent = @"
from rest_framework import serializers
from .models import Item

class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ['id', 'name', 'description', 'price', 'created_at', 'updated_at']
"@
    Set-Content -Path "api/serializers.py" -Value $serializersContent
    
    # Create views.py in api app
    $viewsContent = @"
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from .models import Item
from .serializers import ItemSerializer

class ItemViewSet(viewsets.ModelViewSet):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
"@
    Set-Content -Path "api/views.py" -Value $viewsContent
    
    # Create urls.py in api app
    $apiUrlsContent = @"
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ItemViewSet

router = DefaultRouter()
router.register(r'items', ItemViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
"@
    Set-Content -Path "api/urls.py" -Value $apiUrlsContent
    
    # Update project urls.py
    $projectUrlsPath = Join-Path -Path $ProjectName -ChildPath "urls.py"
    $projectUrlsContent = @"
from django.contrib import admin
from django.urls import path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
   openapi.Info(
      title="$ProjectName API",
      default_version='v1',
      description="API documentation for $ProjectName",
   ),
   public=True,
   permission_classes=[permissions.AllowAny],
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api-auth/', include('rest_framework.urls')),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
]
"@
    Set-Content -Path $projectUrlsPath -Value $projectUrlsContent
    
    # Run migrations
    Write-Host "Running migrations..." -ForegroundColor Cyan
    if ($IsWindows -or $env:OS -match "Windows") {
        & .\venv\Scripts\python.exe manage.py makemigrations
        & .\venv\Scripts\python.exe manage.py migrate
    } else {
        & ./venv/bin/python manage.py makemigrations
        & ./venv/bin/python manage.py migrate
    }
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - Django REST Framework Server

This is a Django REST Framework project created with the ForgeMaster setup tool.

## Getting Started

1. Navigate to the project directory:
   ```
   cd $projectPath
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

4. Run migrations:
   ```
   python manage.py makemigrations
   python manage.py migrate
   ```

5. Create a superuser:
   ```
   python manage.py createsuperuser
   ```

6. Run the development server:
   ```
   python manage.py runserver
   ```

7. Access the API:
   - API Root: http://localhost:8000/api/
   - Admin Interface: http://localhost:8000/admin/
   - API Documentation: http://localhost:8000/swagger/

## Project Structure

- **api/**: Main API application
  - **models.py**: Database models
  - **serializers.py**: REST Framework serializers
  - **views.py**: API views and viewsets
  - **urls.py**: API URL routing

## Features

- RESTful API with Django REST Framework
- API documentation with Swagger/ReDoc
- CORS support
- Authentication with Django REST Framework
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "Django REST Framework server project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 