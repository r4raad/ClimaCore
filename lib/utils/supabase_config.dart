import 'package:supabase_flutter/supabase_flutter.dart';
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

  static Future<String> uploadImage({
    required Uint8List imageBytes,
    required String folder,
    String? customFileName,
  }) async {
    try {

      final compressedBytes = await _compressImageBytes(imageBytes);

      final fileName = customFileName ?? '${Uuid().v4()}.jpg';
      final filePath = '$folder/$fileName';

      print('📤 Uploading image to Supabase: $filePath');

      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(filePath, compressedBytes);

      final imageUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('✅ Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Supabase upload error: $e');

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

  static Future<String> uploadImageFromBytes({
    required Uint8List imageBytes,
    required String folder,
    String? customFileName,
  }) async {
    return uploadImage(
      imageBytes: imageBytes,
      folder: folder,
      customFileName: customFileName,
    );
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {

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

  static Future<Uint8List> _compressImageBytes(Uint8List imageBytes) async {

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

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

    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }

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