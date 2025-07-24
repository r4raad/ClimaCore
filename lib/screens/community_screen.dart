import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../services/activity_service.dart';
import '../models/activity.dart';
import '../widgets/activity_card.dart';
import 'activity_detail_screen.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';

class CommunityScreen extends StatefulWidget {
  final AppUser user;
  final String schoolId;
  const CommunityScreen({Key? key, required this.user, required this.schoolId}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _loadingPosts = true;
  final ActivityService _activityService = ActivityService();
  List<Activity> _activities = [];
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPosts();
    _fetchActivities();
  }

  Future<void> _fetchPosts() async {
    setState(() { _loadingPosts = true; });
    final posts = await _postService.getPosts(widget.schoolId);
    setState(() {
      _posts = posts;
      _loadingPosts = false;
    });
  }

  Future<void> _fetchActivities() async {
    setState(() { _loadingActivities = true; });
    final activities = await _activityService.getActivities(widget.schoolId);
    setState(() {
      _activities = activities;
      _loadingActivities = false;
    });
  }

  void _likePost(Post post) async {
    await _postService.likePost(widget.schoolId, post.id, widget.user.id);
    _fetchPosts();
  }

  void _savePost(Post post) async {
    await _postService.savePost(widget.schoolId, post.id, widget.user.id);
    _fetchPosts();
  }

  void _commentPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(schoolId: widget.schoolId, postId: post.id, user: widget.user),
      ),
    );
  }

  void _createPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(schoolId: widget.schoolId, user: widget.user),
      ),
    );
    if (result == true) _fetchPosts();
  }

  void _openActivityDetail(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(activity: activity, schoolName: _getSchoolName()),
      ),
    );
  }

  String _getSchoolName() {
    // Placeholder: you can fetch the school name from Firestore or pass it down
    return '';
  }

  Widget _buildPostsTab() {
    if (_loadingPosts) return Center(child: CircularProgressIndicator());
    if (_posts.isEmpty) return Center(child: Text('No posts yet.'));
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, i) {
        final post = _posts[i];
        final liked = post.likes.contains(widget.user.id);
        final saved = post.saves.contains(widget.user.id);
        return PostCard(
          post: post,
          liked: liked,
          saved: saved,
          onLike: () => _likePost(post),
          onSave: () => _savePost(post),
          onComment: () => _commentPost(post),
        );
      },
    );
  }

  Widget _buildActivitiesTab() {
    if (_loadingActivities) return Center(child: CircularProgressIndicator());
    if (_activities.isEmpty) return Center(child: Text('No activities yet.'));
    final now = DateTime.now();
    final upcoming = _activities.where((a) => a.date.isAfter(now)).toList();
    final past = _activities.where((a) => a.date.isBefore(now)).toList();
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text('Upcoming Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...upcoming.map((a) => ActivityCard(activity: a, onTap: () => _openActivityDetail(a))),
          SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          Text('Past Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...past.map((a) => ActivityCard(activity: a, onTap: () => _openActivityDetail(a))),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Posts'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildActivitiesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createPost,
              child: Icon(Icons.add),
              tooltip: 'Create Post',
            )
          : null,
    );
  }
} 