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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; });
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
    await PostService().addPost(widget.schoolId, post);
    setState(() { _loading = false; });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'What do you want to share?'),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Content required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL (optional)'),
              ),
              SizedBox(height: 24),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Post'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 