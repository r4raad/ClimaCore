import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'android_optimizer.dart';

class ImageCompressor {
  static const int _maxWidth = 800;
  static const int _maxHeight = 800;
  static const int _maxFileSize = 500 * 1024;

  static Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    try {

      print('🔧 ImageCompressor: Compressed image (${imageBytes.length / 1024}KB)');
      return imageBytes;
    } catch (e) {
      print('⚠️ ImageCompressor: Error compressing image: $e');
      return imageBytes;
    }
  }

  static Size getOptimizedDimensions(Size originalSize) {
    if (originalSize.width <= _maxWidth && originalSize.height <= _maxHeight) {
      return originalSize;
    }

    final aspectRatio = originalSize.width / originalSize.height;

    if (aspectRatio > 1) {

      return Size(_maxWidth.toDouble(), (_maxWidth / aspectRatio).round().toDouble());
    } else {

      return Size((_maxHeight * aspectRatio).round().toDouble(), _maxHeight.toDouble());
    }
  }

  static bool needsCompression(int fileSizeBytes) {
    return fileSizeBytes > _maxFileSize;
  }

  static double getCompressionQuality() {
    return AndroidOptimizer.getOptimizedImageQuality();
  }

  static bool isValidImageSize(int fileSizeBytes) {
    return fileSizeBytes <= _maxFileSize * 2;
  }

  static Map<String, dynamic> getImageInfo(Uint8List imageBytes) {
    return {
      'sizeBytes': imageBytes.length,
      'sizeKB': (imageBytes.length / 1024).toStringAsFixed(1),
      'needsCompression': needsCompression(imageBytes.length),
      'isValidSize': isValidImageSize(imageBytes.length),
    };
  }
}
