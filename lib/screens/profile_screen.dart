import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../models/quiz.dart'; // Added import for Quiz and QuizProgress
import '../services/activity_service.dart';
import '../services/quiz_service.dart'; // Added import for QuizService
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import '../services/user_service.dart'; // Added import for UserService
import '../constants.dart'; // Added import for AppConstants

class ProfileScreen extends StatefulWidget {
  final AppUser user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _userActions = [];
  bool _isLoading = true;
  AppUser? _currentUser; // Add current user state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUser = widget.user; // Initialize with passed user
    _loadUserData(); // Load fresh user data
    _loadUserActions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when screen becomes visible
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch fresh user data from Firestore
      final userService = UserService();
      final freshUser = await userService.getUserById(widget.user.id);
      if (freshUser != null && mounted) {
        setState(() {
          _currentUser = freshUser;
        });
      }
    } catch (e) {
      print('❌ ProfileScreen: Error loading fresh user data: $e');
    }
  }

  Future<void> _loadUserActions() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      // Load user's recent activities and quiz submissions
      final results = await Future.wait([
        _loadUserActivities(),
        _loadUserQuizSubmissions(),
      ]);
      
      final activities = results[0] as List<Activity>;
      final quizSubmissions = results[1] as List<Map<String, dynamic>>;
      
      // Combine and sort by date
      final allActions = <Map<String, dynamic>>[];
      
      for (final activity in activities) {
        allActions.add({
          'type': 'Community Activity',
          'title': activity.title,
          'points': activity.points,
          'date': activity.date,
          'icon': Icons.people,
          'color': Colors.green,
        });
      }
      
      for (final quiz in quizSubmissions) {
        allActions.add({
          'type': 'Quiz',
          'title': quiz['title'],
          'points': quiz['points'],
          'date': quiz['date'],
          'icon': Icons.quiz,
          'color': Colors.blue,
        });
      }
      
      // Sort by date (most recent first)
      allActions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      if (mounted) {
        setState(() {
          _userActions = allActions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ProfileScreen: Error loading user actions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Activity>> _loadUserActivities() async {
    try {
      if (widget.user.joinedSchoolId != null) {
        // Fetch activities from the user's joined school
        final activities = await ActivityService().getActivities(widget.user.joinedSchoolId!);
        
        // In a real implementation, you would also check which activities the user has participated in
        // For now, we'll return recent activities from the school
        return activities.take(5).toList();
      }
      return [];
    } catch (e) {
      print('❌ ProfileScreen: Error loading user activities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadUserQuizSubmissions() async {
    try {
      // Fetch user's quiz progress from Firestore
      final userProgress = await QuizService.getUserQuizProgress(widget.user.id);
      
      final quizSubmissions = <Map<String, dynamic>>[];
      
      for (final progress in userProgress) {
        // Get quiz details for each progress entry
        final quiz = await QuizService.getQuizById(progress.quizId);
        if (quiz != null) {
          final score = (progress.correctAnswers / progress.totalQuestions * 100).round();
          int pointsEarned = 0;
          
          // Calculate points based on performance
          if (score >= 90) {
            pointsEarned = quiz.points;
          } else if (score >= 70) {
            pointsEarned = (quiz.points * 0.8).round();
          } else if (score >= 50) {
            pointsEarned = (quiz.points * 0.5).round();
          }
          
          quizSubmissions.add({
            'title': quiz.title,
            'points': pointsEarned,
            'date': progress.completedAt ?? DateTime.now(),
            'score': score,
          });
        }
      }
      
      return quizSubmissions;
    } catch (e) {
      print('❌ ProfileScreen: Error loading user quiz submissions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Profile',
          style: GoogleFonts.questrial(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _loadUserActions();
        },
        child: Column(
          children: [
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActionsTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _currentUser ?? widget.user; // Use current user or fallback to widget user
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: user),
                ),
              );
              
              // If profile was updated, refresh the user data
              if (result == true) {
                _loadUserData();
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundImage: user.profilePic?.isNotEmpty == true
                        ? NetworkImage(user.profilePic!)
                        : const AssetImage(AppConstants.appLogoPath) as ImageProvider,
                  ),
                ),
                // Edit Icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: GoogleFonts.questrial(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(
                      value: '${user.points}',
                      label: 'Green Points',
                      icon: Icons.emoji_events,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 20),
                    _buildStatItem(
                      value: '${user.streak}',
                      label: 'Streak Days',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.questrial(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              label,
              style: GoogleFonts.questrial(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Actions'),
          Tab(text: 'Stats'),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_userActions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Actions Yet',
              style: GoogleFonts.questrial(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete activities and quizzes to see your history',
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _userActions.length,
      itemBuilder: (context, index) {
        final action = _userActions[index];
        final date = action['date'] as DateTime;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: action['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['title'] as String,
                      style: GoogleFonts.questrial(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action['type'] as String,
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${action['points']} points',
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(date),
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final user = _currentUser ?? widget.user; // Use current user or fallback to widget user
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Points
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${user.points}',
                  style: GoogleFonts.questrial(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'pts.',
                  style: GoogleFonts.questrial(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Points Graph (Simplified)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points Progress',
                  style: GoogleFonts.questrial(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildPointsGraph(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Active Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Actions',
                style: GoogleFonts.questrial(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Show',
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: user.weekGoal > 0 ? (user.weekPoints / user.weekGoal).clamp(0.0, 1.0) : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '${user.weekPoints}',
                  label: 'Last 7 days',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${user.points}',
                  label: 'All time',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${(user.points / 100).round()}',
                  label: 'Average',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsGraph() {
    // Use real user data for the graph
    final user = _currentUser ?? widget.user;
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: PointsGraphPainter(userPoints: user.points.toDouble(), weekPoints: user.weekPoints.toDouble()),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.questrial(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.questrial(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

class PointsGraphPainter extends CustomPainter {
  final double userPoints;
  final double weekPoints;

  PointsGraphPainter({required this.userPoints, required this.weekPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Generate points based on user data
    final maxPoints = userPoints > 0 ? userPoints : 100.0; // Fallback if no points
    final points = [
      Offset(0, size.height * 0.8), // Start point
      Offset(size.width * 0.2, size.height * (0.8 - (weekPoints / maxPoints) * 0.3)),
      Offset(size.width * 0.4, size.height * (0.8 - (userPoints * 0.3 / maxPoints))),
      Offset(size.width * 0.6, size.height * (0.8 - (userPoints * 0.5 / maxPoints))),
      Offset(size.width * 0.8, size.height * (0.8 - (userPoints * 0.7 / maxPoints))),
      Offset(size.width, size.height * (0.8 - (userPoints / maxPoints))),
    ];

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.green);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 