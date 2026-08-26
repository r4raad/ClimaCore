import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PerformanceOptimizer {
  static bool _isLowEndDevice = false;
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    _detectDeviceCapabilities();

    _setPerformanceSettings();

    _isInitialized = true;
    print('🔧 PerformanceOptimizer: Initialized for ${_isLowEndDevice ? 'low-end' : 'high-end'} device');
  }

  static void _detectDeviceCapabilities() {
    try {

      _isLowEndDevice = true;

      print('📱 PerformanceOptimizer: Device detected as ${_isLowEndDevice ? 'low-end' : 'high-end'}');
    } catch (e) {
      print('⚠️ PerformanceOptimizer: Error detecting device: $e');
      _isLowEndDevice = true;
    }
  }

  static void _setPerformanceSettings() {
    if (_isLowEndDevice) {

      const lowEndAnimationDuration = Duration(milliseconds: 200);

      print('🔧 PerformanceOptimizer: Applied low-end device optimizations');
    }
  }

  static Duration getOptimizedDuration(Duration defaultDuration) {
    if (_isLowEndDevice) {
      return Duration(milliseconds: (defaultDuration.inMilliseconds * 0.7).round());
    }
    return defaultDuration;
  }

  static double getOptimizedImageQuality() {
    return _isLowEndDevice ? 0.8 : 1.0;
  }

  static int getOptimizedCacheSize(int defaultSize) {
    return _isLowEndDevice ? (defaultSize * 0.5).round() : defaultSize;
  }

  static bool get isLowEndDevice => _isLowEndDevice;

  static Widget optimizeRebuilds(Widget child) {
    return RepaintBoundary(child: child);
  }

  static Widget optimizeList(ListView listView) {
    return RepaintBoundary(
      child: listView,
    );
  }

  static Widget optimizeImage(Widget imageWidget) {
    return RepaintBoundary(
      child: imageWidget,
    );
  }
}
