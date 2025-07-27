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
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_cachedUsers.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance.collection('users');
      
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      query = query.limit(_pageSize);
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        _hasMoreData = false;
      } else {
        final newUsers = snapshot.docs.map((doc) => 
          AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>)
        ).toList();
        
        _cachedUsers.addAll(newUsers);
        _lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print('Error loading users: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _cachedUsers.clear();
      _hasMoreData = true;
      _lastDocument = null;
      _isLoading = true;
    });
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _selectedTab == 1
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: _selectedTab == 1 ? Text('Leaderboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)) : null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
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
    return LoadingWidget(
      message: 'Loading leaderboard...',
      color: Colors.green,
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
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await _userService.createDummyUsers();
                    await _refreshData();
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
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
            Text('Hello, ${(user.name).split(' ')[0]}👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Sat, 31 May', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ],
    );
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
                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
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