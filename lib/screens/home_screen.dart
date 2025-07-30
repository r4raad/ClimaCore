
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../models/quiz.dart';
import '../services/activity_service.dart';
import '../services/quiz_service.dart';

import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'quiz_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Activity? _latestActivity;
  Quiz? _latestQuiz;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load latest activity and quiz
      final results = await Future.wait([
        _loadLatestActivity(),
        _loadLatestQuiz(),
      ]);
      
      setState(() {
        _latestActivity = results[0] as Activity?;
        _latestQuiz = results[1] as Quiz?;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error loading data: $e');
      setState(() => _isLoading = false);
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
        // Profile Picture with Notification Badge
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: widget.user),
              ),
            );
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
                child: CircleAvatar(
                  radius: 28,
                                backgroundImage: widget.user.profilePic?.isNotEmpty == true
                  ? NetworkImage(widget.user.profilePic!)
                  : const AssetImage('assets/images/icon.png') as ImageProvider,
                ),
              ),
              // Notification Badge
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
                // Navigate to full community activity list
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
                  color: Colors.black.withOpacity(0.1),
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
    return Container(
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
          // Activity Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green, Colors.lightGreen],
              ),
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 40,
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
          // Points Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
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
            color: Colors.black.withOpacity(0.1),
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
              title: 'Chat with',
              subtitle: 'ClimaAI',
              icon: Icons.chat,
              color: Colors.green,
              onTap: () => _openClimaAI(),
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
              color: Colors.black.withOpacity(0.1),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetailScreen(quiz: quiz),
      ),
    );
  }

  void _openClimaAI() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatScreen(user: widget.user),
      ),
    );
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
}
