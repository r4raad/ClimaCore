import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/image_upload_service.dart';
import '../constants.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';

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
  bool _loading = false;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _hasImage = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final imageFile = await ImageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBytes = null;
          _hasImage = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final imageBytes = await ImageUploadService.takePhotoWithCamera();
      if (imageBytes != null) {
        setState(() {
          _selectedImageBytes = imageBytes;
          _selectedImageFile = null;
          _hasImage = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _loading = true; });
    
    try {
      print('📝 CreatePost: Creating new post for school ${widget.schoolId}');
      print('📝 CreatePost: User ID: ${widget.user.id}');
      print('📝 CreatePost: Content: ${_contentController.text.trim()}');
      
      final postId = Uuid().v4();
      String? imageUrl;
      
      // Upload image if selected
      if (_hasImage) {
        print('📝 CreatePost: Uploading image to Supabase...');
        if (_selectedImageFile != null) {
          imageUrl = await ImageUploadService.uploadPostImage(
            postId: postId,
            imageFile: _selectedImageFile,
          );
        } else if (_selectedImageBytes != null) {
          imageUrl = await ImageUploadService.uploadPostImage(
            postId: postId,
            imageBytes: _selectedImageBytes,
          );
        }
        print('📝 CreatePost: Image uploaded: $imageUrl');
      }
      
      final post = Post(
        id: postId,
        userId: widget.user.id,
        content: _contentController.text.trim(),
        imageUrl: imageUrl,
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
                        : const AssetImage(AppConstants.appLogoPath) as ImageProvider,
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
              
              // Image Selection Status
              if (_hasImage)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Image selected',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedImageBytes = null;
                            _hasImage = false;
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.green[600], size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 16),
              
              // Image Upload Options
              Row(
                children: [
                  Expanded(
                    child: _buildImageUploadOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      onTap: _pickImageFromGallery,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildImageUploadOption(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      onTap: _takePhotoWithCamera,
                      color: Colors.green,
                    ),
                  ),
                ],
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

  Widget _buildImageUploadOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 