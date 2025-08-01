# Supabase Storage Setup Guide

This guide will help you set up Supabase storage for image uploads in ClimaCore.

## 🚨 Current Issue

The "_Namespace" error indicates that the Supabase storage bucket is not properly configured. This guide will walk you through the complete setup process.

## 📋 Prerequisites

1. **Supabase Account**: You need a Supabase account
2. **Project Created**: A Supabase project should be created
3. **API Keys**: Your project URL and anon key should be configured

## 🔧 Step-by-Step Setup

### Step 1: Access Your Supabase Dashboard

1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Select your project (or create a new one)

### Step 2: Create Storage Bucket

1. In your Supabase dashboard, navigate to **Storage** in the left sidebar
2. Click **Create a new bucket**
3. Configure the bucket:
   - **Name**: `climacore-images`
   - **Public bucket**: ✅ Check this option
   - **File size limit**: 50MB (or your preferred limit)
   - **Allowed MIME types**: `image/*`

### Step 3: Configure Storage Policies

1. After creating the bucket, click on it to access its settings
2. Go to the **Policies** tab
3. Click **New Policy**
4. Choose **Create a policy from scratch**
5. Configure the policy:

#### For Uploads (INSERT):
```sql
-- Policy name: "Allow authenticated uploads"
-- Target roles: authenticated
-- Using expression: true
```

#### For Downloads (SELECT):
```sql
-- Policy name: "Allow public downloads"
-- Target roles: anon, authenticated
-- Using expression: true
```

#### For Deletions (DELETE):
```sql
-- Policy name: "Allow authenticated deletions"
-- Target roles: authenticated
-- Using expression: true
```

### Step 4: Verify Configuration

1. Go to **Settings** → **API** in your Supabase dashboard
2. Copy your **Project URL** and **anon public** key
3. Verify these match the values in `lib/utils/env_config.dart`

### Step 5: Test the Setup

1. Run the app
2. Try to upload a profile picture
3. If successful, you should see the image URL in the console logs

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "_Namespace" Error
**Cause**: Storage bucket doesn't exist or isn't properly configured
**Solution**: 
1. Create the bucket as described above
2. Ensure the bucket name is exactly `climacore-images`
3. Make sure it's set as a public bucket

#### Issue 2: "Permission denied" Error
**Cause**: Storage policies are not configured correctly
**Solution**:
1. Check that the policies allow `anon` and `authenticated` roles
2. Ensure the policies are enabled
3. Verify the bucket is public

#### Issue 3: "Bucket not found" Error
**Cause**: Wrong bucket name or bucket doesn't exist
**Solution**:
1. Verify the bucket name is `climacore-images`
2. Create the bucket if it doesn't exist
3. Check that you're in the correct Supabase project

#### Issue 4: "File too large" Error
**Cause**: File size exceeds the bucket limit
**Solution**:
1. Increase the file size limit in bucket settings
2. Compress the image before uploading
3. Choose a smaller image

### Diagnostic Tools

The app includes diagnostic tools to help identify issues:

1. **Profile Picture Upload Screen**: Click the bug icon in the app bar
2. **Console Logs**: Check the detailed logs for specific error messages
3. **Error Dialogs**: The app shows detailed error information

## 📱 Testing the Setup

### Manual Test
1. Open the app
2. Go to Profile → Edit Profile
3. Tap the profile picture
4. Try uploading an image
5. Check the console for success/error messages

### Diagnostic Test
1. In the profile picture upload screen, tap the bug icon
2. Review the diagnostic report
3. Follow the recommended fixes

## 🔧 Advanced Configuration

### Custom Bucket Name
If you want to use a different bucket name:

1. Update the bucket name in `lib/utils/supabase_config.dart`:
```dart
static const String bucketName = 'your-custom-bucket-name';
```

2. Create the bucket with the same name in Supabase

### Custom Storage Policies
For more granular control, you can create custom policies:

```sql
-- Example: Only allow users to upload their own profile pictures
CREATE POLICY "Users can upload their own profile pictures"
ON storage.objects FOR INSERT
TO authenticated
USING (bucket_id = 'climacore-images' AND (storage.foldername(name))[1] = auth.uid()::text);
```

## 📞 Support

If you're still experiencing issues:

1. **Check the diagnostic report** in the app
2. **Review the console logs** for detailed error messages
3. **Verify your Supabase project settings**
4. **Ensure your internet connection is stable**

## 🎯 Success Indicators

You'll know the setup is working when:

1. ✅ Profile pictures upload successfully
2. ✅ No "_Namespace" errors in console
3. ✅ Image URLs are generated and stored
4. ✅ Images display correctly in the app
5. ✅ Diagnostic report shows all tests passing

## 🔄 Maintenance

### Regular Checks
- Monitor storage usage in Supabase dashboard
- Review and update storage policies as needed
- Keep Supabase SDK updated

### Backup Strategy
- Consider backing up important images
- Monitor storage costs
- Set up alerts for storage limits

---

**Note**: This setup is specifically for image uploads. The app uses Firebase for data storage and Supabase only for image storage, which is why the configuration is focused on Supabase storage buckets. 