import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/ecore.dart';
import '../models/user.dart';
import '../services/climagame_service.dart';
import '../widgets/ecore_mission_modal.dart';
import '../utils/ecore_marker_utils.dart';
import '../utils/user_marker_utils.dart';
import '../utils/android_map_optimizer.dart';
import 'climaconnect_screen.dart';

class ClimaGameScreen extends StatefulWidget {
  final AppUser user;

  const ClimaGameScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ClimaGameScreen> createState() => _ClimaGameScreenState();
}

class _ClimaGameScreenState extends State<ClimaGameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  GoogleMapController? _mapController;

  LatLng? _initialPosition;
  bool _mapInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _userDailyMissionCount = 0;
  bool _canDoMission = true;

  Set<Marker> _ecoreMarkers = {};
  Marker? _userMarker;
  List<Ecore> _visibleEcores = [];
  List<Map<String, dynamic>> _schoolRankings = [];

  StreamSubscription? _ecoresSubscription;
  StreamSubscription? _rankingsSubscription;
  Timer? _locationUpdateTimer;
  Timer? _debounceTimer;

  bool _isDisposed = false;
  DateTime? _lastLocationUpdate;
  DateTime? _lastEcoreUpdate;
  static const Duration _minLocationUpdateInterval = Duration(seconds: 15);
  static const Duration _minEcoreUpdateInterval = Duration(seconds: 5);

  Map<String, BitmapDescriptor> _markerIconCache = {};
  bool _isUpdatingMarkers = false;

  static const double _proximityThreshold = 100.0;
  static const Duration _locationUpdateInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _initialize();
  }

  void _initializeControllers() {
    try {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
        if (mounted && !_isDisposed) {
      setState(() {});
        }
      });
    } catch (e) {
      print('❌ Error initializing controllers: $e');
      _handleError('Failed to initialize screen components');
    }
  }

  Future<void> _initialize() async {
    if (_isDisposed) return;

    try {
    setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      if (widget.user.joinedSchoolId == null || widget.user.joinedSchoolId!.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
          _showJoinSchoolDialog();
          }
        });
        return;
      }

      await _setInitialPosition();
      await _loadData();
      await _checkUserMissionLimit();
      _setupRealTimeListeners();

      Future.delayed(Duration(seconds: 2), () {
        if (mounted && !_isDisposed) {
        _startLocationTracking();
        }
      });

      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error in initialization: $e');
      _handleError('Failed to initialize ClimaGame');
    }
  }

  void _handleError(String message) {
    if (mounted && !_isDisposed) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    try {
    _tabController.dispose();
    _mapController?.dispose();
    _ecoresSubscription?.cancel();
    _rankingsSubscription?.cancel();
    _locationUpdateTimer?.cancel();
      _debounceTimer?.cancel();

      _markerIconCache.clear();
    } catch (e) {
      print('❌ Error in dispose: $e');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _loadData();
        break;
      case AppLifecycleState.paused:
        _markerIconCache.clear();
        EcoreMarkerUtils.clearCache();
        UserMarkerUtils.clearCache();
        break;
      default:
        break;
    }
  }

  Future<void> _updateUserMarker(LatLng position) async {
    if (_isDisposed) return;

    try {
      print('📍 Updating user marker at position: ${position.latitude}, ${position.longitude}');

      final cacheKey = 'user_${widget.user.joinedSchoolId}';
      BitmapDescriptor userIcon;

      if (_markerIconCache.containsKey(cacheKey)) {
        userIcon = _markerIconCache[cacheKey]!;
      } else {
        userIcon = await UserMarkerUtils.getUserMarkerIcon(widget.user);
        _markerIconCache[cacheKey] = userIcon;
      }

      _userMarker = Marker(
        markerId: MarkerId('user_marker'),
        position: position,
        icon: userIcon,
        zIndex: 9999,
      );

      await _updateEcoreMarkers();
    } catch (e) {
      print('❌ Error updating user marker: $e');
    }

    setState(() {
      _ecoreMarkers.removeWhere((m) => m.markerId.value == 'user_marker');
      _ecoreMarkers.add(_userMarker!);
      _userMarker = _userMarker;
    });

  }

  Future<void> _setInitialPosition() async {
    if (_isDisposed) return;

    try {
      print('🗺️ Setting initial position...');
      if (!await _checkLocationPermission()) {
        print('❌ Location permission denied');
        _handleError('Location permission is required for ClimaGame');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print('✅ Got location: ${pos.latitude}, ${pos.longitude}');

      if (mounted && !_isDisposed) {
        setState(() {
          _initialPosition = LatLng(pos.latitude, pos.longitude);
          _mapInitialized = true;
        });
        await _updateUserMarker(_initialPosition!);
      }
    } catch (e) {
      print('❌ Error setting initial position: $e');
      _handleError('Failed to get your location. Please check location permissions.');
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      print('❌ Error checking location permission: $e');
      return false;
    }
  }

  void _startLocationTracking() {
    if (_isDisposed) return;

      _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) async {
      if (_isDisposed) return;

        try {
          await _followUserLocation();
          await _checkForUndiscoveredEcores();
        } catch (e) {
          print('❌ Error in location tracking: $e');
        }
      });
  }

  Future<void> _followUserLocation() async {
    if (_isDisposed) return;

    try {
      if (_lastLocationUpdate != null &&
          DateTime.now().difference(_lastLocationUpdate!) < _minLocationUpdateInterval) {
        return;
      }

      if (!await _checkLocationPermission()) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      _lastLocationUpdate = DateTime.now();

      if (mounted && !_isDisposed) {
        setState(() {
          _initialPosition = LatLng(pos.latitude, pos.longitude);
        });

        _mapController?.animateCamera(
          AndroidMapOptimizer.getOptimizedCameraUpdate(_initialPosition!),
        );
        await _updateUserMarker(_initialPosition!);
      }
    } catch (e) {
      print('❌ Error following user location: $e');
    }
  }

  Future<void> _checkForUndiscoveredEcores() async {
    if (_isDisposed || _initialPosition == null) return;

    try {
    final discovered = await ClimaGameService.checkAndDiscoverEcores(
      userId: widget.user.id,
      userLatitude: _initialPosition!.latitude,
      userLongitude: _initialPosition!.longitude,
      proximityThreshold: _proximityThreshold,
    );

    if (discovered.isNotEmpty) {
      for (final e in discovered) {
        _showEcoreDiscoveredNotification(e);
      }
      await _loadVisibleEcores();
      }
    } catch (e) {
      print('❌ Error checking for undiscovered ecores: $e');
    }
  }

  void _showEcoreDiscoveredNotification(Ecore ecore) {
    if (_isDisposed) return;

    try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 New Ecore Discovered: ${ecore.name}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _focusOnEcore(ecore),
        ),
      ),
    );
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  void _focusOnEcore(Ecore ecore) {
    try {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(ecore.latitude, ecore.longitude), 16.0),
    );
    } catch (e) {
      print('❌ Error focusing on ecore: $e');
    }
  }

  Future<void> _loadVisibleEcores() async {
    if (_isDisposed) return;

    try {
      if (_lastEcoreUpdate != null &&
          DateTime.now().difference(_lastEcoreUpdate!) < _minEcoreUpdateInterval) {
        return;
      }

      _lastEcoreUpdate = DateTime.now();

      final ecores = await ClimaGameService.getVisibleEcores();

      if (!mounted || _isDisposed) return;

      setState(() {
        _visibleEcores = ecores;
      });

      await _updateEcoreMarkers();
    } catch (e) {
      print('❌ Error loading visible ecores: $e');
    }
  }

  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      await Future.wait([
        _loadVisibleEcores(),
        _loadSchoolRankings()
      ]);
    } catch (e) {
      print('❌ Error loading data: $e');
      _handleError('Failed to load game data');
    }
  }

  Future<void> _loadSchoolRankings() async {
    if (_isDisposed) return;

    try {
      _schoolRankings = await ClimaGameService.getSchoolRankings();
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error loading school rankings: $e');
    }
  }

  Future<void> _updateEcoreMarkers() async {
    if (_isDisposed || _isUpdatingMarkers) return;

    try {
      _isUpdatingMarkers = true;
      final markers = <Marker>{};
      final markerConfig = AndroidMapOptimizer.getOptimizedMarkerConfig();
      final maxMarkers = markerConfig['maxMarkers'] as int;

      final limitedEcores = _visibleEcores.take(maxMarkers).toList();

      for (final ecore in limitedEcores) {
          final state = EcoreMarkerUtils.getEcoreState(ecore.isConquered, ecore.isInCoolingTime);
        final cacheKey = 'ecore_$state';

        BitmapDescriptor icon;
        if (_markerIconCache.containsKey(cacheKey)) {
          icon = _markerIconCache[cacheKey]!;
        } else {
          icon = await EcoreMarkerUtils.getEcoreMarkerIcon(state);
          _markerIconCache[cacheKey] = icon;
        }

          markers.add(Marker(
            markerId: MarkerId('ecore_${ecore.id}'),
            position: LatLng(ecore.latitude, ecore.longitude),
            icon: icon,
            onTap: () => _onEcoreTapped(ecore),
          ));
      }

      if (_userMarker != null) {
        markers.add(_userMarker!);
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _ecoreMarkers = markers;
        });
      }
    } catch (e) {
      print('❌ Error updating ecore markers: $e');
    } finally {
      _isUpdatingMarkers = false;
    }
  }

  void _onEcoreTapped(Ecore ecore) {
    if (_isDisposed) return;

    try {
    if (ecore.isInCoolingTime) {
      _showCoolingTimeDialog(ecore);
    } else if (ecore.isConquered) {
      _showConqueredDialog(ecore);
    } else {
      _showMissionModal(ecore);
      }
    } catch (e) {
      print('❌ Error handling ecore tap: $e');
    }
  }

  void _showCoolingTimeDialog(Ecore ecore) {
    if (_isDisposed) return;

    try {
    final remaining = ecore.coolingTimeEnd?.difference(DateTime.now()) ?? Duration.zero;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cooling Time'),
        content: Text('Time remaining: ${remaining.inMinutes}m ${remaining.inSeconds % 60}s'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
    } catch (e) {
      print('❌ Error showing cooling time dialog: $e');
    }
  }

  void _showConqueredDialog(Ecore ecore) {
    if (_isDisposed) return;

    try {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conquered Ecore'),
        content: Text('Conquered by ${ecore.conqueredBySchoolName} on ${ecore.conqueredAt}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
    } catch (e) {
      print('❌ Error showing conquered dialog: $e');
    }
  }

  void _showJoinSchoolDialog() {
    if (_isDisposed) return;

    try {
    showDialog(
      context: context,
        barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
              Icon(Icons.school, color: Colors.blue[600], size: 28),
            SizedBox(width: 12),
            Text(
              'Join a School',
              style: GoogleFonts.questrial(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To participate in ClimaGame, you need to join a school first.',
                style: GoogleFonts.questrial(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ClimaGame features are only available to students who have joined a participating school.',
                        style: GoogleFonts.questrial(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
              child: Text('Go Back', style: GoogleFonts.questrial(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          ),
                      ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClimaConnectScreen(user: widget.user),
                  ),
                );
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Join School', style: GoogleFonts.questrial(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    } catch (e) {
      print('❌ Error showing join school dialog: $e');
    }
  }

  void _showMissionModal(Ecore ecore) {
    if (_isDisposed) return;

    try {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EcoreMissionModal(
        ecore: ecore,
        user: widget.user,
        onMissionCompleted: () async {
          await _loadData();
          await _checkUserMissionLimit();
        },
      ),
    );
    } catch (e) {
      print('❌ Error showing mission modal: $e');
    }
  }

  Future<void> _checkUserMissionLimit() async {
    if (_isDisposed) return;

    try {
    _canDoMission = await ClimaGameService.canUserDoMission(widget.user.id);
    _userDailyMissionCount = await ClimaGameService.getUserDailyMissionCount(widget.user.id);
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error checking user mission limit: $e');
    }
  }

  void _setupRealTimeListeners() {
    if (_isDisposed) return;

    try {
      _ecoresSubscription = FirebaseFirestore.instance
          .collection('ecores')
          .where('isActive', isEqualTo: true)
          .where('isDiscovered', isEqualTo: true)
          .snapshots()
          .listen((_) {
            if (!_isDisposed) {
              _debounceTimer?.cancel();
              _debounceTimer = Timer(Duration(milliseconds: 500), () {
                if (!_isDisposed) {
                  _loadVisibleEcores();
                }
              });
            }
          });

      _rankingsSubscription =
          FirebaseFirestore.instance.collection('schools').snapshots().listen((_) {
            if (!_isDisposed) {
              _debounceTimer?.cancel();
              _debounceTimer = Timer(Duration(milliseconds: 1000), () {
                if (!_isDisposed) {
                  _loadSchoolRankings();
                }
              });
            }
          });
    } catch (e) {
      print('❌ Error setting up real-time listeners: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const Scaffold(body: SizedBox.shrink());
    }

    if (widget.user.joinedSchoolId == null || widget.user.joinedSchoolId!.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/climagame_header.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 64, color: Colors.blue[600]),
                    SizedBox(height: 16),
                    Text('Join a School', style: GoogleFonts.questrial(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    SizedBox(height: 12),
                    Text('To participate in ClimaGame, you need to join a school first.', textAlign: TextAlign.center, style: GoogleFonts.questrial(fontSize: 16, color: Colors.grey[600])),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClimaConnectScreen(user: widget.user),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Join School', style: GoogleFonts.questrial(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              SizedBox(height: 16),
              Text('Something went wrong', style: GoogleFonts.questrial(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              SizedBox(height: 8),
              Text(_errorMessage ?? 'Failed to load ClimaGame', textAlign: TextAlign.center, style: GoogleFonts.questrial(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _initialize();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Retry', style: GoogleFonts.questrial(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (!_mapInitialized || _initialPosition == null) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading ClimaGame...', style: GoogleFonts.questrial(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
                    children: [

          Container(
                          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0F8FF), Color(0xFFE6F3FF), Color(0xFFE8F5E8), Color(0xFFF0FFF0)],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text('ClimaGame', style: GoogleFonts.questrial(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 1.2)),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                    color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            child: TabBar(
                              controller: _tabController,
                    indicator: BoxDecoration(color: Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey[600],
                    labelStyle: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w500),
                    tabs: [Tab(text: 'Map'), Tab(text: 'Ranking')],
                  ),
                ),
                              ],
                            ),
                          ),

          Expanded(
            child: TabBarView(
          controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMapTab(),
            _buildRankingTab(),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    final mapConfig = AndroidMapOptimizer.getOptimizedMapConfig();

    return AndroidMapOptimizer.optimizeMapForAndroid(
      GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: mapConfig['myLocationEnabled'] as bool,
        myLocationButtonEnabled: mapConfig['myLocationButtonEnabled'] as bool,
        initialCameraPosition: AndroidMapOptimizer.getOptimizedCameraPosition(_initialPosition!),
        markers: _ecoreMarkers,
        zoomControlsEnabled: mapConfig['zoomControlsEnabled'] as bool,
        zoomGesturesEnabled: mapConfig['zoomGesturesEnabled'] as bool,
        scrollGesturesEnabled: mapConfig['scrollGesturesEnabled'] as bool,
        tiltGesturesEnabled: mapConfig['tiltGesturesEnabled'] as bool,
        rotateGesturesEnabled: mapConfig['rotateGesturesEnabled'] as bool,
        mapToolbarEnabled: mapConfig['mapToolbarEnabled'] as bool,
        compassEnabled: mapConfig['compassEnabled'] as bool,
        indoorViewEnabled: mapConfig['indoorViewEnabled'] as bool,
        trafficEnabled: mapConfig['trafficEnabled'] as bool,
        buildingsEnabled: mapConfig['buildingsEnabled'] as bool,
        mapType: mapConfig['mapType'] as MapType,
      ),
    );
  }

  Widget _buildRankingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Color(0xFFF5F7FA),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _schoolRankings.length,
        itemBuilder: (context, index) {
          final school = _schoolRankings[index];
          final conqueredCount = school['conqueredEcores'] ?? 0;
          final isTop3 = index < 3;
          final position = index + 1;

          Color getPositionColor() {
            switch (position) {
              case 1: return Color(0xFFFFD700);
              case 2: return Color(0xFFC0C0C0);
              case 3: return Color(0xFFCD7F32);
              default: return Color(0xFF1976D2);
            }
          }

          Color getCardColor() {
            switch (position) {
              case 1: return Color(0xFFFFFDF0);
              case 2: return Color(0xFFF8F8F8);
              case 3: return Color(0xFFFFF8F0);
              default: return Colors.white;
            }
          }

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getCardColor(),
              borderRadius: BorderRadius.circular(12),
              border: isTop3 ? Border.all(color: getPositionColor().withOpacity(0.3), width: 2) : null,
              boxShadow: [BoxShadow(color: isTop3 ? getPositionColor().withOpacity(0.15) : Colors.black.withOpacity(0.05), blurRadius: isTop3 ? 12 : 8, offset: Offset(0, isTop3 ? 4 : 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isTop3 ? getPositionColor() : Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isTop3 ? [BoxShadow(color: getPositionColor().withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))] : null,
                  ),
                  child: Center(
                    child: Text('${index + 1}', style: GoogleFonts.questrial(fontSize: 18, fontWeight: FontWeight.bold, color: isTop3 ? Colors.white : Color(0xFF1976D2))),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school['schoolName'] ?? 'Unknown School', style: GoogleFonts.questrial(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.2), width: 1),
                      ),
                      child: SvgPicture.asset(
                        'icons/green_points.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => Icon(Icons.eco, color: Color(0xFF4CAF50), size: 12),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Conquer $conqueredCount Core', style: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
