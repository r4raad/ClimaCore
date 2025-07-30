import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  final String schoolId;
  final AppUser user;
  const CreatePostScreen({Key? key, required this.schoolId, required this.user}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _loading = true; });
    
    try {
      print('📝 CreatePost: Creating new post for school ${widget.schoolId}');
      print('📝 CreatePost: User ID: ${widget.user.id}');
      print('📝 CreatePost: Content: ${_contentController.text.trim()}');
      
      final post = Post(
        id: Uuid().v4(),
        userId: widget.user.id,
        content: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        timestamp: DateTime.now(),
        likes: [],
        saves: [],
        commentCount: 0,
      );
      
      print('📝 CreatePost: Post created, saving to Firebase...');
      print('📝 CreatePost: Post ID: ${post.id}');
      await PostService().addPost(widget.schoolId, post);
      print('✅ CreatePost: Post saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ CreatePost: Error creating post: $e');
      print('❌ CreatePost: Error type: ${e.runtimeType}');
      if (e.toString().contains('permission')) {
        print('❌ CreatePost: This looks like a Firebase security rules issue');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _submit,
              child: Text(
                'Post',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.user.profilePic != null 
                        ? NetworkImage(widget.user.profilePic!)
                        : AssetImage('assets/images/icon.png') as ImageProvider,
                    radius: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.user.fullName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'What\'s happening in your community?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                maxLines: 8,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please write something to share';
                  }
                  if (v.trim().length < 10) {
                    return 'Post should be at least 10 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final uri = Uri.tryParse(v);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_loading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Creating your post...'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 