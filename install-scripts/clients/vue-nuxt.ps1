# ----------------------------------------
# ForgeMaster - Vue/Nuxt Client Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new Nuxt 3 project
# 2. Installs dependencies
# 3. Sets up Tailwind CSS
# 4. Creates basic project structure
# ----------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Ensure the target directory exists
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/vue-nuxt"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create Nuxt project
    Write-Host "Creating Nuxt project..." -ForegroundColor Cyan
    npx nuxi@latest init $ProjectName
    
    # Navigate to project directory
    Set-Location $ProjectName
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    npm install
    
    # Install additional dependencies
    Write-Host "Installing additional dependencies..." -ForegroundColor Cyan
    npm install @pinia/nuxt pinia @nuxtjs/tailwindcss @nuxtjs/color-mode nuxt-icon
    npm install --save-dev sass
    
    # Set up Tailwind CSS
    Write-Host "Setting up Tailwind CSS..." -ForegroundColor Cyan
    npx tailwindcss init
    
    # Update nuxt.config.ts
    $nuxtConfigPath = "nuxt.config.ts"
    $nuxtConfigContent = @"
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/color-mode',
    'nuxt-icon'
  ],
  colorMode: {
    preference: 'system',
    fallback: 'light',
    hid: 'nuxt-color-mode-script',
    globalName: '__NUXT_COLOR_MODE__',
    componentName: 'ColorScheme',
    classPrefix: '',
    classSuffix: '-mode',
    storageKey: 'nuxt-color-mode'
  },
  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css',
    configPath: 'tailwind.config.js',
    exposeConfig: false,
    viewer: true,
  },
  app: {
    head: {
      title: '$ProjectName',
      meta: [
        { name: 'description', content: 'A Nuxt 3 application created with ForgeMaster' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  }
})
"@
    Set-Content -Path $nuxtConfigPath -Value $nuxtConfigContent
    
    # Create tailwind.config.js
    $tailwindConfigPath = "tailwind.config.js"
    $tailwindConfigContent = @"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './app.vue',
    './error.vue'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
          950: '#082f49',
        },
      },
    },
  },
  plugins: [],
}
"@
    Set-Content -Path $tailwindConfigPath -Value $tailwindConfigContent
    
    # Create tailwind.css
    $tailwindCssDir = "assets/css"
    New-Item -Path $tailwindCssDir -ItemType Directory -Force | Out-Null
    $tailwindCssPath = "$tailwindCssDir/tailwind.css"
    $tailwindCssContent = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn {
    @apply px-4 py-2 rounded-md font-medium transition-colors;
  }
  .btn-primary {
    @apply bg-primary-600 text-white hover:bg-primary-700;
  }
  .btn-secondary {
    @apply bg-gray-200 text-gray-800 hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600;
  }
  .card {
    @apply bg-white dark:bg-gray-800 rounded-lg shadow-md p-6;
  }
  .input {
    @apply w-full px-4 py-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white;
  }
}
"@
    Set-Content -Path $tailwindCssPath -Value $tailwindCssContent
    
    # Create project structure
    $directories = @(
        "components/ui",
        "components/layout",
        "components/forms",
        "components/cards",
        "layouts",
        "pages",
        "stores",
        "composables",
        "utils",
        "types",
        "public/images"
    )
    
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    # Create app.vue
    $appVuePath = "app.vue"
    $appVueContent = @"
<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>
"@
    Set-Content -Path $appVuePath -Value $appVueContent
    
    # Create default layout
    $defaultLayoutPath = "layouts/default.vue"
    $defaultLayoutContent = @"
<template>
  <div>
    <AppHeader />
    <main class="container mx-auto px-4 py-8">
      <slot />
    </main>
    <AppFooter />
  </div>
</template>
"@
    Set-Content -Path $defaultLayoutPath -Value $defaultLayoutContent
    
    # Create AppHeader component
    $headerComponentPath = "components/layout/AppHeader.vue"
    $headerComponentContent = @"
<template>
  <header class="bg-white dark:bg-gray-800 shadow-sm">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <NuxtLink to="/" class="text-2xl font-bold text-primary-600 dark:text-primary-400">
          {{ appName }}
        </NuxtLink>
        <nav class="flex items-center space-x-6">
          <NuxtLink to="/" class="hover:text-primary-600 dark:hover:text-primary-400">Home</NuxtLink>
          <NuxtLink to="/about" class="hover:text-primary-600 dark:hover:text-primary-400">About</NuxtLink>
          <button @click="toggleColorMode" class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
            <Icon v-if="colorMode.value === 'dark'" name="uil:sun" class="w-5 h-5" />
            <Icon v-else name="uil:moon" class="w-5 h-5" />
          </button>
        </nav>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
const appName = '$ProjectName';
const colorMode = useColorMode();

const toggleColorMode = () => {
  colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark';
};
</script>
"@
    Set-Content -Path $headerComponentPath -Value $headerComponentContent
    
    # Create AppFooter component
    $footerComponentPath = "components/layout/AppFooter.vue"
    $footerComponentContent = @"
<template>
  <footer class="bg-white dark:bg-gray-800 shadow-sm mt-auto py-6">
    <div class="container mx-auto px-4">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <div class="mb-4 md:mb-0">
          <p class="text-sm text-gray-600 dark:text-gray-400">
            &copy; {{ new Date().getFullYear() }} {{ appName }}. All rights reserved.
          </p>
        </div>
        <div class="flex space-x-4">
          <a href="#" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
            <Icon name="uil:github" class="w-5 h-5" />
          </a>
          <a href="#" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
            <Icon name="uil:twitter" class="w-5 h-5" />
          </a>
          <a href="#" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
            <Icon name="uil:linkedin" class="w-5 h-5" />
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const appName = '$ProjectName';
</script>
"@
    Set-Content -Path $footerComponentPath -Value $footerComponentContent
    
    # Create index page
    $indexPagePath = "pages/index.vue"
    $indexPageContent = @"
<template>
  <div>
    <section class="py-12">
      <div class="text-center">
        <h1 class="text-4xl font-bold mb-4">Welcome to {{ appName }}</h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 mb-8">
          A modern Nuxt 3 application with Tailwind CSS
        </p>
        <div class="flex justify-center space-x-4">
          <button class="btn btn-primary">Get Started</button>
          <button class="btn btn-secondary">Learn More</button>
        </div>
      </div>
    </section>

    <section class="py-12">
      <h2 class="text-2xl font-bold mb-6 text-center">Features</h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <FeatureCard 
          v-for="feature in features" 
          :key="feature.title"
          :title="feature.title"
          :description="feature.description"
          :icon="feature.icon"
        />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
const appName = '$ProjectName';

const features = [
  {
    title: 'Nuxt 3',
    description: 'Built with the latest version of Nuxt for optimal performance and developer experience.',
    icon: 'logos:nuxt-icon'
  },
  {
    title: 'Tailwind CSS',
    description: 'Styled with Tailwind CSS for rapid UI development with utility classes.',
    icon: 'logos:tailwindcss-icon'
  },
  {
    title: 'Dark Mode',
    description: 'Includes dark mode support for better user experience in low-light environments.',
    icon: 'uil:moon'
  }
];
</script>
"@
    Set-Content -Path $indexPagePath -Value $indexPageContent
    
    # Create about page
    $aboutPagePath = "pages/about.vue"
    $aboutPageContent = @"
<template>
  <div>
    <section class="py-12">
      <h1 class="text-4xl font-bold mb-6">About {{ appName }}</h1>
      <p class="text-lg mb-4">
        This is a Nuxt 3 application created with the ForgeMaster setup tool.
      </p>
      <p class="text-lg mb-8">
        It includes Tailwind CSS for styling, Pinia for state management, and dark mode support.
      </p>
      
      <h2 class="text-2xl font-bold mt-8 mb-4">Technologies Used</h2>
      <ul class="list-disc list-inside space-y-2 mb-8">
        <li>Nuxt 3 - The Vue.js Framework</li>
        <li>Vue 3 - Progressive JavaScript Framework</li>
        <li>Tailwind CSS - Utility-first CSS framework</li>
        <li>Pinia - State management for Vue</li>
        <li>TypeScript - Typed JavaScript</li>
      </ul>
    </section>
  </div>
</template>

<script setup lang="ts">
const appName = '$ProjectName';
</script>
"@
    Set-Content -Path $aboutPagePath -Value $aboutPageContent
    
    # Create FeatureCard component
    $featureCardPath = "components/cards/FeatureCard.vue"
    $featureCardContent = @"
<template>
  <div class="card flex flex-col items-center text-center">
    <div class="mb-4 text-primary-600 dark:text-primary-400">
      <Icon :name="icon" class="w-12 h-12" />
    </div>
    <h3 class="text-xl font-semibold mb-2">{{ title }}</h3>
    <p class="text-gray-600 dark:text-gray-400">{{ description }}</p>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  description: string;
  icon: string;
}>();
</script>
"@
    Set-Content -Path $featureCardPath -Value $featureCardContent
    
    # Create counter store with Pinia
    $counterStorePath = "stores/counter.ts"
    $counterStoreContent = @"
import { defineStore } from 'pinia';

export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0
  }),
  getters: {
    doubleCount: (state) => state.count * 2
  },
  actions: {
    increment() {
      this.count++;
    },
    decrement() {
      this.count--;
    },
    reset() {
      this.count = 0;
    }
  }
});
"@
    Set-Content -Path $counterStorePath -Value $counterStoreContent
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - Vue/Nuxt Client

This is a Nuxt 3 project created with the ForgeMaster setup tool.

## Features

- Nuxt 3 with Vue 3 and TypeScript
- Tailwind CSS for styling
- Dark mode support
- Pinia for state management
- Icon support with nuxt-icon

## Getting Started

1. Navigate to the project directory:
   ```
   cd $projectPath/$ProjectName
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npm run dev
   ```

4. Build for production:
   ```
   npm run build
   ```

5. Preview production build:
   ```
   npm run preview
   ```

## Project Structure

- **components/**: Vue components
  - **ui/**: UI components
  - **layout/**: Layout components
  - **forms/**: Form components
  - **cards/**: Card components
- **layouts/**: Nuxt layouts
- **pages/**: Nuxt pages (auto-routing)
- **stores/**: Pinia stores
- **composables/**: Vue composables
- **utils/**: Utility functions
- **types/**: TypeScript type definitions
- **public/**: Static assets
- **assets/**: CSS, images, and other assets

## Styling

This project uses Tailwind CSS for styling. Custom utility classes are defined in `assets/css/tailwind.css`.
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "Vue/Nuxt client project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 