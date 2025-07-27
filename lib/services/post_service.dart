import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostService {
  CollectionReference getPostsCollection(String schoolId) {
    return FirebaseFirestore.instance.collection('schools').doc(schoolId).collection('posts');
  }

  Future<List<Post>> getPosts(String schoolId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = getPostsCollection(schoolId).orderBy('timestamp', descending: true);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => 
        Post.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> addPost(String schoolId, Post post) async {
    try {
      await getPostsCollection(schoolId).doc(post.id).set(post.toMap());
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  Future<void> likePost(String schoolId, String postId, String userId) async {
    try {
      await getPostsCollection(schoolId).doc(postId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error liking post: $e');
      rethrow;
    }
  }

  Future<void> unlikePost(String schoolId, String postId, String userId) async {
    try {
      await getPostsCollection(schoolId).doc(postId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error unliking post: $e');
      rethrow;
    }
  }

  Future<void> savePost(String schoolId, String postId, String userId) async {
    try {
      await getPostsCollection(schoolId).doc(postId).update({
        'saves': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error saving post: $e');
      rethrow;
    }
  }

  Future<void> unsavePost(String schoolId, String postId, String userId) async {
    try {
      await getPostsCollection(schoolId).doc(postId).update({
        'saves': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error unsaving post: $e');
      rethrow;
    }
  }

  Future<void> addComment(String schoolId, String postId, String comment) async {
    try {
      await getPostsCollection(schoolId).doc(postId).collection('comments').add({
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
} 