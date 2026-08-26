import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class PerformanceMonitor {
  static Timer? _monitorTimer;
  static List<Map<String, dynamic>> _performanceLog = [];
  static bool _isMonitoring = false;

  static void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkPerformance();
    });

    print('🔍 PerformanceMonitor: Started monitoring');
  }

  static void stopMonitoring() {
    _isMonitoring = false;
    _monitorTimer?.cancel();
    print('🔍 PerformanceMonitor: Stopped monitoring');
  }

  static void _checkPerformance() {
    try {

      final imageCache = PaintingBinding.instance.imageCache;
      final cacheSize = imageCache.currentSizeBytes;
      final cacheSizeMB = cacheSize / 1024 / 1024;

      _performanceLog.add({
        'timestamp': DateTime.now().toIso8601String(),
        'imageCacheSizeMB': cacheSizeMB.toStringAsFixed(2),
        'imageCacheCount': imageCache.currentSize,
        'platform': Platform.operatingSystem,
      });

      if (_performanceLog.length > 50) {
        _performanceLog.removeAt(0);
      }

      if (cacheSizeMB > 40) {
        print('⚠️ PerformanceMonitor: High memory usage (${cacheSizeMB.toStringAsFixed(1)}MB)');
        _optimizeMemory();
      }

    } catch (e) {
      print('⚠️ PerformanceMonitor: Error checking performance: $e');
    }
  }

  static void _optimizeMemory() {
    try {

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      print('🧹 PerformanceMonitor: Cleared image cache');
    } catch (e) {
      print('⚠️ PerformanceMonitor: Error optimizing memory: $e');
    }
  }

  static Map<String, dynamic> getPerformanceStats() {
    if (_performanceLog.isEmpty) {
      return {
        'averageCacheSizeMB': 0.0,
        'maxCacheSizeMB': 0.0,
        'totalLogs': 0,
      };
    }

    final cacheSizes = _performanceLog
        .map((log) => double.tryParse(log['imageCacheSizeMB'] ?? '0') ?? 0.0)
        .toList();

    final average = cacheSizes.reduce((a, b) => a + b) / cacheSizes.length;
    final max = cacheSizes.reduce((a, b) => a > b ? a : b);

    return {
      'averageCacheSizeMB': average.toStringAsFixed(2),
      'maxCacheSizeMB': max.toStringAsFixed(2),
      'totalLogs': _performanceLog.length,
      'lastLog': _performanceLog.last,
    };
  }

  static Map<String, dynamic> getCurrentMemoryUsage() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      return {
        'imageCacheSizeMB': (imageCache.currentSizeBytes / 1024 / 1024).toStringAsFixed(2),
        'imageCacheCount': imageCache.currentSize,
        'maxCacheSize': (imageCache.maximumSizeBytes / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  static void clearLog() {
    _performanceLog.clear();
    print('🔍 PerformanceMonitor: Cleared performance log');
  }

  static void dispose() {
    stopMonitoring();
    clearLog();
  }
}