import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';

class UserMarkerUtils {
  static const Map<String, String> _schoolMarkerAssets = {
    'yangdong': 'assets/images/yangdong_pfp.png',
    'daegu-gongsan': 'assets/images/daegu_gongsan_pfp.png',
    'jungheung': 'assets/images/jungheung_pfp.png',
    'nam-samsung': 'assets/images/nam_samsung_pfp.png',
    'posan': 'assets/images/posan_pfp.png',
  };

  static final Map<String, BitmapDescriptor> _iconCache = {};

  static Future<BitmapDescriptor> _loadBitmapDescriptor(String assetPath, {int width = 50}) async {
    final byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw Exception('Failed to convert image to bytes');
    return BitmapDescriptor.bytes(data.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getUserMarkerIcon(AppUser user) async {
    final schoolId = user.joinedSchoolId?.toLowerCase() ?? '';
    if (_iconCache.containsKey(schoolId)) {
      return _iconCache[schoolId]!;
    }

    try {
      final assetPath =
          _schoolMarkerAssets[schoolId] ?? 'assets/images/climagame_user.png';
      final descriptor =
          await _loadBitmapDescriptor(assetPath, width: 50);
      _iconCache[schoolId] = descriptor;
      return descriptor;
    } catch (e) {
      debugPrint('Error loading bitmap for $schoolId: $e');
      final fallback = await _loadBitmapDescriptor('assets/images/climagame_user.png', width: 50);
      _iconCache[schoolId] = fallback;
      return fallback;
    }
  }

  static void clearCache() => _iconCache.clear();
  static List<String> getAvailableSchoolIds() => _schoolMarkerAssets.keys.toList();
  static bool hasCustomMarker(String schoolId) =>
      _schoolMarkerAssets.containsKey(schoolId.toLowerCase());
}

class UserMap extends StatefulWidget {
  final AppUser user;
  final LatLng userPosition;

  const UserMap({required this.user, required this.userPosition, Key? key}) : super(key: key);

  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  BitmapDescriptor? _userIcon;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initUserIconAndMarker();
  }

  Future<void> _initUserIconAndMarker() async {
    final icon = await UserMarkerUtils.getUserMarkerIcon(widget.user);
    setState(() {
      _userIcon = icon;
      _markers.add(
        Marker(
          markerId: MarkerId(widget.user.id),
          position: widget.userPosition,
          icon: _userIcon!,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: widget.userPosition, zoom: 15),
      markers: _userIcon != null ? _markers : {},

    );
  }
}
