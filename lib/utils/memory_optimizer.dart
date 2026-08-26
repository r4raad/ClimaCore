import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

class MemoryOptimizer {
  static const int _maxImageCacheSize = 50 * 1024 * 1024;
  static const int _maxMemoryUsage = 200 * 1024 * 1024;
  static Timer? _memoryCheckTimer;

  static void initialize() {

    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = _maxImageCacheSize;

    _startMemoryMonitoring();

    print('🔧 MemoryOptimizer: Initialized with 50MB image cache limit');
  }

  static void _startMemoryMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  static void _checkMemoryUsage() {
    try {

      final imageCache = PaintingBinding.instance.imageCache;
      if (imageCache.currentSizeBytes > _maxImageCacheSize * 0.8) {
        print('🧹 MemoryOptimizer: Clearing image cache (${(imageCache.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB)');
        imageCache.clear();
        imageCache.clearLiveImages();
      }
    } catch (e) {
      print('⚠️ MemoryOptimizer: Error checking memory: $e');
    }
  }

  static void forceGarbageCollection() {
    try {

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      print('🧹 MemoryOptimizer: Forced garbage collection');
    } catch (e) {
      print('⚠️ MemoryOptimizer: Error during garbage collection: $e');
    }
  }

  static void optimizeForLowMemory() {
    try {

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      PaintingBinding.instance.imageCache.maximumSize = 500;
      PaintingBinding.instance.imageCache.maximumSizeBytes = _maxImageCacheSize ~/ 2;

      print('🔧 MemoryOptimizer: Optimized for low memory');
    } catch (e) {
      print('⚠️ MemoryOptimizer: Error optimizing for low memory: $e');
    }
  }

  static void dispose() {
    _memoryCheckTimer?.cancel();
    forceGarbageCollection();
  }
}
