import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostService {
  CollectionReference getPostsCollection(String schoolId) {
    return FirebaseFirestore.instance.collection('schools').doc(schoolId).collection('posts');
  }

  Future<List<Post>> getPosts(String schoolId) async {
    final snapshot = await getPostsCollection(schoolId).orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addPost(String schoolId, Post post) async {
    await getPostsCollection(schoolId).doc(post.id).set(post.toMap());
  }

  Future<void> likePost(String schoolId, String postId, String userId) async {
    await getPostsCollection(schoolId).doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> savePost(String schoolId, String postId, String userId) async {
    await getPostsCollection(schoolId).doc(postId).update({
      'saves': FieldValue.arrayUnion([userId]),
    });
  }
} 