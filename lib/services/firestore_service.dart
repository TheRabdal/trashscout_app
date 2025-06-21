import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(
    String uid,
    String email,
    String name,
    String role,
    String birthdate,
    String gender,
    String province,
    String regency,
    String phoneNumber,
    String profileImageUrl,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'birthdate': birthdate,
      'gender': gender,
      'province': province,
      'regency': regency,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    });
  }

  Future<String?> getUserName(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists &&
        userDoc.data() != null &&
        (userDoc.data() as Map<String, dynamic>).containsKey('name')) {
      return userDoc['name'];
    } else {
      return null;
    }
  }

  Future<String?> getUserPhoto(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists &&
        userDoc.data() != null &&
        (userDoc.data() as Map<String, dynamic>)
            .containsKey('profileImageUrl')) {
      return userDoc['profileImageUrl'];
    } else {
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists &&
        userDoc.data() != null &&
        (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
      return userDoc['role'];
    } else {
      return null;
    }
  }

  Future<void> addNotification(
      String userId, String reportTitle, bool isDone) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'reportTitle': reportTitle,
      'isDone': isDone,
      'dateTime': Timestamp.now(),
    });
  }

  Future<void> updateReportStatus(
      String userId, String reportId, String newStatus) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reports')
        .doc(reportId)
        .update({
      'status': newStatus,
    });

    final reportDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reports')
        .doc(reportId)
        .get();
    String reportTitle = '';
    if (reportDoc.exists &&
        reportDoc.data() != null &&
        (reportDoc.data() as Map<String, dynamic>).containsKey('title')) {
      reportTitle = reportDoc['title'];
    }
    bool isDone = newStatus == 'Selesai';
    await addNotification(userId, reportTitle, isDone);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .where((doc) => doc.exists && doc.data() != null)
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'uid': data.containsKey('uid') ? data['uid'] : doc.id,
        'name': data.containsKey('name') ? data['name'] : '',
        'role': data.containsKey('role') ? data['role'] : '',
        'profileImageUrl':
            data.containsKey('profileImageUrl') ? data['profileImageUrl'] : '',
      };
    }).toList();
  }
}
