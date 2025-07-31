import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../utils/supabase_config.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Upload profile picture
  static Future<String?> uploadProfilePicture({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      String imageUrl;
      
      if (imageFile != null) {
        imageUrl = await SupabaseImageService.uploadImage(
          imageFile: imageFile,
          folder: 'profile-pictures',
          customFileName: '$userId.jpg',
        );
      } else if (imageBytes != null) {
        imageUrl = await SupabaseImageService.uploadImageFromBytes(
          imageBytes: imageBytes,
          folder: 'profile-pictures',
          customFileName: '$userId.jpg',
        );
      } else {
        throw Exception('No image provided');
      }
      
      return imageUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }
  
  /// Upload post image
  static Future<String?> uploadPostImage({
    required String postId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      String imageUrl;
      
      if (imageFile != null) {
        imageUrl = await SupabaseImageService.uploadImage(
          imageFile: imageFile,
          folder: 'post-images',
          customFileName: '$postId.jpg',
        );
      } else if (imageBytes != null) {
        imageUrl = await SupabaseImageService.uploadImageFromBytes(
          imageBytes: imageBytes,
          folder: 'post-images',
          customFileName: '$postId.jpg',
        );
      } else {
        throw Exception('No image provided');
      }
      
      return imageUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      rethrow;
    }
  }
  
  /// Upload mission proof image
  static Future<String?> uploadMissionProofImage({
    required String missionId,
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      String imageUrl;
      
      if (imageFile != null) {
        imageUrl = await SupabaseImageService.uploadImage(
          imageFile: imageFile,
          folder: 'mission-proofs/$missionId',
          customFileName: '$userId.jpg',
        );
      } else if (imageBytes != null) {
        imageUrl = await SupabaseImageService.uploadImageFromBytes(
          imageBytes: imageBytes,
          folder: 'mission-proofs/$missionId',
          customFileName: '$userId.jpg',
        );
      } else {
        throw Exception('No image provided');
      }
      
      return imageUrl;
    } catch (e) {
      print('Error uploading mission proof image: $e');
      rethrow;
    }
  }
  
  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }
  
  /// Take photo with camera
  static Future<Uint8List?> takePhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      
      if (photo != null) {
        return await photo.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      rethrow;
    }
  }
  
  /// Delete image from Supabase
  static Future<void> deleteImage(String imageUrl) async {
    try {
      await SupabaseImageService.deleteImage(imageUrl);
    } catch (e) {
      print('Error deleting image: $e');
      // Don't rethrow as this is not critical
    }
  }
  
  /// Validate image file
  static bool isValidImageFile(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = file.path.split('.').last.toLowerCase();
    return validExtensions.contains('.$extension');
  }
  
  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
  
  /// Check if file size is acceptable (max 10MB)
  static bool isFileSizeAcceptable(File file) {
    return getFileSizeInMB(file) <= 10.0;
  }
} 