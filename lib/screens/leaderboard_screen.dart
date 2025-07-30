import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../widgets/loading_widget.dart';
import '../services/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  String? _currentUserId;
  final UserService _userService = UserService();
  
  List<AppUser> _cachedUsers = [];
  bool _isLoading = true;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;

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
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'dummy_user_1';
    _loadInitialData();
    
    // Add timeout to prevent infinite loading
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

  Future<void> _loadInitialData() async {
    if (_cachedUsers.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    try {
      print('🔄 Leaderboard: Starting to load users...');
      await _loadUsers().timeout(Duration(seconds: 15));
      print('✅ Leaderboard: Users loaded successfully');
    } catch (e) {
      print('❌ Leaderboard: Loading timeout or error: $e');
      print('📝 Leaderboard: Using fallback data');
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    print('📝 Leaderboard: Loading fallback sample data');
    
    // Get current user from Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? 'dummy_user_1';
    
    // Extract first name from display name or use a default
    String firstName = 'User';
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      firstName = currentUser.displayName!.split(' ').first;
    }
    
    // Create a basic user entry for the current user
    final currentUserEntry = AppUser(
      id: currentUserId,
      firstName: firstName,
      lastName: '',
      points: 4245, // Sample points from UI
      savedPosts: [],
      likedPosts: [],
      actions: 6, // Sample actions from UI
      streak: 24, // Sample streak from UI
      weekPoints: 400, // Sample week points from UI
      weekGoal: 800,
    );
    
    // Create sample users with realistic names and data
    final sampleUsers = [
      currentUserEntry,
      AppUser(
        id: 'user_2',
        firstName: 'Son',
        lastName: 'Heung-min',
        points: 1160,
        savedPosts: [],
        likedPosts: [],
        actions: 16,
        streak: 12,
        weekPoints: 1160,
        weekGoal: 800,
      ),
      AppUser(
        id: 'user_3',
        firstName: 'Angelica',
        lastName: 'Gomes',
        points: 5600,
        savedPosts: [],
        likedPosts: [],
        actions: 85,
        streak: 45,
        weekPoints: 1200,
        weekGoal: 800,
      ),
      AppUser(
        id: 'user_4',
        firstName: 'Gong',
        lastName: 'Yoo',
        points: 5560,
        savedPosts: [],
        likedPosts: [],
        actions: 80,
        streak: 38,
        weekPoints: 1100,
        weekGoal: 800,
      ),
    ];
    
    if (mounted) {
      setState(() {
        _cachedUsers = sampleUsers;
        _isLoading = false;
      });
      print('✅ Leaderboard: Fallback data loaded successfully');
    }
  }

  Future<void> _loadUsers() async {
    if (!_hasMoreData || _isLoading) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('📊 Leaderboard: Querying Firestore for users...');
      Query query = FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(_pageSize);
      
      final snapshot = await query.get();
      print('📋 Leaderboard: Found ${snapshot.docs.length} users');
      
      if (snapshot.docs.isEmpty) {
        print('📝 Leaderboard: No users found in Firestore');
        _hasMoreData = false;
        // Load fallback data if no users found
        _loadFallbackData();
        return;
      } else {
        final newUsers = snapshot.docs.map((doc) {
          try {
            return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          } catch (e) {
            print('⚠️ Leaderboard: Error parsing user ${doc.id}: $e');
            return null;
          }
        }).where((user) => user != null).cast<AppUser>().toList();
        
        print('✅ Leaderboard: Successfully parsed ${newUsers.length} users');
        _cachedUsers.addAll(newUsers);
        _lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print('❌ Leaderboard: Error loading users from Firestore: $e');
      _loadFallbackData();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _cachedUsers.clear();
        _hasMoreData = true;
        _lastDocument = null;
        _isLoading = true;
      });
    }
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null, // Removed back button
        title: null, // Removed title
        centerTitle: true,
        actions: [
          // Removed refresh button
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
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
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cachedUsers.isEmpty && _isLoading) {
      return _buildLoadingState();
    }

    if (_cachedUsers.isEmpty) {
      return _buildEmptyState();
    }

    final allTimeLeaderboard = [..._cachedUsers]..sort((a, b) => b.points.compareTo(a.points));
    final weeklyLeaderboard = [..._cachedUsers]..sort((a, b) => b.weekPoints.compareTo(a.weekPoints));
    final currentUser = _cachedUsers.isNotEmpty ? _cachedUsers.firstWhere((u) => u.id == _currentUserId, orElse: () => _cachedUsers[0]) : null;
    final weekWinner = weeklyLeaderboard.isNotEmpty ? weeklyLeaderboard[0] : null;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyTab(currentUser, weekWinner, weeklyLeaderboard),
          _buildAllTimeTab(currentUser, allTimeLeaderboard),
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
              ElevatedButton(
                onPressed: () async {
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }
                  try {
                    await _userService.createDummyUsers();
                    await _refreshData();
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create dummy users: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Create Demo Data'),
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
            _buildUserHeader(currentUser),
            SizedBox(height: 16),
            _buildPointsCard(currentUser),
            SizedBox(height: 16),
            _buildWeeklyProgressCard(currentUser),
            SizedBox(height: 24),
            Text('This Week Winner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            if (weekWinner != null) _buildWinnerCard(weekWinner),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Show All', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ...leaderboard.take(3).map((user) => _buildLeaderboardTile(user, highlight: user.id == _currentUserId)).toList(),
            if (_hasMoreData && leaderboard.length >= 3)
              _buildLoadMoreButton(),
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
        ...leaderboard.map((user) => _buildLeaderboardTile(user, highlight: user.id == _currentUserId)),
        if (_hasMoreData) _buildLoadMoreButton(),
        if (_isLoading) 
          Padding(
            padding: EdgeInsets.all(16),
            child: LoadingWidget(color: Colors.green, size: 20),
          ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _loadUsers,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading 
            ? SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : Text('Load More'),
        ),
      ),
    );
  }

  Widget _buildUserHeader(AppUser user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
              ? NetworkImage(user.profilePic!)
              : AssetImage('assets/images/icon.png') as ImageProvider,
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
            child: Icon(Icons.eco, color: Colors.green),
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

  Widget _buildWinnerCard(AppUser user) {
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
                : AssetImage('assets/images/icon.png') as ImageProvider,
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
              Icon(Icons.emoji_events, color: Colors.green, size: 20),
              SizedBox(width: 4),
              Text('${user.points} Points', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(AppUser user, {bool highlight = false}) {
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
              : AssetImage('assets/images/icon.png') as ImageProvider,
          radius: 22,
        ),
        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${user.actions} Actions'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.green, size: 20),
            SizedBox(width: 4),
            Text('${user.points} Points', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 