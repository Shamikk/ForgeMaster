# ----------------------------------------
# ForgeMaster - Vue/Vite Client Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new Vue 3 project with Vite
# 2. Sets up TypeScript
# 3. Installs dependencies
# 4. Sets up Tailwind CSS
# 5. Creates basic project structure
# ----------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Ensure the target directory exists
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/vue-vite"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create Vue project with Vite
    Write-Host "Creating Vue project with Vite..." -ForegroundColor Cyan
    npm create vite@latest $ProjectName -- --template vue-ts
    
    # Navigate to project directory
    Set-Location $ProjectName
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    npm install
    
    # Install additional dependencies
    Write-Host "Installing additional dependencies..." -ForegroundColor Cyan
    npm install vue-router@4 pinia axios vue-i18n@9
    npm install tailwindcss postcss autoprefixer @headlessui/vue @heroicons/vue
    npm install --save-dev sass
    
    # Set up Tailwind CSS
    Write-Host "Setting up Tailwind CSS..." -ForegroundColor Cyan
    npx tailwindcss init -p
    
    # Update tailwind.config.js
    $tailwindConfigPath = "tailwind.config.js"
    $tailwindConfigContent = @"
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
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
    
    # Create src/assets/css/tailwind.css
    $tailwindCssDir = "src/assets/css"
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
        "src/components/ui",
        "src/components/layout",
        "src/components/forms",
        "src/components/cards",
        "src/views",
        "src/router",
        "src/stores",
        "src/composables",
        "src/utils",
        "src/types",
        "src/assets/images"
    )
    
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    # Update main.ts
    $mainTsPath = "src/main.ts"
    $mainTsContent = @"
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './assets/css/tailwind.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)

app.mount('#app')
"@
    Set-Content -Path $mainTsPath -Value $mainTsContent
    
    # Create router/index.ts
    $routerPath = "src/router/index.ts"
    $routerContent = @"
import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue')
    }
  ]
})

export default router
"@
    Set-Content -Path $routerPath -Value $routerContent
    
    # Create App.vue
    $appVuePath = "src/App.vue"
    $appVueContent = @"
<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
    <AppHeader />
    <main class="container mx-auto px-4 py-8">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>

<script setup lang="ts">
import AppHeader from './components/layout/AppHeader.vue';
import AppFooter from './components/layout/AppFooter.vue';
</script>
"@
    Set-Content -Path $appVuePath -Value $appVueContent
    
    # Create AppHeader component
    $headerComponentPath = "src/components/layout/AppHeader.vue"
    $headerComponentContent = @"
<template>
  <header class="bg-white dark:bg-gray-800 shadow-sm">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <router-link to="/" class="text-2xl font-bold text-primary-600 dark:text-primary-400">
          {{ appName }}
        </router-link>
        <nav class="flex items-center space-x-6">
          <router-link to="/" class="hover:text-primary-600 dark:hover:text-primary-400">Home</router-link>
          <router-link to="/about" class="hover:text-primary-600 dark:hover:text-primary-400">About</router-link>
          <button @click="toggleDarkMode" class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
            <svg v-if="isDarkMode" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
          </button>
        </nav>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';

const appName = '$ProjectName';
const isDarkMode = ref(false);

// Function to toggle dark mode
const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value;
  if (isDarkMode.value) {
    document.documentElement.classList.add('dark');
    localStorage.setItem('darkMode', 'true');
  } else {
    document.documentElement.classList.remove('dark');
    localStorage.setItem('darkMode', 'false');
  }
};

// Initialize dark mode based on user preference
onMounted(() => {
  const darkModePreference = localStorage.getItem('darkMode');
  if (darkModePreference === 'true' || (!darkModePreference && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    isDarkMode.value = true;
    document.documentElement.classList.add('dark');
  }
});
</script>
"@
    Set-Content -Path $headerComponentPath -Value $headerComponentContent
    
    # Create AppFooter component
    $footerComponentPath = "src/components/layout/AppFooter.vue"
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
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
          </a>
          <a href="#" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"/>
            </svg>
          </a>
          <a href="#" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
            </svg>
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
    
    # Create HomeView
    $homeViewPath = "src/views/HomeView.vue"
    $homeViewContent = @"
<template>
  <div>
    <section class="py-12">
      <div class="text-center">
        <h1 class="text-4xl font-bold mb-4">Welcome to {{ appName }}</h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 mb-8">
          A modern Vue 3 application with Vite and Tailwind CSS
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

    <section class="py-12">
      <div class="card">
        <h2 class="text-2xl font-bold mb-4">Counter Example</h2>
        <p class="mb-4">Current count: {{ counter.count }}</p>
        <p class="mb-4">Double count: {{ counter.doubleCount }}</p>
        <div class="flex space-x-2">
          <button @click="counter.increment()" class="btn btn-primary">Increment</button>
          <button @click="counter.decrement()" class="btn btn-secondary">Decrement</button>
          <button @click="counter.reset()" class="btn btn-secondary">Reset</button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { useCounterStore } from '../stores/counter';
import FeatureCard from '../components/cards/FeatureCard.vue';

const appName = '$ProjectName';
const counter = useCounterStore();

const features = [
  {
    title: 'Vue 3',
    description: 'Built with the latest version of Vue for optimal performance and developer experience.',
    icon: 'vue'
  },
  {
    title: 'Tailwind CSS',
    description: 'Styled with Tailwind CSS for rapid UI development with utility classes.',
    icon: 'tailwind'
  },
  {
    title: 'Vite',
    description: 'Lightning fast development server and optimized builds with Vite.',
    icon: 'vite'
  }
];
</script>
"@
    Set-Content -Path $homeViewPath -Value $homeViewContent
    
    # Create AboutView
    $aboutViewPath = "src/views/AboutView.vue"
    $aboutViewContent = @"
<template>
  <div>
    <section class="py-12">
      <h1 class="text-4xl font-bold mb-6">About {{ appName }}</h1>
      <p class="text-lg mb-4">
        This is a Vue 3 application created with the ForgeMaster setup tool.
      </p>
      <p class="text-lg mb-8">
        It includes Vite for fast development, Tailwind CSS for styling, Pinia for state management, and Vue Router for navigation.
      </p>
      
      <h2 class="text-2xl font-bold mt-8 mb-4">Technologies Used</h2>
      <ul class="list-disc list-inside space-y-2 mb-8">
        <li>Vue 3 - Progressive JavaScript Framework</li>
        <li>Vite - Next Generation Frontend Tooling</li>
        <li>Tailwind CSS - Utility-first CSS framework</li>
        <li>Pinia - State management for Vue</li>
        <li>Vue Router - Official router for Vue.js</li>
        <li>TypeScript - Typed JavaScript</li>
      </ul>
    </section>
  </div>
</template>

<script setup lang="ts">
const appName = '$ProjectName';
</script>
"@
    Set-Content -Path $aboutViewPath -Value $aboutViewContent
    
    # Create FeatureCard component
    $featureCardPath = "src/components/cards/FeatureCard.vue"
    $featureCardContent = @"
<template>
  <div class="card flex flex-col items-center text-center">
    <div class="mb-4 text-primary-600 dark:text-primary-400">
      <component :is="iconComponent" class="w-12 h-12" />
    </div>
    <h3 class="text-xl font-semibold mb-2">{{ title }}</h3>
    <p class="text-gray-600 dark:text-gray-400">{{ description }}</p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  title: string;
  description: string;
  icon: string;
}>();

const iconComponent = computed(() => {
  switch (props.icon) {
    case 'vue':
      return VueIcon;
    case 'tailwind':
      return TailwindIcon;
    case 'vite':
      return ViteIcon;
    default:
      return null;
  }
});

// Simple SVG components for icons
const VueIcon = {
  template: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" class="w-12 h-12">
      <path fill="currentColor" d="M78.8,10L64,35.4L49.2,10H0l64,110l64-110C128,10,78.8,10,78.8,10z"/>
      <path fill="currentColor" d="M78.8,10L64,35.4L49.2,10H25.6L64,76l38.4-66H78.8z" opacity="0.6"/>
    </svg>
  `
};

const TailwindIcon = {
  template: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="w-12 h-12">
      <path fill="currentColor" d="M32 16C24.8 16 20.3 19.6 18.5 26.8C21.2 23.2 24.4 21.4 28.3 21.6C30.5 21.7 32.1 23.3 33.8 25.1C36.5 28 39.6 31.2 47.5 31.2C54.7 31.2 59.2 27.6 61 20.4C58.3 24 55.1 25.8 51.2 25.6C49 25.5 47.4 23.9 45.7 22.1C43 19.2 39.9 16 32 16ZM16.5 32C9.3 32 4.8 35.6 3 42.8C5.7 39.2 8.9 37.4 12.8 37.6C15 37.7 16.6 39.3 18.3 41.1C21 44 24.1 47.2 32 47.2C39.2 47.2 43.7 43.6 45.5 36.4C42.8 40 39.6 41.8 35.7 41.6C33.5 41.5 31.9 39.9 30.2 38.1C27.5 35.2 24.4 32 16.5 32Z"/>
    </svg>
  `
};

const ViteIcon = {
  template: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 410 404" class="w-12 h-12">
      <path fill="currentColor" d="M399.641 59.525l-183.998 329.02c-3.799 6.793-13.559 6.833-17.415.073L10.582 59.556C6.38 52.19 12.68 43.266 21.028 44.76l184.195 32.923c1.175.21 2.378.208 3.553-.006l180.343-32.87c8.32-1.517 14.649 7.337 10.522 14.719z"/>
    </svg>
  `
};
</script>
"@
    Set-Content -Path $featureCardPath -Value $featureCardContent
    
    # Create counter store with Pinia
    $counterStorePath = "src/stores/counter.ts"
    $counterStoreContent = @"
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0
  }),
  getters: {
    doubleCount: (state) => state.count * 2
  },
  actions: {
    increment() {
      this.count++
    },
    decrement() {
      this.count--
    },
    reset() {
      this.count = 0
    }
  }
})
"@
    Set-Content -Path $counterStorePath -Value $counterStoreContent
    
    # Update index.html
    $indexHtmlPath = "index.html"
    $indexHtmlContent = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$ProjectName</title>
    <meta name="description" content="A Vue 3 application created with ForgeMaster">
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
"@
    Set-Content -Path $indexHtmlPath -Value $indexHtmlContent
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - Vue/Vite Client

This is a Vue 3 project with Vite created with the ForgeMaster setup tool.

## Features

- Vue 3 with TypeScript
- Vite for fast development
- Vue Router for navigation
- Pinia for state management
- Tailwind CSS for styling
- Dark mode support

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

- **src/components/**: Vue components
  - **ui/**: UI components
  - **layout/**: Layout components
  - **forms/**: Form components
  - **cards/**: Card components
- **src/views/**: Page components
- **src/router/**: Vue Router configuration
- **src/stores/**: Pinia stores
- **src/composables/**: Vue composables
- **src/utils/**: Utility functions
- **src/types/**: TypeScript type definitions
- **src/assets/**: CSS, images, and other assets

## Styling

This project uses Tailwind CSS for styling. Custom utility classes are defined in `src/assets/css/tailwind.css`.
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "Vue/Vite client project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 