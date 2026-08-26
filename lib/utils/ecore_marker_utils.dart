import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EcoreMarkerUtils {
  static const Map<String, String> _ecoreAssets = {
    'before_conquering': 'icons/ecore_before_conquering.png',
    'after_conquering': 'icons/ecore_after_conquering.png',
    'cooldown': 'icons/ecore_after_conquering.png',
  };

  static final Map<String, BitmapDescriptor> _iconCache = {};

  static Future<BitmapDescriptor> getEcoreMarkerIcon(String state) async {
    try {

      if (_iconCache.containsKey(state)) {
        return _iconCache[state]!;
      }

      String assetPath = _ecoreAssets[state] ?? _ecoreAssets['before_conquering']!;
      print('🎯 Loading ecore marker for state: $state, asset: $assetPath');

      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(80, 80)),
        assetPath,
      );

      _iconCache[state] = icon;
      return icon;
    } catch (e) {
      print('❌ Error loading ecore marker for state $state: $e');

      BitmapDescriptor fallbackIcon;
      switch (state) {
        case 'before_conquering':
          fallbackIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          break;
        case 'after_conquering':
          fallbackIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          break;
        case 'cooldown':
          fallbackIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          break;
        default:
          fallbackIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }

      _iconCache[state] = fallbackIcon;
      return fallbackIcon;
    }
  }

  static void clearCache() {
    _iconCache.clear();
  }

  static String getEcoreState(bool isConquered, bool isInCoolingTime) {
    if (isInCoolingTime) return 'cooldown';
    if (isConquered) return 'after_conquering';
    return 'before_conquering';
  }
}