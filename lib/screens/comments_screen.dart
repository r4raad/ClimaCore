import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class CommentsScreen extends StatefulWidget {
  final String schoolId;
  final String postId;
  final AppUser user;
  const CommentsScreen({Key? key, required this.schoolId, required this.postId, required this.user}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  bool _loading = false;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() { _loading = true; });
    await FirebaseFirestore.instance
        .collection('schools')
        .doc(widget.schoolId)
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': widget.user.id,
      'content': _commentController.text.trim(),
      'timestamp': DateTime.now(),
    });
    _commentController.clear();
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('schools')
                  .doc(widget.schoolId)
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No comments yet.'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['content'] ?? ''),
                      subtitle: Text(data['userId'] ?? ''),
                      trailing: Text((data['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0]),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                _loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _addComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 