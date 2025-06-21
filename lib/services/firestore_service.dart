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
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc['name'];
    } else {
      return null;
    }
  }

  Future<String?> getUserPhoto(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc['profileImageUrl'];
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

    String reportTitle = (await _firestore
            .collection('users')
            .doc(userId)
            .collection('reports')
            .doc(reportId)
            .get())
        .data()!['title'];

    bool isDone = newStatus == 'Selesai';
    await addNotification(userId, reportTitle, isDone);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => {
              'uid':
                  doc.data().toString().contains('uid') ? doc['uid'] : doc.id,
              'name': doc['name'],
            })
        .toList();
  }
}
