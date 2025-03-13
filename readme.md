# ForgeMaster Project Setup Tool

A modular PowerShell script solution for setting up development project structures with server and client applications.

## Features

- Creates a standardized directory structure for development projects
- Allows selection and installation of server and client applications
- Uses themed messages for a more engaging user experience
- Modular design with separate scripts for different functionalities
- Validates user input and handles errors gracefully

## Directory Structure Created

- `apps`
  - `servers` (contains selected server projects)
  - `clients` (contains selected client projects)
- `workspace`
  - `designs`
  - `reports`
  - `ideas`
  - `research`
- `infra`
  - `docker`
  - `scripts`
  - `configs`
- `libs`
  - `shared`
  - `ai`
- `tests`
  - `integration`
  - `unit`
- `docs`

## Available Projects

### Server Projects

1. .NET API
2. FastAPI
3. Django REST
4. Express.js

### Client Projects

1. Vue/Nuxt
2. Vue/Vite
3. React/Next.js

## Script Files

- `setup_master.ps1` - Main script that orchestrates the entire process
- `setup_project_directories.ps1` - Handles directory creation with proper validation
- `setup_server_project.ps1` - Handles server project installation
- `setup_client_project.ps1` - Handles client project installation
- `messages.json` - Contains themed messages for user interaction

## Usage

1. Run the main script:

   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File setup_master.ps1
   ```

2. Enter a project name (only letters, numbers, hyphens, and underscores allowed)

3. Enter a base path or press Enter to use the default (`$env:USERPROFILE\source\repos`)

4. Follow the interactive prompts to select server and client projects

5. The script will create the directory structure and install the selected projects

## Message Themes

The script uses themed messages from `messages.json` to provide a more engaging user experience. The themes include:

- Standard
- Tech
- Friendly
- Professional
- Pirate
- Fantasy
- Gothic Horror
- Space Explorer
- Cyberpunk
- Medieval
- Wild West
- Underwater
- Superhero
- Steampunk
- Ancient Egypt
- Alien Technology

## Technical Notes

- The script is designed to be modular and easy to maintain
- Each script file has a specific responsibility
- User input is validated to prevent errors
- The script handles existing directories with confirmation prompts
- The script returns to the original directory when complete
