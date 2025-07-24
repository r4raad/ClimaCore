import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;

  const PostCard({
    Key? key,
    required this.post,
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onSave,
    required this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 8),
            Text(post.content, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: onLike,
                ),
                Text('${post.likes.length}'),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: onComment,
                ),
                Text('${post.commentCount}'),
                Spacer(),
                IconButton(
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: Colors.purple),
                  onPressed: onSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 