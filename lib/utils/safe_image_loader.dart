import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'performance_optimizer.dart';

class SafeImageLoader {

  static Widget loadAssetImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return PerformanceOptimizer.optimizeImage(
      Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('❌ SafeImageLoader: Failed to load asset image: $assetPath');
          print('❌ Error: $error');
          return errorWidget ?? _buildDefaultErrorWidget();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: PerformanceOptimizer.getOptimizedDuration(const Duration(milliseconds: 300)),
            child: child,
          );
        },
      ),
    );
  }

  static Widget loadNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ SafeImageLoader: Failed to load network image: $imageUrl');
        print('❌ Error: $error');
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  static Widget loadMemoryImage({
    required Uint8List imageBytes,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.memory(
      imageBytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ SafeImageLoader: Failed to load memory image');
        print('❌ Error: $error');
        return errorWidget ?? _buildDefaultErrorWidget();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }

  static Widget loadImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {

    if (imageUrl.startsWith('assets/')) {
      return loadAssetImage(
        assetPath: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return loadNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    print('❌ SafeImageLoader: Unknown image format: $imageUrl');
    return errorWidget ?? _buildDefaultErrorWidget();
  }

  static Future<bool> validateImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ SafeImageLoader: Image file does not exist: $filePath');
        return false;
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        print('❌ SafeImageLoader: Image file too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ SafeImageLoader: Error validating image file: $e');
      return false;
    }
  }

  static Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  static Widget _buildDefaultLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }

  static Future<void> preloadImages(List<String> imageUrls, BuildContext context) async {
    for (final imageUrl in imageUrls) {
      try {
        if (imageUrl.startsWith('assets/')) {
          await precacheImage(AssetImage(imageUrl), context);
        } else if (imageUrl.startsWith('http')) {
          await precacheImage(NetworkImage(imageUrl), context);
        }
      } catch (e) {
        print('⚠️ SafeImageLoader: Failed to preload image: $imageUrl');
        print('⚠️ Error: $e');
      }
    }
  }
}
