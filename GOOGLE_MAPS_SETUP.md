# Google Maps API Setup Guide

## Current Issue
The Google Maps API is showing a `ProjectDeniedMapError` which means the API key doesn't have the proper permissions or the project is not properly configured.

## Fix Steps

### 1. Google Cloud Console Setup

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Select your project** or create a new one
3. **Enable the required APIs**:
   - Go to "APIs & Services" > "Library"
   - Search and enable these APIs:
     - **Maps JavaScript API**
     - **Places API**
     - **Geocoding API**

### 2. API Key Configuration

1. **Go to "APIs & Services" > "Credentials"**
2. **Create a new API key** or use your existing one: `AIzaSyDDbZHL7MXkEvcUF_n4z7mRFKsSUCq7-4Q`
3. **Restrict the API key** (recommended):
   - Click on your API key
   - Under "Application restrictions", select "HTTP referrers (web sites)"
   - Add these referrers:
     - `localhost:*`
     - `127.0.0.1:*`
     - Your domain (if deploying)
   - Under "API restrictions", select "Restrict key"
   - Select these APIs:
     - Maps JavaScript API
     - Places API
     - Geocoding API

### 3. Billing Setup (Required)

1. **Enable billing** for your Google Cloud project
2. **Set up a billing account** if you haven't already
3. **Google Maps API requires billing to be enabled** even for free tier usage

### 4. Alternative API Key (If Current One Doesn't Work)

If the current API key continues to have issues, you can:

1. **Create a new API key** in Google Cloud Console
2. **Replace the key** in these files:
   - `lib/utils/env_config.dart` (line 30)
   - `web/index.html` (line 25)
   - `android/app/src/main/AndroidManifest.xml` (line 33)

### 5. Testing the Fix

After completing the setup:

1. **Run the app**: `flutter run -d chrome`
2. **Navigate to ClimaGame** tab
3. **Check the browser console** for any remaining errors
4. **Test the map functionality**:
   - Map should load without errors
   - User location should be detected
   - Ecores should appear as markers

### 6. Common Issues and Solutions

#### Issue: "ProjectDeniedMapError"
**Solution**: Enable billing and ensure APIs are enabled

#### Issue: "API key not valid"
**Solution**: Check API key restrictions and ensure it's not restricted to specific domains

#### Issue: "Quota exceeded"
**Solution**: Check billing setup and usage limits

#### Issue: "Maps JavaScript API not enabled"
**Solution**: Enable the Maps JavaScript API in Google Cloud Console

### 7. Current Configuration Files

The API key is configured in these locations:

```dart
// lib/utils/env_config.dart
static String get googleMapsApiKey {
  return 'AIzaSyDDbZHL7MXkEvcUF_n4z7mRFKsSUCq7-4Q';
}
```

```html
<!-- web/index.html -->
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDDbZHL7MXkEvcUF_n4z7mRFKsSUCq7-4Q&libraries=places,marker&v=beta"></script>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyDDbZHL7MXkEvcUF_n4z7mRFKsSUCq7-4Q" />
```

### 8. Verification Steps

1. **Check Google Cloud Console**:
   - APIs are enabled
   - Billing is enabled
   - API key has proper restrictions

2. **Test in browser**:
   - Open browser console (F12)
   - Look for any Google Maps errors
   - Verify map loads correctly

3. **Test functionality**:
   - Map displays correctly
   - User location works
   - Markers appear
   - No console errors

## Quick Fix Summary

The main issue is likely that the Google Cloud project needs:
1. ✅ **Billing enabled**
2. ✅ **Maps JavaScript API enabled**
3. ✅ **Places API enabled**
4. ✅ **Proper API key restrictions**

Once these are configured, the `ProjectDeniedMapError` should be resolved and the map should work properly. 