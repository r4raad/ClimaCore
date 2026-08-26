import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_request.dart';
import '../models/user.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createVerificationRequest({
    required AppUser user,
    required String schoolId,
    required String schoolName,
    required VerificationType type,
    required String itemId,
    required String itemTitle,
    required int points,
    String? proofImageUrl,
    String? description,
  }) async {
    try {
      final verificationRequest = VerificationRequest(
        id: '',
        userId: user.id,
        userName: user.fullName,
        schoolId: schoolId,
        schoolName: schoolName,
        type: type,
        itemId: itemId,
        itemTitle: itemTitle,
        points: points,
        proofImageUrl: proofImageUrl,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('verification_requests')
          .add(verificationRequest.toMap());
    } catch (e) {
      throw Exception('Failed to create verification request: $e');
    }
  }

  Future<List<VerificationRequest>> getUserVerificationRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user verification requests: $e');
    }
  }

  Future<List<VerificationRequest>> getPendingVerificationRequests() async {
    try {
      final snapshot = await _firestore
          .collection('verification_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending verification requests: $e');
    }
  }

  Future<List<VerificationRequest>> getSchoolVerificationRequests(String schoolId) async {
    try {
      final snapshot = await _firestore
          .collection('verification_requests')
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get school verification requests: $e');
    }
  }

  Future<void> approveVerificationRequest({
    required String requestId,
    required String reviewerId,
    String? reviewNotes,
  }) async {
    try {
      await _firestore.collection('verification_requests').doc(requestId).update({
        'status': 'approved',
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
        'reviewedBy': reviewerId,
        'reviewNotes': reviewNotes,
      });
    } catch (e) {
      throw Exception('Failed to approve verification request: $e');
    }
  }

  Future<void> rejectVerificationRequest({
    required String requestId,
    required String reviewerId,
    String? reviewNotes,
  }) async {
    try {
      await _firestore.collection('verification_requests').doc(requestId).update({
        'status': 'rejected',
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
        'reviewedBy': reviewerId,
        'reviewNotes': reviewNotes,
      });
    } catch (e) {
      throw Exception('Failed to reject verification request: $e');
    }
  }

  Future<bool> hasPendingVerification({
    required String userId,
    required String itemId,
    required VerificationType type,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .where('type', isEqualTo: type.toString().split('.').last)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check pending verification: $e');
    }
  }

  Future<VerificationRequest?> getVerificationRequest({
    required String userId,
    required String itemId,
    required VerificationType type,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .where('type', isEqualTo: type.toString().split('.').last)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return VerificationRequest.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data(),
      );
    } catch (e) {
      throw Exception('Failed to get verification request: $e');
    }
  }

  Future<void> deleteVerificationRequest(String requestId) async {
    try {
      await _firestore
          .collection('verification_requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete verification request: $e');
    }
  }
}