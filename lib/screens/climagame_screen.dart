import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ecore.dart';
import '../models/user.dart';
import '../services/climagame_service.dart';
import '../utils/env_config.dart';
import 'mission_detail_screen.dart';

class ClimaGameScreen extends StatefulWidget {
  final AppUser user;

  const ClimaGameScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ClimaGameScreen> createState() => _ClimaGameScreenState();
}

class _ClimaGameScreenState extends State<ClimaGameScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<Ecore> _ecores = [];
  List<Map<String, dynamic>> _schoolRankings = [];
  Map<String, dynamic> _gameStats = {};
  bool _isLoading = true;
  bool _hasError = false;
  bool _mapInitialized = false;
  
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  
  // Animation controllers
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {
        // _selectedTab = _tabController.index; // Removed unused field
      });
    });
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _initializeMap();
    _loadData();
    _getCurrentLocation();
    
    // Initialize comprehensive game if no data exists
    _initializeGameIfNeeded();
  }

  Future<void> _initializeMap() async {
    try {
      // Initialize Google Maps for web
      if (!EnvConfig.isGoogleMapsConfigured) {
        print('❌ Google Maps API key not configured');
        setState(() {
          _hasError = true;
        });
        return;
      }

      // Set up initial camera position
      final initialPosition = const LatLng(37.7749, -122.4194); // Default to San Francisco
      
      // Add a small delay to ensure Google Maps API is loaded
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _mapInitialized = true;
      });
      
      print('✅ Google Maps initialized successfully');
    } catch (e) {
      print('❌ Error initializing Google Maps: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final results = await Future.wait([
        ClimaGameService.getEcores(),
        ClimaGameService.getSchoolRankings(),
        ClimaGameService.getGameStats(),
      ]);

      if (mounted) {
        setState(() {
          _ecores = results[0] as List<Ecore>;
          _schoolRankings = results[1] as List<Map<String, dynamic>>;
          _gameStats = results[2] as Map<String, dynamic>;
          _isLoading = false;
        });
      }

      _createMapMarkers();
    } catch (e) {
      print('❌ ClimaGameScreen: Error loading data: $e');
      if (mounted) setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _initializeGameIfNeeded() async {
    try {
      // Check if game data exists
      final ecores = await ClimaGameService.getEcores();
      if (ecores.isEmpty) {
        print('🎮 No game data found, initializing comprehensive game...');
        await ClimaGameService.createComprehensiveSampleGame();
        // Reload data after initialization
        _loadData();
      }
    } catch (e) {
      print('❌ Error initializing game: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() {
        _currentPosition = position;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }
    } catch (e) {
      print('❌ Error getting current location: $e');
    }
  }

  void _createMapMarkers() {
    final markers = <Marker>{};
    
    // Add user marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: widget.user.displayName,
            snippet: widget.user.joinedSchoolId != null ? 'Team Member' : 'No Team',
          ),
        ),
      );
    }

    // Add ecore markers
    for (final ecore in _ecores) {
      final markerId = MarkerId('ecore_${ecore.id}');
      final position = LatLng(ecore.latitude, ecore.longitude);
      
      markers.add(
        Marker(
          markerId: markerId,
          position: position,
          icon: _getEcoreMarkerIcon(ecore),
          onTap: () => _showEcoreDetails(ecore),
        ),
      );
    }

    if (mounted) setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getEcoreMarkerIcon(Ecore ecore) {
    if (ecore.isConquered) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (ecore.isInCoolingTime) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _showEcoreDetails(Ecore ecore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEcoreModal(ecore),
    );
  }

  Widget _buildEcoreModal(Ecore ecore) {
    final completedMissions = ecore.missions.where((m) => m.isCompleted).length;
    final totalMissions = ecore.missions.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ecore.isConquered ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ecore.name,
                        style: GoogleFonts.questrial(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ecore.isConquered 
                            ? 'Conquered by ${ecore.conqueredBySchoolName}'
                            : '$completedMissions/$totalMissions missions completed',
                        style: GoogleFonts.questrial(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (ecore.isInCoolingTime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cooling',
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Missions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ecore.missions.length,
              itemBuilder: (context, index) {
                final mission = ecore.missions[index];
                return _buildMissionCard(mission, ecore);
              },
            ),
          ),
          
          // Close button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(EcoreMission mission, Ecore ecore) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mission.isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isCompleted ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mission.isCompleted ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.isCompleted ? Icons.check : Icons.eco,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission.points} points',
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!mission.isCompleted && ecore.canBeConquered)
            TextButton(
              onPressed: () => _openMissionDetail(mission, ecore),
              child: Text(
                'Start',
                style: GoogleFonts.questrial(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMissionDetail(EcoreMission mission, Ecore ecore) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MissionDetailScreen(
          mission: mission,
          ecore: ecore,
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green[100]!,
                    Colors.green[50]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ClimaGame',
                        style: GoogleFonts.questrial(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (_gameStats.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${_gameStats['currentSeason'] ?? 'Spring'} Season',
                            style: GoogleFonts.questrial(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: GoogleFonts.questrial(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: GoogleFonts.questrial(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Map'),
                        Tab(text: 'Ranking'),
                      ],
                    ),
                  ),
                  if (_gameStats.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Ecores', '${_gameStats['totalEcores'] ?? 0}'),
                        _buildStatItem('Missions', '${_gameStats['completedMissions'] ?? 0}/${_gameStats['totalMissions'] ?? 0}'),
                        _buildStatItem('Schools', '${_gameStats['activeSchools'] ?? 0}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMapView(),
                  _buildRankingView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_hasError || !_mapInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _hasError ? 'Failed to load map data' : 'Initializing map...',
              style: GoogleFonts.questrial(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeMap();
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            _createMapMarkers();
          },
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : const LatLng(37.7749, -122.4194),
            zoom: 15.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        
        // Legend
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Available', Colors.red),
                const SizedBox(height: 8),
                _buildLegendItem('Conquered', Colors.green),
                const SizedBox(height: 8),
                _buildLegendItem('Cooling', Colors.orange),
              ],
            ),
          ),
        ),
        

      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.questrial(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.questrial(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.questrial(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_schoolRankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No rankings yet',
              style: GoogleFonts.questrial(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete missions to see school rankings',
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _schoolRankings.length,
      itemBuilder: (context, index) {
        final ranking = _schoolRankings[index];
        return _buildRankingCard(ranking, index + 1);
      },
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> ranking, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: position <= 3 ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: position <= 3 ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // School info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking['schoolName'] ?? 'Unknown School',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conquer ${ranking['conqueredCount']} Core',
                  style: GoogleFonts.questrial(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Medal icon
          Icon(
            Icons.emoji_events,
            color: position <= 3 ? Colors.amber : Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }
} 