# Image URLs Configuration

This document explains how to update the image URLs for the advanced scrolling screens in the ClimaCore app.

## Screens with Advanced Scrolling

### 1. ClimaConnectScreen (`lib/screens/climaconnect_screen.dart`)

**Current placeholder:** `https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=ClimaConnect+Image`

**To update:**
1. Open `lib/screens/climaconnect_screen.dart`
2. Find line 28: `static const String _climaConnectImageUrl = '...'`
3. Replace the placeholder URL with your actual ClimaConnect image URL
4. The image will display "ClimaConnect" text overlay on top

**Recommended image specifications:**
- Aspect ratio: 2:1 (400x200 or similar)
- Format: JPG, PNG, or WebP
- Size: Optimized for web (under 500KB)
- Content: General ClimaConnect branding/theme

### 2. CommunityScreen (`lib/screens/community_screen.dart`)

**Current placeholder:** `https://via.placeholder.com/400x200/2196F3/FFFFFF?text=School+Image`

**To update:**
1. Open `lib/screens/community_screen.dart`
2. Find line 30: `static const String _schoolImageUrl = '...'`
3. Replace the placeholder URL with your actual school image URL
4. The image will display the school name as text overlay on top

**Recommended image specifications:**
- Aspect ratio: 2:1 (400x200 or similar)
- Format: JPG, PNG, or WebP
- Size: Optimized for web (under 500KB)
- Content: School-specific imagery (campus, logo, etc.)

## Advanced Scrolling Features

Both screens now feature:

1. **SliverAppBar with FlexibleSpaceBar**: Creates a collapsing app bar effect
2. **Parallax Scrolling**: Background image moves at different speed than content
3. **Text Overlays**: School names and titles with shadow effects for readability
4. **Gradient Overlays**: Subtle gradients for better text contrast
5. **Error Handling**: Fallback to gradient backgrounds if images fail to load
6. **Responsive Design**: Works on different screen sizes

## Implementation Details

- **Expanded Height**: 250.0 pixels for the app bar
- **Pinned**: App bar stays visible when scrolling
- **Background Colors**: Green for ClimaConnect, Blue for Community
- **Text Shadows**: Applied for better readability over images
- **Error Fallbacks**: Gradient backgrounds if images fail to load

## Testing

To test the image updates:
1. Replace the placeholder URLs with your actual image URLs
2. Run the app and navigate to the respective screens
3. Verify the images load correctly and text overlays are readable
4. Test on different screen sizes to ensure responsiveness

## Notes

- Images are loaded using `Image.network()` with error handling
- Text overlays use shadow effects for better contrast
- The scrolling experience is smooth and modern
- Both screens maintain their existing functionality while adding the visual enhancements 