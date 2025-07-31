# Supabase Setup Instructions

## Storage Bucket Setup

To fix the image upload error (`_Namespace` error), you need to create a storage bucket in your Supabase project:

1. **Go to your Supabase Dashboard**
   - Navigate to https://supabase.com/dashboard
   - Select your project

2. **Create Storage Bucket**
   - Go to "Storage" in the left sidebar
   - Click "Create a new bucket"
   - Name: `climacore-images`
   - Make it public (for image access)
   - Click "Create bucket"

3. **Set Bucket Permissions**
   - Go to "Storage" → "Policies"
   - Add policy for `climacore-images` bucket:
     - Policy name: `Allow public read access`
     - Operation: SELECT
     - Target roles: `anon`, `authenticated`
     - Policy definition: `true`

4. **Add Upload Policy**
   - Add another policy:
     - Policy name: `Allow authenticated uploads`
     - Operation: INSERT
     - Target roles: `authenticated`
     - Policy definition: `auth.role() = 'authenticated'`

## Environment Variables

Make sure your `.env` file contains:

```
SUPABASE_URL=https://url.supabase.co
SUPABASE_ANON_KEY=key
```

## Testing

After setting up the storage bucket, image uploads should work properly. Users will be able to:
- Upload profile pictures
- Upload post images  
- Upload mission proof images

**Default Profile Pictures**: Users who don't set a profile picture during registration will automatically have the ClimaCore logo as their default profile picture throughout the app. 