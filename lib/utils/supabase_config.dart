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
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
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
      
      print('📤 Uploading image to Supabase: $filePath');
      
      // Upload to Supabase Storage
      await SupabaseConfig.client.storage
          .from(bucketName)
          .upload(filePath, compressedImage);
      
      // Get public URL
      final imageUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      print('✅ Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Supabase upload error: $e');
      
      // Check if bucket exists
      try {
        await SupabaseConfig.client.storage.listBuckets();
        print('✅ Buckets accessible');
      } catch (bucketError) {
        print('❌ Cannot access buckets: $bucketError');
        throw Exception('Supabase storage not accessible. Please check your Supabase project settings.');
      }
      
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
      
      print('📤 Uploading image bytes to Supabase: $filePath');
      
      // Upload to Supabase Storage
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(filePath, compressedBytes);
      
      // Get public URL
      final imageUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      print('✅ Image bytes uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Supabase upload error: $e');
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
      print('⚠️ Warning: Failed to delete image: $e');
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
    
    // Resize image to max dimensions
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