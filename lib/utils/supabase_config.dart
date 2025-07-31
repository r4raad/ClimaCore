import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'env_config.dart';

class SupabaseConfig {
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}

class SupabaseImageService {
  static const String bucketName = 'climacore-images';
  
  /// Upload image to Supabase Storage
  static Future<String> uploadImage({
    required File imageFile,
    required String folder,
    String? customFileName,
  }) async {
    try {
      // Compress and resize image
      final compressedImage = await _compressImage(imageFile);
      
      // Generate unique filename
      final fileName = customFileName ?? '${Uuid().v4()}.jpg';
      final filePath = '$folder/$fileName';
      
      // Upload to Supabase Storage with better error handling
      try {
        await SupabaseConfig.client.storage
            .from(bucketName)
            .upload(filePath, compressedImage);
      } catch (e) {
        // If bucket doesn't exist, try to create it
        if (e.toString().contains('bucket') || e.toString().contains('not found')) {
          print('⚠️ Storage bucket not found, attempting to create...');
          // Note: Bucket creation requires admin privileges
          // For now, we'll use a fallback approach
          throw Exception('Storage bucket not configured. Please set up Supabase storage bucket: $bucketName');
        }
        rethrow;
      }
      
      // Get public URL
      final imageUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Upload image from bytes (for camera captures)
  static Future<String> uploadImageFromBytes({
    required Uint8List imageBytes,
    required String folder,
    String? customFileName,
  }) async {
    try {
      // Compress and resize image bytes
      final compressedBytes = await _compressImageBytes(imageBytes);
      
      // Generate unique filename
      final fileName = customFileName ?? '${Uuid().v4()}.jpg';
      final filePath = '$folder/$fileName';
      
      // Upload to Supabase Storage with better error handling
      try {
        await SupabaseConfig.client.storage
            .from(bucketName)
            .uploadBinary(filePath, compressedBytes);
      } catch (e) {
        // If bucket doesn't exist, try to create it
        if (e.toString().contains('bucket') || e.toString().contains('not found')) {
          print('⚠️ Storage bucket not found, attempting to create...');
          // Note: Bucket creation requires admin privileges
          // For now, we'll use a fallback approach
          throw Exception('Storage bucket not configured. Please set up Supabase storage bucket: $bucketName');
        }
        rethrow;
      }
      
      // Get public URL
      final imageUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Delete image from Supabase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.length - 2).join('/');
      
      await SupabaseConfig.client.storage
          .from(bucketName)
          .remove([filePath]);
    } catch (e) {
      print('Warning: Failed to delete image: $e');
    }
  }
  
  /// Compress and resize image file
  static Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final compressedBytes = await _compressImageBytes(bytes);
    
    // Create temporary file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedBytes);
    
    return tempFile;
  }
  
  /// Compress and resize image bytes
  static Future<Uint8List> _compressImageBytes(Uint8List imageBytes) async {
    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');
    
    // Resize image to max dimensions (1200x1200 for profile pics, 1600x1600 for posts)
    final maxWidth = 1600;
    final maxHeight = 1600;
    
    img.Image resizedImage;
    if (image.width > maxWidth || image.height > maxHeight) {
      resizedImage = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        interpolation: img.Interpolation.linear,
      );
    } else {
      resizedImage = image;
    }
    
    // Encode as JPEG with quality 85
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }
  
  /// Get image URL for different types
  static String getProfilePictureUrl(String userId) {
    return 'profile-pictures/$userId.jpg';
  }
  
  static String getPostImageUrl(String postId) {
    return 'post-images/$postId.jpg';
  }
  
  static String getMissionProofUrl(String missionId, String userId) {
    return 'mission-proofs/$missionId/$userId.jpg';
  }
} 