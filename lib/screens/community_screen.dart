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

class _CommunityScreenState extends State<CommunityScreen> {
  final PostService _postService = PostService();
  final ActivityService _activityService = ActivityService();
  final UserService _userService = UserService();
  final SchoolService _schoolService = SchoolService();

  List<Post> _posts = [];
  List<Activity> _activities = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _schoolName;

  static const String _schoolImageUrl = 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=School+Image';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSchoolName();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _postService.getPosts(widget.schoolId),
        _activityService.getActivities(widget.schoolId),
      ]);

      setState(() {
        _posts = results[0] as List<Post>;
        _activities = results[1] as List<Activity>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadSchoolName() async {
    try {
      final school = await _schoolService.getSchoolById(widget.schoolId);
      setState(() {
        _schoolName = school?.name;
      });
    } catch (e) {
      print('Error loading school name: $e');
    }
  }

  String _getSchoolName() {
    return _schoolName ?? 'School Community';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                const Text(
                  'Community',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
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
                ],
              ),
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
          ),
          
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
                 final post = _posts[index];
                 final liked = post.likes.contains(widget.user.id);
                 final saved = post.saves.contains(widget.user.id);
                 
                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                   child: PostCard(
                     post: post,
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
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Comments feature coming soon!')),
                       );
                     },
                   ),
                 );
               },
            ),
          ],

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
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Activity details coming soon!')),
                       );
                     },
                   ),
                 );
               },
            ),
          ],

          if (_posts.isEmpty && _activities.isEmpty)
            Padding(
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
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
} 