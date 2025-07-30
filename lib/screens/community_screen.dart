import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/activity.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/activity_service.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';
import '../widgets/post_card.dart';
import '../widgets/activity_card.dart';
import 'create_post_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'comments_screen.dart';
import 'activity_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  final AppUser user;
  final String schoolId;

  const CommunityScreen({
    Key? key,
    required this.user,
    required this.schoolId,
  }) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  final PostService _postService = PostService();
  final ActivityService _activityService = ActivityService();
  final UserService _userService = UserService();
  final SchoolService _schoolService = SchoolService();

  List<PostWithUser> _posts = [];
  List<Activity> _activities = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _schoolName;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  static const double _expandedHeight = 250.0;
  static const double _collapsedHeight = kToolbarHeight;

  late AnimationController _centerTitleController;
  late AnimationController _leftTitleController;
  late AnimationController _backgroundController;
  late TabController _tabController;
  int _selectedTab = 0;

  static const String _schoolImageUrl = 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=School+Image';

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    
    _centerTitleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _leftTitleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadData();
    _loadSchoolName();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _centerTitleController.dispose();
    _leftTitleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final maxScroll = _expandedHeight - _collapsedHeight;
    final progress = (offset / maxScroll).clamp(0.0, 1.0);
    
    setState(() {
      _scrollOffset = offset;
    });
    
    _centerTitleController.value = 1.0 - progress;
    _leftTitleController.value = progress;
    _backgroundController.value = 1.0 - progress;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🔄 Community: Loading posts and activities for school ${widget.schoolId}');
      
      final results = await Future.wait([
        _postService.getPostsWithUserInfo(widget.schoolId),
        _activityService.getActivities(widget.schoolId),
      ]);

      final posts = results[0] as List<PostWithUser>;
      final activities = results[1] as List<Activity>;
      
      print('✅ Community: Loaded ${posts.length} posts and ${activities.length} activities');
      
      // If both lists are empty, load fallback data
      if (posts.isEmpty && activities.isEmpty) {
        print('📝 Community: No data found, loading fallback data');
        _loadFallbackData();
        return;
      }
      
      setState(() {
        _posts = posts;
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Community: Error loading data: $e');
      print('📝 Community: Loading fallback data');
      
      // Load fallback data instead of showing error
      _loadFallbackData();
    }
  }

  void _loadFallbackData() async {
    print('📝 Community: Loading fallback sample data');
    
    try {
      // Ensure dummy users exist first
      await _userService.ensureDummyUsersExist();
      
      // Create sample posts and activities
      await Future.wait([
        _postService.createSamplePosts(widget.schoolId),
        _activityService.createSampleActivities(widget.schoolId),
      ]);
      
      // Now load the newly created data
      final results = await Future.wait([
        _postService.getPostsWithUserInfo(widget.schoolId),
        _activityService.getActivities(widget.schoolId),
      ]);

      final posts = results[0] as List<PostWithUser>;
      final activities = results[1] as List<Activity>;
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _activities = activities;
          _isLoading = false;
        });
        print('✅ Community: Fallback data loaded successfully');
      }
    } catch (e) {
      print('❌ Community: Error loading fallback data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadSchoolName() async {
    try {
      print('🔄 Community: Loading school name for school ID: ${widget.schoolId}');
      final school = await _schoolService.getSchoolById(widget.schoolId);
      if (mounted) {
        setState(() {
          _schoolName = school?.name ?? 'Unknown School';
        });
        print('✅ Community: School name loaded: $_schoolName');
      }
    } catch (e) {
      print('❌ Community: Error loading school name: $e');
      if (mounted) {
        setState(() {
          _schoolName = 'Unknown School';
        });
      }
    }
  }

  String _getSchoolName() {
    return _schoolName ?? 'Loading...';
  }

  Future<void> _leaveSchool() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave School'),
        content: const Text('Are you sure you want to leave this school?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.joinSchool(widget.user.id, '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the school'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave school: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _expandedHeight,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue,
              automaticallyImplyLeading: false,
              leading: null,
              title: AnimatedBuilder(
                animation: _leftTitleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _leftTitleController.value,
                    child: Text(
                      _getSchoolName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxExtent = constraints.maxHeight;
                  final double minExtent = kToolbarHeight;
                  final double t = ((maxExtent - minExtent) / (_expandedHeight - _collapsedHeight)).clamp(0.0, 1.0);
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        opacity: t,
                        duration: const Duration(milliseconds: 200),
                        child: Image.network(
                          _schoolImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue, Colors.lightBlue],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: 0,
                        right: 0,
                        top: -40 * (1.0 - t),
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: t,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                _getSchoolName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: 16,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: 1.0 - t,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _getSchoolName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 1.1,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'leave') {
                      _leaveSchool();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'leave',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Leave School'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('Posts', 0),
                      _buildTabButton('Activities', 1),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: IndexedStack(
          index: _selectedTab,
          children: [
            _buildPostsTab(),
            _buildActivitiesTab(),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                      schoolId: widget.schoolId,
                      user: widget.user,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.questrial(
                color: isSelected ? Colors.white : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading community content...'),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load posts and activities.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_posts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recent Posts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
                             itemBuilder: (context, index) {
                 final postWithUser = _posts[index];
                 final post = postWithUser.post;
                 final liked = post.likes.contains(widget.user.id);
                 final saved = post.saves.contains(widget.user.id);
                 
                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                   child: PostCard(
                     postWithUser: postWithUser,
                     currentUser: widget.user,
                     liked: liked,
                     saved: saved,
                     onLike: () async {
                       try {
                         if (liked) {
                           await _postService.unlikePost(widget.schoolId, post.id, widget.user.id);
                         } else {
                           await _postService.likePost(widget.schoolId, post.id, widget.user.id);
                         }
                         _loadData();
                       } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Failed to ${liked ? 'unlike' : 'like'} post'), backgroundColor: Colors.red),
                         );
                       }
                     },
                     onSave: () async {
                       try {
                         if (saved) {
                           await _postService.unsavePost(widget.schoolId, post.id, widget.user.id);
                         } else {
                           await _postService.savePost(widget.schoolId, post.id, widget.user.id);
                         }
                         _loadData();
                       } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Failed to ${saved ? 'unsave' : 'save'} post'), backgroundColor: Colors.red),
                         );
                       }
                     },
                     onComment: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => CommentsScreen(
                             post: post,
                             currentUser: widget.user,
                             schoolId: widget.schoolId,
                           ),
                         ),
                       );
                     },
                     onDelete: () async {
                       try {
                         await _postService.deletePost(widget.schoolId, post.id);
                         _loadData();
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Post deleted successfully'),
                             backgroundColor: Colors.green,
                           ),
                         );
                       } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Failed to delete post'),
                             backgroundColor: Colors.red,
                           ),
                         );
                       }
                     },
                   ),
                 );
               },
            ),
          ],

          if (_posts.isEmpty)
            _buildEmptyState(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading community content...'),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load posts and activities.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activities.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activities.length,
                             itemBuilder: (context, index) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                   child: ActivityCard(
                     activity: _activities[index],
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => ActivityDetailScreen(
                             activity: _activities[index],
                             currentUser: widget.user,
                             schoolId: widget.schoolId,
                           ),
                         ),
                       );
                     },
                   ),
                 );
               },
            ),
          ],

          if (_activities.isEmpty)
            _buildEmptyState(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Content Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share a post or activity!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Refresh'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print('🔧 Debug: Manually creating sample data for school ${widget.schoolId}');
                    try {
                      await Future.wait([
                        _postService.createSamplePosts(widget.schoolId),
                        _activityService.createSampleActivities(widget.schoolId),
                      ]);
                      print('✅ Debug: Sample data created successfully');
                      _loadData(); // Reload the data
                    } catch (e) {
                      print('❌ Debug: Error creating sample data: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating sample data: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Sample Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 