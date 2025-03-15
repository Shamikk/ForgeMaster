# ----------------------------------------
# ForgeMaster - React/Next.js Client Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new Next.js project
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
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/clients/react-nextjs"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create Next.js project
    Write-Host "Creating Next.js project..." -ForegroundColor Cyan
    npx create-next-app@latest $ProjectName --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
    
    # Navigate to project directory
    Set-Location $ProjectName
    
    # Install additional dependencies
    Write-Host "Installing additional dependencies..." -ForegroundColor Cyan
    npm install zustand axios react-hook-form zod @hookform/resolvers next-themes
    npm install --save-dev @types/node @types/react @types/react-dom
    
    # Create project structure
    $directories = @(
        "src/components/ui",
        "src/components/layout",
        "src/components/forms",
        "src/components/cards",
        "src/lib",
        "src/hooks",
        "src/store",
        "src/types",
        "src/utils",
        "public/images"
    )
    
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    # Update tailwind.config.js
    $tailwindConfigPath = "tailwind.config.ts"
    $tailwindConfigContent = @"
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
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
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [],
}
export default config
"@
    Set-Content -Path $tailwindConfigPath -Value $tailwindConfigContent
    
    # Create globals.css
    $globalCssPath = "src/app/globals.css"
    $globalCssContent = @"
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
    Set-Content -Path $globalCssPath -Value $globalCssContent
    
    # Create ThemeProvider
    $themeProviderDir = "src/components/providers"
    New-Item -Path $themeProviderDir -ItemType Directory -Force | Out-Null
    $themeProviderPath = "$themeProviderDir/theme-provider.tsx"
    $themeProviderContent = @"
'use client'

import { ThemeProvider as NextThemesProvider } from 'next-themes'
import { type ThemeProviderProps } from 'next-themes/dist/types'

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
"@
    Set-Content -Path $themeProviderPath -Value $themeProviderContent
    
    # Create layout.tsx
    $layoutPath = "src/app/layout.tsx"
    $layoutContent = @"
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { ThemeProvider } from '@/components/providers/theme-provider'
import Header from '@/components/layout/header'
import Footer from '@/components/layout/footer'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: '$ProjectName',
  description: 'A Next.js application created with ForgeMaster',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          <div className="flex flex-col min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
            <Header />
            <main className="flex-grow container mx-auto px-4 py-8">
              {children}
            </main>
            <Footer />
          </div>
        </ThemeProvider>
      </body>
    </html>
  )
}
"@
    Set-Content -Path $layoutPath -Value $layoutContent
    
    # Create Header component
    $headerComponentPath = "src/components/layout/header.tsx"
    $headerComponentContent = @"
'use client'

import Link from 'next/link'
import { useTheme } from 'next-themes'
import { useEffect, useState } from 'react'

export default function Header() {
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  // Avoid hydration mismatch
  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <header className="bg-white dark:bg-gray-800 shadow-sm">
      <div className="container mx-auto px-4 py-4">
        <div className="flex justify-between items-center">
          <Link href="/" className="text-2xl font-bold text-primary-600 dark:text-primary-400">
            $ProjectName
          </Link>
          <nav className="flex items-center space-x-6">
            <Link href="/" className="hover:text-primary-600 dark:hover:text-primary-400">
              Home
            </Link>
            <Link href="/about" className="hover:text-primary-600 dark:hover:text-primary-400">
              About
            </Link>
            <button
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700"
              aria-label="Toggle theme"
            >
              {theme === 'dark' ? (
                <SunIcon className="h-5 w-5" />
              ) : (
                <MoonIcon className="h-5 w-5" />
              )}
            </button>
          </nav>
        </div>
      </div>
    </header>
  )
}

function SunIcon({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      strokeWidth={1.5}
      stroke="currentColor"
      className={className}
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z"
      />
    </svg>
  )
}

function MoonIcon({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      strokeWidth={1.5}
      stroke="currentColor"
      className={className}
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z"
      />
    </svg>
  )
}
"@
    Set-Content -Path $headerComponentPath -Value $headerComponentContent
    
    # Create Footer component
    $footerComponentPath = "src/components/layout/footer.tsx"
    $footerComponentContent = @"
export default function Footer() {
  return (
    <footer className="bg-white dark:bg-gray-800 shadow-sm mt-auto py-6">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="mb-4 md:mb-0">
            <p className="text-sm text-gray-600 dark:text-gray-400">
              &copy; {new Date().getFullYear()} $ProjectName. All rights reserved.
            </p>
          </div>
          <div className="flex space-x-4">
            <a
              href="#"
              className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              aria-label="GitHub"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                className="h-5 w-5"
              >
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
              </svg>
            </a>
            <a
              href="#"
              className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              aria-label="Twitter"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                className="h-5 w-5"
              >
                <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z" />
              </svg>
            </a>
            <a
              href="#"
              className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              aria-label="LinkedIn"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                className="h-5 w-5"
              >
                <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
"@
    Set-Content -Path $footerComponentPath -Value $footerComponentContent
    
    # Create FeatureCard component
    $featureCardPath = "src/components/cards/feature-card.tsx"
    $featureCardContent = @"
import { ReactNode } from 'react'

interface FeatureCardProps {
  title: string
  description: string
  icon: ReactNode
}

export default function FeatureCard({ title, description, icon }: FeatureCardProps) {
  return (
    <div className="card flex flex-col items-center text-center">
      <div className="mb-4 text-primary-600 dark:text-primary-400">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600 dark:text-gray-400">{description}</p>
    </div>
  )
}
"@
    Set-Content -Path $featureCardPath -Value $featureCardContent
    
    # Create page.tsx (home page)
    $pageContent = @"
import FeatureCard from '@/components/cards/feature-card'
import CounterDemo from '@/components/counter-demo'

export default function Home() {
  return (
    <div>
      <section className="py-12">
        <div className="text-center">
          <h1 className="text-4xl font-bold mb-4">Welcome to $ProjectName</h1>
          <p className="text-xl text-gray-600 dark:text-gray-400 mb-8">
            A modern Next.js application with Tailwind CSS
          </p>
          <div className="flex justify-center space-x-4">
            <button className="btn btn-primary">Get Started</button>
            <button className="btn btn-secondary">Learn More</button>
          </div>
        </div>
      </section>

      <section className="py-12">
        <h2 className="text-2xl font-bold mb-6 text-center">Features</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <FeatureCard
            title="Next.js 14"
            description="Built with the latest version of Next.js for optimal performance and developer experience."
            icon={<NextjsIcon className="w-12 h-12" />}
          />
          <FeatureCard
            title="Tailwind CSS"
            description="Styled with Tailwind CSS for rapid UI development with utility classes."
            icon={<TailwindIcon className="w-12 h-12" />}
          />
          <FeatureCard
            title="Dark Mode"
            description="Includes dark mode support for better user experience in low-light environments."
            icon={<MoonIcon className="w-12 h-12" />}
          />
        </div>
      </section>

      <section className="py-12">
        <CounterDemo />
      </section>
    </div>
  )
}

function NextjsIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 180 180" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <mask
        id="mask0_408_134"
        style={{ maskType: 'alpha' }}
        maskUnits="userSpaceOnUse"
        x="0"
        y="0"
        width="180"
        height="180"
      >
        <circle cx="90" cy="90" r="90" fill="black" />
      </mask>
      <g mask="url(#mask0_408_134)">
        <circle cx="90" cy="90" r="90" fill="currentColor" />
        <path
          d="M149.508 157.52L69.142 54H54V125.97H66.1136V69.3836L139.999 164.845C143.333 162.614 146.509 160.165 149.508 157.52Z"
          fill="url(#paint0_linear_408_134)"
        />
        <rect x="115" y="54" width="12" height="72" fill="url(#paint1_linear_408_134)" />
      </g>
      <defs>
        <linearGradient
          id="paint0_linear_408_134"
          x1="109"
          y1="116.5"
          x2="144.5"
          y2="160.5"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="white" />
          <stop offset="1" stopColor="white" stopOpacity="0" />
        </linearGradient>
        <linearGradient
          id="paint1_linear_408_134"
          x1="121"
          y1="54"
          x2="120.799"
          y2="106.875"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="white" />
          <stop offset="1" stopColor="white" stopOpacity="0" />
        </linearGradient>
      </defs>
    </svg>
  )
}

function TailwindIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path
        fill="currentColor"
        d="M32 16C24.8 16 20.3 19.6 18.5 26.8C21.2 23.2 24.4 21.4 28.3 21.6C30.5 21.7 32.1 23.3 33.8 25.1C36.5 28 39.6 31.2 47.5 31.2C54.7 31.2 59.2 27.6 61 20.4C58.3 24 55.1 25.8 51.2 25.6C49 25.5 47.4 23.9 45.7 22.1C43 19.2 39.9 16 32 16ZM16.5 32C9.3 32 4.8 35.6 3 42.8C5.7 39.2 8.9 37.4 12.8 37.6C15 37.7 16.6 39.3 18.3 41.1C21 44 24.1 47.2 32 47.2C39.2 47.2 43.7 43.6 45.5 36.4C42.8 40 39.6 41.8 35.7 41.6C33.5 41.5 31.9 39.9 30.2 38.1C27.5 35.2 24.4 32 16.5 32Z"
      />
    </svg>
  )
}

function MoonIcon({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      strokeWidth={1.5}
      stroke="currentColor"
      className={className}
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z"
      />
    </svg>
  )
}
"@
    Set-Content -Path "src/app/page.tsx" -Value $pageContent
    
    # Create about page
    $aboutPageDir = "src/app/about"
    New-Item -Path $aboutPageDir -ItemType Directory -Force | Out-Null
    $aboutPageContent = @"
export default function AboutPage() {
  return (
    <div>
      <section className="py-12">
        <h1 className="text-4xl font-bold mb-6">About $ProjectName</h1>
        <p className="text-lg mb-4">
          This is a Next.js application created with the ForgeMaster setup tool.
        </p>
        <p className="text-lg mb-8">
          It includes Tailwind CSS for styling, Zustand for state management, and dark mode support.
        </p>
        
        <h2 className="text-2xl font-bold mt-8 mb-4">Technologies Used</h2>
        <ul className="list-disc list-inside space-y-2 mb-8">
          <li>Next.js 14 - The React Framework</li>
          <li>React 18 - JavaScript Library for UI</li>
          <li>Tailwind CSS - Utility-first CSS framework</li>
          <li>Zustand - State management</li>
          <li>TypeScript - Typed JavaScript</li>
        </ul>
      </section>
    </div>
  )
}
"@
    Set-Content -Path "$aboutPageDir/page.tsx" -Value $aboutPageContent
    
    # Create counter store with Zustand
    $storeDir = "src/store"
    New-Item -Path $storeDir -ItemType Directory -Force | Out-Null
    $counterStoreContent = @"
import { create } from 'zustand'

interface CounterState {
  count: number
  increment: () => void
  decrement: () => void
  reset: () => void
}

export const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}))
"@
    Set-Content -Path "$storeDir/counter-store.ts" -Value $counterStoreContent
    
    # Create CounterDemo component
    $counterDemoPath = "src/components/counter-demo.tsx"
    $counterDemoContent = @"
'use client'

import { useCounterStore } from '@/store/counter-store'

export default function CounterDemo() {
  const { count, increment, decrement, reset } = useCounterStore()

  return (
    <div className="card">
      <h2 className="text-2xl font-bold mb-4">Counter Example</h2>
      <p className="mb-4">Current count: {count}</p>
      <p className="mb-4">Double count: {count * 2}</p>
      <div className="flex space-x-2">
        <button onClick={increment} className="btn btn-primary">
          Increment
        </button>
        <button onClick={decrement} className="btn btn-secondary">
          Decrement
        </button>
        <button onClick={reset} className="btn btn-secondary">
          Reset
        </button>
      </div>
    </div>
  )
}
"@
    Set-Content -Path $counterDemoPath -Value $counterDemoContent
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - React/Next.js Client

This is a Next.js project created with the ForgeMaster setup tool.

## Features

- Next.js 14 with App Router
- React 18 with TypeScript
- Tailwind CSS for styling
- Dark mode support with next-themes
- Zustand for state management
- Form handling with react-hook-form and zod

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

5. Start the production server:
   ```
   npm start
   ```

## Project Structure

- **src/app/**: Next.js App Router pages and layouts
- **src/components/**: React components
  - **ui/**: UI components
  - **layout/**: Layout components
  - **forms/**: Form components
  - **cards/**: Card components
  - **providers/**: Context providers
- **src/lib/**: Library code and utilities
- **src/hooks/**: Custom React hooks
- **src/store/**: Zustand stores
- **src/types/**: TypeScript type definitions
- **src/utils/**: Utility functions
- **public/**: Static assets

## Styling

This project uses Tailwind CSS for styling. Custom utility classes are defined in `src/app/globals.css`.
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "React/Next.js client project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 