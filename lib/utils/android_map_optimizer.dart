import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class AndroidMapOptimizer {
  static bool _isLowEndDevice = false;
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    if (Platform.isAndroid) {
      _detectDeviceCapabilities();
      _setMapOptimizations();
    }

    _isInitialized = true;
    print('🔧 AndroidMapOptimizer: Initialized for ${_isLowEndDevice ? 'low-end' : 'high-end'} Android device');
  }

  static void _detectDeviceCapabilities() {
    try {

      _isLowEndDevice = true;

      print('📱 AndroidMapOptimizer: Device detected as ${_isLowEndDevice ? 'low-end' : 'high-end'}');
    } catch (e) {
      print('⚠️ AndroidMapOptimizer: Error detecting device: $e');
      _isLowEndDevice = true;
    }
  }

  static void _setMapOptimizations() {
    if (_isLowEndDevice) {
      print('🔧 AndroidMapOptimizer: Applied low-end device map optimizations');
    }
  }

  static MapType getOptimizedMapType() {
    return _isLowEndDevice ? MapType.normal : MapType.hybrid;
  }

  static CameraPosition getOptimizedCameraPosition(LatLng position, {double zoom = 15.0}) {
    return CameraPosition(
      target: position,
      zoom: _isLowEndDevice ? (zoom * 0.9) : zoom,
      tilt: _isLowEndDevice ? 0.0 : 45.0,
      bearing: 0.0,
    );
  }

  static Map<String, dynamic> getOptimizedMapConfig() {
    return {
      'myLocationEnabled': true,
      'myLocationButtonEnabled': true,
      'zoomControlsEnabled': _isLowEndDevice ? false : true,
      'zoomGesturesEnabled': true,
      'scrollGesturesEnabled': true,
      'tiltGesturesEnabled': !_isLowEndDevice,
      'rotateGesturesEnabled': !_isLowEndDevice,
      'mapToolbarEnabled': false,
      'compassEnabled': _isLowEndDevice ? false : true,
      'indoorViewEnabled': false,
      'trafficEnabled': false,
      'buildingsEnabled': !_isLowEndDevice,
      'mapType': getOptimizedMapType(),
    };
  }

  static Map<String, dynamic> getOptimizedMarkerConfig() {
    return {
      'maxMarkers': _isLowEndDevice ? 50 : 100,
      'markerClustering': _isLowEndDevice ? true : false,
      'markerAnimation': !_isLowEndDevice,
    };
  }

  static CameraUpdate getOptimizedCameraUpdate(LatLng position, {double zoom = 15.0}) {
    return CameraUpdate.newCameraPosition(
      getOptimizedCameraPosition(position, zoom: zoom),
    );
  }

  static bool get isLowEndDevice => _isLowEndDevice;

  static Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isLowEndDevice': _isLowEndDevice,
      'optimizations': getOptimizedMapConfig(),
    };
  }

  static Widget optimizeMapForAndroid(Widget mapWidget) {
    return RepaintBoundary(
      child: mapWidget,
    );
  }

  static List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    if (_isLowEndDevice) {
      recommendations.addAll([
        'Map type set to normal for better performance',
        '3D buildings disabled to reduce rendering load',
        'Tilt and rotate gestures disabled',
        'Compass disabled to reduce UI complexity',
        'Marker clustering enabled for better performance',
        'Marker animations disabled',
        'Indoor view disabled',
        'Traffic layer disabled',
      ]);
    }

    return recommendations;
  }
}
