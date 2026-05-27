import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_log.dart';
import '../models/user.dart';

class SessionRepository {
  SessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<SessionLog>> watchSessionLogs(String userId, UserRole role) {
    final field = role == UserRole.member ? 'memberId' : 'trainerId';
    return _firestore
        .collection('session_logs')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => SessionLog.fromFirestore(doc.data(), doc.id))
          .toList();
      logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return logs;
    });
  }

  Future<void> saveSessionLog(SessionLog log) async {
    await _firestore
        .collection('session_logs')
        .doc(log.id)
        .set(log.toFirestore());
  }

  Future<void> updateSessionLog(
    String id, {
    int? rating,
    String? trainerNotes,
    String? memberNotes,
  }) async {
    await _firestore.collection('session_logs').doc(id).update({
      if (rating != null) 'rating': rating,
      if (trainerNotes != null) 'trainerNotes': trainerNotes,
      if (memberNotes != null) 'memberNotes': memberNotes,
    });
  }

  Stream<List<User>> watchMembers(String trainerId) {
    return _firestore
        .collection('users')
        .where('assignedTrainerId', isEqualTo: trainerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => User.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
