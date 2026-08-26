import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user.dart';
import '../widgets/loading_widget.dart';
import '../services/user_service.dart';
import '../constants.dart';
import '../utils/transitions.dart';

class LeaderboardScreen extends StatefulWidget {
  final AppUser user;

  const LeaderboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  String? _currentUserId;
  final UserService _userService = UserService();

  List<AppUser> _allTimeUsers = [];
  List<AppUser> _weeklyUsers = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadAllUsers();

    Future.delayed(Duration(seconds: 20), () {
      if (mounted && _isLoading) {
        print('⚠️ Leaderboard: Loading timeout, forcing fallback data');
        _loadFallbackData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    try {
      print('🔄 Leaderboard: Starting to load all users...');
      await _loadUsersFromFirestore().timeout(Duration(seconds: 15));
      print('✅ Leaderboard: Users loaded successfully');
    } catch (e) {
      print('❌ Leaderboard: Loading timeout or error: $e');
      print('📝 Leaderboard: Using fallback data');
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    print('📝 Leaderboard: Loading fallback data from Firestore...');

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? 'current_user';

    String firstName = 'User';
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      firstName = currentUser.displayName!.split(' ').first;
    }

    final currentUserEntry = AppUser(
      id: currentUserId,
      firstName: firstName,
      lastName: '',
      points: 0,
      savedPosts: [],
      likedPosts: [],
      actions: 0,
      streak: 0,
      weekPoints: 0,
      weekGoal: 800,
    );

    final sampleUsers = [currentUserEntry];

    if (mounted) {
      setState(() {
        _allTimeUsers = sampleUsers;
        _weeklyUsers = sampleUsers;
        _isLoading = false;
        _hasError = true;
      });
      print('✅ Leaderboard: Fallback data loaded successfully');
    }
  }

  Future<void> _loadUsersFromFirestore() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      print('📊 Leaderboard: Querying Firestore for all users...');

      Query query = FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true);

      final snapshot = await query.get();
      print('📋 Leaderboard: Found ${snapshot.docs.length} users');

      if (snapshot.docs.isEmpty) {
        print('📝 Leaderboard: No users found in Firestore');
        if (mounted) {
          setState(() {
            _allTimeUsers = [];
            _weeklyUsers = [];
            _isLoading = false;
            _hasError = true;
          });
        }
        return;
      }

      final allUsers = snapshot.docs.map((doc) {
        try {
          return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Leaderboard: Error parsing user ${doc.id}: $e');
          return null;
        }
      }).where((user) => user != null).cast<AppUser>().toList();

      print('✅ Leaderboard: Successfully parsed ${allUsers.length} users');

      final allTimeSorted = [...allUsers]..sort((a, b) => b.points.compareTo(a.points));
      final weeklySorted = [...allUsers]..sort((a, b) => b.weekPoints.compareTo(a.weekPoints));

      if (mounted) {
        setState(() {
          _allTimeUsers = allTimeSorted;
          _weeklyUsers = weeklySorted;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      print('❌ Leaderboard: Error loading users from Firestore: $e');
      _loadFallbackData();
      return;
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _allTimeUsers.clear();
        _weeklyUsers.clear();
        _isLoading = true;
        _hasError = false;
      });
    }
    await _loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        title: null,
        centerTitle: true,
        actions: [
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_allTimeUsers.isEmpty && _weeklyUsers.isEmpty) {
      return _buildEmptyState();
    }

    final currentUser = _allTimeUsers.isNotEmpty
        ? _allTimeUsers.firstWhere((u) => u.id == _currentUserId, orElse: () => _allTimeUsers[0])
        : null;
    final weekWinner = _weeklyUsers.isNotEmpty ? _weeklyUsers[0] : null;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (currentUser != null) ...[
                  _buildUserHeader(currentUser),
                  SizedBox(height: 16),
                  _buildPointsCard(currentUser),
                ],
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF2FDF6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.green,
              tabs: [
                Tab(text: 'Weekly'),
                Tab(text: 'All Time'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyTab(currentUser, weekWinner, _weeklyUsers),
                _buildAllTimeTab(currentUser, _allTimeUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading leaderboard...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('No leaderboard data available', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          SizedBox(height: 8),
          Text('No users have earned points yet', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
              SizedBox(width: 12),
              Text(
                'No users found in the leaderboard.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(AppUser? currentUser, AppUser? weekWinner, List<AppUser> leaderboard) {
    if (currentUser == null) return _buildEmptyState();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyProgressCard(currentUser),
            SizedBox(height: 24),
            Text('This Week Winner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            if (weekWinner != null) _buildWinnerCard(weekWinner, isWeekly: true),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Show All', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ...leaderboard.take(20).map((user) => _buildLeaderboardTile(user, highlight: user.id == _currentUserId, isWeekly: true)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeTab(AppUser? currentUser, List<AppUser> leaderboard) {
    if (currentUser == null) return _buildEmptyState();
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ...leaderboard.take(20).map((user) => _buildLeaderboardTile(user, highlight: user.id == _currentUserId, isWeekly: false)),
      ],
    );
  }

  Widget _buildUserHeader(AppUser user) {
    return Row(
      children: [
        user.profilePic != null && user.profilePic!.isNotEmpty
            ? CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.profilePic!),
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
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user.displayName}👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text(_getCurrentDate(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ],
    );
  }

  String _getUserFirstName(AppUser user) {
    return user.displayName;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildPointsCard(AppUser user) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF00C853),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'icons/green_points.svg',
              width: 24,
              height: 24,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Green Points', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text('${user.points} pts.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          Spacer(),
          Column(
            children: [
              Text('${user.streak}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                  SizedBox(width: 4),
                  Text('Streaks Days', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(AppUser user) {
    double progress = user.weekGoal > 0 ? user.weekPoints / user.weekGoal : 0;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF2FDF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Actions: ${user.actions}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('This week points', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text('Keep participating in weekly challenges', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.green[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 8,
                ),
              ),
              Text('${user.weekPoints}/${user.weekGoal}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(AppUser user, {bool isWeekly = false}) {
    final points = isWeekly ? user.weekPoints : user.points;
    final pointsLabel = isWeekly ? 'Week Points' : 'Points';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                ? NetworkImage(user.profilePic!)
                : AssetImage(AppConstants.defaultProfilePicPath) as ImageProvider,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('${user.actions} Actions', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'icons/green_points.svg',
                width: 20,
                height: 20,
              ),
              SizedBox(width: 4),
              Text('$points $pointsLabel', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(AppUser user, {bool highlight = false, bool isWeekly = false}) {
    final points = isWeekly ? user.weekPoints : user.points;
    final pointsLabel = isWeekly ? 'Week Points' : 'Points';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: highlight ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? Border.all(color: Colors.green, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
              ? NetworkImage(user.profilePic!)
              : AssetImage(AppConstants.defaultProfilePicPath) as ImageProvider,
          radius: 22,
        ),
        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${user.actions} Actions'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'icons/green_points.svg',
              width: 20,
              height: 20,
            ),
            SizedBox(width: 4),
            Text('$points $pointsLabel', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}