
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../models/quiz.dart';
import '../models/ecore.dart';
import '../models/school.dart';
import '../services/activity_service.dart';
import '../services/quiz_service.dart';
import '../services/climagame_service.dart';
import '../services/school_service.dart';
import '../utils/custom_marker_utils.dart';

import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'main_screen.dart';
import 'quiz_detail_screen.dart';
import 'activity_detail_screen.dart';
import 'climagame_screen.dart';
import 'climaconnect_screen.dart';

import '../constants.dart';
import '../utils/transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Activity? _latestActivity;
  Quiz? _latestQuiz;
  List<Ecore> _visibleEcores = [];
  Map<String, dynamic> _gameStats = {};
  Position? _currentPosition;
  bool _isLoading = true;
  bool _mapInitialized = false;

  final SchoolService _schoolService = SchoolService();
  School? _userSchool;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentLocation();
    _loadUserSchool();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final results = await Future.wait([
        _loadLatestActivity(),
        _loadLatestQuiz(),
        _loadGameData(),
      ]);

      if (mounted) {
        setState(() {
          _latestActivity = results[0] as Activity?;
          _latestQuiz = results[1] as Quiz?;
          _visibleEcores = results[2] as List<Ecore>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ HomeScreen: Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Activity?> _loadLatestActivity() async {
    try {
      if (widget.user.joinedSchoolId != null) {
        final activities = await ActivityService().getActivities(widget.user.joinedSchoolId!);
        return activities.isNotEmpty ? activities.first : null;
      }
      return null;
    } catch (e) {
      print('❌ HomeScreen: Error loading latest activity: $e');
      return null;
    }
  }

  Future<Quiz?> _loadLatestQuiz() async {
    try {
      final quizzes = await QuizService.getQuizzes();
      return quizzes.isNotEmpty ? quizzes.first : null;
    } catch (e) {
      print('❌ HomeScreen: Error loading latest quiz: $e');
      return null;
    }
  }

  Future<List<Ecore>> _loadGameData() async {
    try {
      final ecores = await ClimaGameService.getVisibleEcores();
      final conqueredCount = ecores.where((e) => e.isConquered).length;
      final inProgressCount = ecores.where((e) => !e.isConquered && !e.isInCoolingTime).length;

      if (mounted) {
        setState(() {
          _gameStats = {
            'conqueredEcores': conqueredCount,
            'inProgressEcores': inProgressCount,
            'totalEcores': ecores.length,
          };
        });
      }

      return ecores;
    } catch (e) {
      print('❌ HomeScreen: Error loading game data: $e');
      return [];
    }
  }

  Future<void> _loadUserSchool() async {
    try {
      if (widget.user.joinedSchoolId != null) {
        final school = await _schoolService.getSchoolById(widget.user.joinedSchoolId!);
        if (mounted) {
          setState(() {
            _userSchool = school;
          });
        }
      }
    } catch (e) {
      print('❌ HomeScreen: Error loading user school: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _mapInitialized = true;
        });
      }
    } catch (e) {
      print('❌ HomeScreen: Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildCoreMapSection(),
                  const SizedBox(height: 30),
                  _buildCommunityActivitySection(),
                  const SizedBox(height: 30),
                  _buildQuickAccessSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [

        GestureDetector(
          onTap: () {
            context.navigateWithSlideFromRight(ProfileScreen(user: widget.user));
          },
          child: Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: widget.user.profilePic?.isNotEmpty == true
                    ? CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(widget.user.profilePic!),
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[200],
                        child: SvgPicture.asset(
                          AppConstants.defaultProfilePicPath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) => Icon(
                            Icons.person,
                            size: 25,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
              ),

              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.user.displayName} 👋',
                style: GoogleFonts.questrial(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCurrentDate(),
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoreMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Map',
          style: GoogleFonts.questrial(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [

                                 if (_mapInitialized && _currentPosition != null)
                   FutureBuilder<Set<Marker>>(
                     future: _buildMapMarkers(),
                     builder: (context, snapshot) {
                       if (snapshot.hasData) {
                         return GoogleMap(
                           onMapCreated: (controller) {},
                           initialCameraPosition: CameraPosition(
                             target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                             zoom: 15.0,
                           ),
                                                       markers: snapshot.data!,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          );
                       } else {
                         return Container(
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                               colors: [Colors.green.shade100, Colors.green.shade50],
                             ),
                           ),
                           child: Center(
                             child: CircularProgressIndicator(
                               valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                             ),
                           ),
                         );
                       }
                     },
                   )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade100, Colors.green.shade50],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loading map...',
                            style: GoogleFonts.questrial(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                 Positioned(
                   top: 16,
                   left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                                    BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_gameStats['inProgressEcores'] ?? 0}/${_gameStats['totalEcores'] ?? 0} Games In-Progress',
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Continue The Game',
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cycle to School',
                          style: GoogleFonts.questrial(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_gameStats['conqueredEcores'] ?? 0} Cores Conquered',
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      context.navigateWithSlideFromRight(ClimaGameScreen(user: widget.user));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                                                     BoxShadow(
                             color: Colors.green.withValues(alpha: 0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 2),
                           ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.questrial(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Set<Marker>> _buildMapMarkers() async {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      final customIcon = await CustomMarkerUtils.createUserMarkerBitmap(
        widget.user,
        _userSchool,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'Tap to view details',
          ),
        ),
      );
    }

    for (final ecore in _visibleEcores.take(3)) {
      markers.add(
        Marker(
          markerId: MarkerId(ecore.id),
          position: LatLng(ecore.latitude, ecore.longitude),
          icon: _getEcoreMarkerIcon(ecore),
          infoWindow: InfoWindow(
            title: ecore.name,
            snippet: ecore.isConquered ? 'Conquered' : 'Available',
          ),
        ),
      );
    }

    return markers;
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

  Widget _buildCommunityActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Activity',
              style: GoogleFonts.questrial(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {

              },
              child: Text(
                'See All',
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
                          boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          )
        else if (_latestActivity != null)
          _buildActivityCard(_latestActivity!)
        else
          _buildEmptyActivityCard(),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return GestureDetector(
      onTap: () {
        if (widget.user.joinedSchoolId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(
                activity: activity,
                user: widget.user,
                schoolId: widget.user.joinedSchoolId!,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildActivityImage(activity),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.type,
                    style: GoogleFonts.questrial(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.title,
                    style: GoogleFonts.questrial(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.participantCount} Participants',
                        style: GoogleFonts.questrial(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatDate(activity.date),
                        style: GoogleFonts.questrial(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'icons/green_points.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity.points}',
                    style: GoogleFonts.questrial(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.people_outline,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Community Activities',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Join a school to see community activities',
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: GoogleFonts.questrial(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildQuickAccessCard(
              title: 'New Quiz',
              subtitle: _latestQuiz?.title ?? 'No Quiz Available',
              icon: Icons.quiz,
              color: Colors.green,
              onTap: _latestQuiz != null ? () => _openQuiz(_latestQuiz!) : null,
            ),
            _buildQuickAccessCard(
              title: 'Clima Games',
              subtitle: 'School Rank',
              icon: Icons.games,
              color: Colors.red,
              onTap: () => _openClimaGames(),
            ),
            _buildQuickAccessCard(
              title: 'Chat with',
              subtitle: 'ClimaAI',
              icon: Icons.chat,
              color: Colors.green,
              onTap: () => _openClimaAI(),
            ),
            _buildQuickAccessCard(
              title: 'ClimaConnect',
              subtitle: 'Community Posts',
              icon: Icons.people,
              color: Colors.green,
              onTap: () => _openClimaConnect(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.questrial(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _openQuiz(Quiz quiz) {
    context.navigateWithCard(QuizDetailScreen(quiz: quiz));
  }

  void _openClimaAI() {
    context.navigateWithSlideFromBottom(AIChatScreen(user: widget.user));
  }

  void _openClimaGames() {

    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState.onItemTapped(3);
    }
  }

  void _openClimaConnect() {
    context.navigateWithSlideFromRight(ClimaConnectScreen(user: widget.user));
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Widget _buildActivityImage(Activity activity) {
    if (activity.imageUrl == null || activity.imageUrl!.isEmpty) {

      return Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.event,
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }

            if (activity.imageUrl!.startsWith('assets/images/')) {
          return Image.asset(
            activity.imageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey[400],
            ),
          );
        },
      );
    }

    if (activity.imageUrl!.startsWith('http://') || activity.imageUrl!.startsWith('https://')) {
      return Image.network(
        activity.imageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey[400],
            ),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.event,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }
}
