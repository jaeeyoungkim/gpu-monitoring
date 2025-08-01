# GPU Monitoring Dashboard - Deployment Guide

This Flutter web application provides comprehensive GPU monitoring and management capabilities.

## Prerequisites

- Flutter SDK installed locally
- Vercel CLI installed: `npm i -g vercel`

## Deployment Steps

### 1. Build the Flutter Web App
```bash
flutter build web
```

### 2. Deploy to Vercel
```bash
vercel login
vercel --prod
```

## Build Configuration

The project includes a `vercel.json` configuration file that:
- Uses pre-built static files (no build commands on Vercel)
- Serves files from `build/web/`
- Handles client-side routing with proper rewrites

## Features

After deployment, the app will be available with all features:
- **GPU Inventory Management**: Department and user assignment tracking
- **Real-time Heatmap Visualization**: GPU usage trends and patterns
- **Scheduling Optimization Analysis**: Cost-saving recommendations
- **Custom Column Management**: Flexible data organization

## Troubleshooting

### "Command 'flutter pub get' exited with 127"
This error occurs because Vercel doesn't have Flutter installed. The solution is to:
1. Build the app locally using `flutter build web`
2. Use the included `vercel.json` that deploys pre-built files
3. Ensure `buildCommand` and `installCommand` are set to `null`

### Updating the App
When you make changes to the Flutter app:
1. Rebuild locally: `flutter build web`
2. Redeploy: `vercel --prod`

## Local Development

```bash
# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome --web-port=8080

# Build for production
flutter build web
```

## Project Structure

```
├── lib/
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   ├── utils/           # Utilities and constants
│   └── widgets/         # Reusable widgets
├── assets/              # Static assets
├── build/web/           # Built web files
└── pubspec.yaml         # Dependencies
```