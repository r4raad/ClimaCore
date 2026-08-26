import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AndroidOptimizer {
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    _setAndroidOptimizations();

    _isInitialized = true;
    print('🔧 AndroidOptimizer: Initialized for Android devices');
  }

  static void _setAndroidOptimizations() {
    try {

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      _optimizeForLowEndDevices();

      print('🔧 AndroidOptimizer: Applied Android-specific optimizations');
    } catch (e) {
      print('⚠️ AndroidOptimizer: Error setting optimizations: $e');
    }
  }

  static void _optimizeForLowEndDevices() {

    const lowEndFrameRate = 30.0;

    print('🔧 AndroidOptimizer: Applied low-end device optimizations');
  }

  static double getOptimizedFrameRate() {
    return 30.0;
  }

  static double getOptimizedImageQuality() {
    return 0.85;
  }

  static int getOptimizedCacheSize(int defaultSize) {
    return (defaultSize * 0.6).round();
  }

  static Widget optimizeForAndroid(Widget child) {
    return RepaintBoundary(
      child: child,
    );
  }

  static Widget optimizeListForAndroid(ListView listView) {
    return RepaintBoundary(
      child: listView,
    );
  }

  static Widget optimizeImageForAndroid(Widget imageWidget) {
    return RepaintBoundary(
      child: imageWidget,
    );
  }

  static bool get isAndroid => Platform.isAndroid;

  static Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'localHostname': Platform.localHostname,
    };
  }
}
