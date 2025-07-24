import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';

class SchoolService {
  final CollectionReference schoolsCollection = FirebaseFirestore.instance.collection('schools');

  Future<List<School>> getSchools() async {
    final snapshot = await schoolsCollection.get();
    return snapshot.docs.map((doc) => School.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addSchool(School school) async {
    await schoolsCollection.doc(school.id).set(school.toMap());
  }

  Future<School?> getSchoolById(String id) async {
    final doc = await schoolsCollection.doc(id).get();
    if (doc.exists) {
      return School.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }
} 