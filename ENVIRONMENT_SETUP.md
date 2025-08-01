# Environment Setup Guide

## 🔐 Secure API Key Management

This project uses environment variables to keep API keys secure and prevent them from being exposed on GitHub.

## 📋 Setup Instructions

### 1. Create Environment File
Copy the example file and rename it to `.env`:
```bash
cp env.example .env
```

### 2. Configure Your API Keys
Edit the `.env` file with your actual API keys:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# News API Keys
NEWS_API_KEY=your_news_api_key_here
GNEWS_API_KEY=your_gnews_api_key_here

# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

**⚠️ IMPORTANT:** Replace all placeholder values with your actual API keys. Never commit the `.env` file to version control.

### 3. Security Features
- ✅ `.env` file is in `.gitignore` - won't be committed to GitHub
- ✅ API keys are loaded from environment variables
- ✅ Hardcoded keys removed from source code
- ✅ Template file (`env.example`) provided for easy setup

### 4. Platform-Specific Configuration

#### Web Platform
The Google Maps API key is automatically injected into `web/index.html` using the environment variable.

#### Android Platform
The Google Maps API key is automatically injected into `android/app/src/main/AndroidManifest.xml` using the environment variable.

### 5. Verification
After setup, the app will print:
```
✅ Environment variables loaded
✅ Supabase initialized successfully
```

## 🚨 Important Notes

1. **Never commit `.env` file** - It's already in `.gitignore`
2. **Keep your API keys secure** - Don't share them publicly
3. **Use different keys for development/production** - Consider using separate environment files
4. **Rotate keys regularly** - For security best practices

## 🔧 Troubleshooting

If you see errors about missing API keys:
1. Check that `.env` file exists in the project root
2. Verify all required environment variables are set
3. Restart the app after making changes to `.env`

## 📱 Deployment

For production deployment:
1. Set up environment variables in your hosting platform
2. Never include `.env` files in production builds
3. Use platform-specific environment variable management 