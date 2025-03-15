# ----------------------------------------
# ForgeMaster - Express.js Server Installation Script
# ----------------------------------------
# This script:
# 1. Creates a new Express.js project
# 2. Sets up TypeScript
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
$projectPath = Join-Path -Path $ProjectRoot -ChildPath "apps/servers/expressjs"
New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

# Navigate to the project directory
Push-Location $projectPath

try {
    # Create project directory
    Write-Host "Creating Express.js project structure..." -ForegroundColor Cyan
    New-Item -Path $ProjectName -ItemType Directory -Force | Out-Null
    Set-Location $ProjectName
    
    # Initialize npm project
    Write-Host "Initializing npm project..." -ForegroundColor Cyan
    npm init -y
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    npm install express cors helmet morgan dotenv mongoose jsonwebtoken bcryptjs
    
    # Install dev dependencies
    Write-Host "Installing dev dependencies..." -ForegroundColor Cyan
    npm install --save-dev typescript ts-node nodemon @types/express @types/cors @types/helmet @types/morgan @types/node @types/mongoose @types/jsonwebtoken @types/bcryptjs jest ts-jest @types/jest supertest @types/supertest
    
    # Initialize TypeScript
    Write-Host "Initializing TypeScript..." -ForegroundColor Cyan
    npx tsc --init
    
    # Update tsconfig.json
    $tsconfigContent = @"
{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
"@
    Set-Content -Path "tsconfig.json" -Value $tsconfigContent
    
    # Create project structure
    $directories = @(
        "src/controllers",
        "src/models",
        "src/routes",
        "src/middleware",
        "src/services",
        "src/utils",
        "src/config",
        "src/types",
        "tests/unit",
        "tests/integration"
    )
    
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    # Create .env file
    $envContent = @"
PORT=3000
MONGODB_URI=mongodb://localhost:27017/$ProjectName
JWT_SECRET=your_jwt_secret_key
NODE_ENV=development
"@
    Set-Content -Path ".env" -Value $envContent
    
    # Create .env.example file
    $envExampleContent = @"
PORT=3000
MONGODB_URI=mongodb://localhost:27017/$ProjectName
JWT_SECRET=your_jwt_secret_key
NODE_ENV=development
"@
    Set-Content -Path ".env.example" -Value $envExampleContent
    
    # Create .gitignore file
    $gitignoreContent = @"
# Dependencies
node_modules/

# Build
dist/

# Environment variables
.env

# Logs
logs
*.log
npm-debug.log*

# Coverage
coverage/

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
"@
    Set-Content -Path ".gitignore" -Value $gitignoreContent
    
    # Update package.json scripts
    $packageJsonPath = "package.json"
    $packageJson = Get-Content -Path $packageJsonPath -Raw | ConvertFrom-Json
    
    $packageJson.scripts = @{
        "start" = "node dist/server.js"
        "dev" = "nodemon src/server.ts"
        "build" = "tsc"
        "test" = "jest --coverage"
        "lint" = "eslint . --ext .ts"
    }
    
    $packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath
    
    # Create server.ts
    $serverContent = @"
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { connectDB } from './config/database';
import userRoutes from './routes/userRoutes';
import itemRoutes from './routes/itemRoutes';
import { errorHandler } from './middleware/errorMiddleware';

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/items', itemRoutes);

// Welcome route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to $ProjectName API' });
});

// Error handling middleware
app.use(errorHandler);

// Start server
const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();
    
    app.listen(PORT, () => {
      console.log(`Server running on port \${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

export default app;
"@
    Set-Content -Path "src/server.ts" -Value $serverContent
    
    # Create database.ts
    $databaseContent = @"
import mongoose from 'mongoose';

export const connectDB = async (): Promise<void> => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI as string);
    console.log(`MongoDB Connected: \${conn.connection.host}`);
  } catch (error) {
    console.error(`Error connecting to MongoDB: \${error}`);
    process.exit(1);
  }
};
"@
    Set-Content -Path "src/config/database.ts" -Value $databaseContent
    
    # Create User model
    $userModelContent = @"
import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser extends Document {
  name: string;
  email: string;
  password: string;
  isAdmin: boolean;
  createdAt: Date;
  updatedAt: Date;
  matchPassword(enteredPassword: string): Promise<boolean>;
}

const userSchema = new Schema<IUser>(
  {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },
    isAdmin: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    next();
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Method to compare passwords
userSchema.methods.matchPassword = async function (enteredPassword: string): Promise<boolean> {
  return await bcrypt.compare(enteredPassword, this.password);
};

const User = mongoose.model<IUser>('User', userSchema);

export default User;
"@
    Set-Content -Path "src/models/userModel.ts" -Value $userModelContent
    
    # Create Item model
    $itemModelContent = @"
import mongoose, { Document, Schema } from 'mongoose';

export interface IItem extends Document {
  name: string;
  description: string;
  price: number;
  createdAt: Date;
  updatedAt: Date;
}

const itemSchema = new Schema<IItem>(
  {
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

const Item = mongoose.model<IItem>('Item', itemSchema);

export default Item;
"@
    Set-Content -Path "src/models/itemModel.ts" -Value $itemModelContent
    
    # Create user controller
    $userControllerContent = @"
import { Request, Response } from 'express';
import User, { IUser } from '../models/userModel';
import jwt from 'jsonwebtoken';

// Generate JWT
const generateToken = (id: string): string => {
  return jwt.sign({ id }, process.env.JWT_SECRET as string, {
    expiresIn: '30d',
  });
};

// @desc    Register a new user
// @route   POST /api/users
// @access  Public
export const registerUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, email, password } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });

    if (userExists) {
      res.status(400).json({ message: 'User already exists' });
      return;
    }

    // Create user
    const user = await User.create({
      name,
      email,
      password,
    });

    if (user) {
      res.status(201).json({
        _id: user._id,
        name: user.name,
        email: user.email,
        isAdmin: user.isAdmin,
        token: generateToken(user._id),
      });
    } else {
      res.status(400).json({ message: 'Invalid user data' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Auth user & get token
// @route   POST /api/users/login
// @access  Public
export const loginUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });

    // Check if user exists and password matches
    if (user && (await user.matchPassword(password))) {
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        isAdmin: user.isAdmin,
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
export const getUserProfile = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findById((req as any).user._id).select('-password');

    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};
"@
    Set-Content -Path "src/controllers/userController.ts" -Value $userControllerContent
    
    # Create item controller
    $itemControllerContent = @"
import { Request, Response } from 'express';
import Item from '../models/itemModel';

// @desc    Get all items
// @route   GET /api/items
// @access  Public
export const getItems = async (req: Request, res: Response): Promise<void> => {
  try {
    const items = await Item.find({});
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Get item by ID
// @route   GET /api/items/:id
// @access  Public
export const getItemById = async (req: Request, res: Response): Promise<void> => {
  try {
    const item = await Item.findById(req.params.id);

    if (item) {
      res.json(item);
    } else {
      res.status(404).json({ message: 'Item not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Create a new item
// @route   POST /api/items
// @access  Private/Admin
export const createItem = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, description, price } = req.body;

    const item = await Item.create({
      name,
      description,
      price,
    });

    res.status(201).json(item);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Update an item
// @route   PUT /api/items/:id
// @access  Private/Admin
export const updateItem = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, description, price } = req.body;

    const item = await Item.findById(req.params.id);

    if (item) {
      item.name = name || item.name;
      item.description = description || item.description;
      item.price = price || item.price;

      const updatedItem = await item.save();
      res.json(updatedItem);
    } else {
      res.status(404).json({ message: 'Item not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// @desc    Delete an item
// @route   DELETE /api/items/:id
// @access  Private/Admin
export const deleteItem = async (req: Request, res: Response): Promise<void> => {
  try {
    const item = await Item.findById(req.params.id);

    if (item) {
      await item.deleteOne();
      res.json({ message: 'Item removed' });
    } else {
      res.status(404).json({ message: 'Item not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};
"@
    Set-Content -Path "src/controllers/itemController.ts" -Value $itemControllerContent
    
    # Create auth middleware
    $authMiddlewareContent = @"
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/userModel';

interface JwtPayload {
  id: string;
}

export const protect = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  let token;

  // Check for token in headers
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as JwtPayload;

      // Get user from token
      (req as any).user = await User.findById(decoded.id).select('-password');

      next();
    } catch (error) {
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

export const admin = (req: Request, res: Response, next: NextFunction): void => {
  if ((req as any).user && (req as any).user.isAdmin) {
    next();
  } else {
    res.status(401).json({ message: 'Not authorized as an admin' });
  }
};
"@
    Set-Content -Path "src/middleware/authMiddleware.ts" -Value $authMiddlewareContent
    
    # Create error middleware
    $errorMiddlewareContent = @"
import { Request, Response, NextFunction } from 'express';

export const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction): void => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  
  res.status(statusCode).json({
    message: err.message,
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
};
"@
    Set-Content -Path "src/middleware/errorMiddleware.ts" -Value $errorMiddlewareContent
    
    # Create user routes
    $userRoutesContent = @"
import express from 'express';
import { registerUser, loginUser, getUserProfile } from '../controllers/userController';
import { protect } from '../middleware/authMiddleware';

const router = express.Router();

router.post('/', registerUser);
router.post('/login', loginUser);
router.get('/profile', protect, getUserProfile);

export default router;
"@
    Set-Content -Path "src/routes/userRoutes.ts" -Value $userRoutesContent
    
    # Create item routes
    $itemRoutesContent = @"
import express from 'express';
import { getItems, getItemById, createItem, updateItem, deleteItem } from '../controllers/itemController';
import { protect, admin } from '../middleware/authMiddleware';

const router = express.Router();

router.route('/')
  .get(getItems)
  .post(protect, admin, createItem);

router.route('/:id')
  .get(getItemById)
  .put(protect, admin, updateItem)
  .delete(protect, admin, deleteItem);

export default router;
"@
    Set-Content -Path "src/routes/itemRoutes.ts" -Value $itemRoutesContent
    
    # Create README.md
    $readmeContent = @"
# $ProjectName - Express.js Server

This is an Express.js project with TypeScript created with the ForgeMaster setup tool.

## Getting Started

1. Navigate to the project directory:
   ```
   cd $projectPath/$ProjectName
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up environment variables:
   - Copy .env.example to .env
   - Update the values as needed

4. Start the development server:
   ```
   npm run dev
   ```

5. Build for production:
   ```
   npm run build
   ```

6. Run in production:
   ```
   npm start
   ```

## Project Structure

- **src/controllers/**: Request handlers
- **src/models/**: Mongoose models
- **src/routes/**: API routes
- **src/middleware/**: Custom middleware
- **src/services/**: Business logic
- **src/utils/**: Utility functions
- **src/config/**: Configuration files
- **src/types/**: TypeScript type definitions
- **tests/**: Test files

## API Endpoints

### Users
- POST /api/users - Register a new user
- POST /api/users/login - Authenticate user
- GET /api/users/profile - Get user profile (protected)

### Items
- GET /api/items - Get all items
- GET /api/items/:id - Get item by ID
- POST /api/items - Create a new item (admin only)
- PUT /api/items/:id - Update an item (admin only)
- DELETE /api/items/:id - Delete an item (admin only)

## Features

- TypeScript support
- MongoDB with Mongoose
- JWT Authentication
- Error handling middleware
- Environment variable configuration
- Testing with Jest
"@
    Set-Content -Path "README.md" -Value $readmeContent
    
    Write-Host "Express.js server project '$ProjectName' created successfully!" -ForegroundColor Green
    
} finally {
    # Return to the original directory
    Pop-Location
} 