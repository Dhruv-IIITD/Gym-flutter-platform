import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/call_request.dart';
import '../models/room_meta.dart';
import '../models/user.dart';

class ScheduleRepository {
  ScheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createCallRequest(CallRequest request) async {
    await _firestore
        .collection('call_requests')
        .doc(request.id)
        .set(request.toFirestore());
  }

  Stream<List<CallRequest>> watchCallRequests(String userId, UserRole role) {
    final field = role == UserRole.member ? 'memberId' : 'trainerId';
    return _firestore
        .collection('call_requests')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => CallRequest.fromFirestore(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return requests;
    });
  }

  Future<void> updateCallRequestStatus(
    String id,
    CallRequestStatus status, {
    String? reason,
    String? roomMetaId,
  }) async {
    await _firestore.collection('call_requests').doc(id).update({
      'status': status.name,
      if (reason != null) 'declineReason': reason,
      if (roomMetaId != null) 'roomMetaId': roomMetaId,
    });
  }

  Future<List<DateTime>> getApprovedSlots(String trainerId) async {
    final snapshot = await _firestore
        .collection('call_requests')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'approved')
        .get();
    return snapshot.docs
        .map((doc) => CallRequest.fromFirestore(doc.data(), doc.id).scheduledAt)
        .toList();
  }

  Future<void> saveRoomMeta(RoomMeta roomMeta) async {
    await _firestore
        .collection('room_metas')
        .doc(roomMeta.id)
        .set(roomMeta.toFirestore());
  }

  Future<RoomMeta?> getRoomMeta(String id) async {
    final doc = await _firestore.collection('room_metas').doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      return null;
    }
    return RoomMeta.fromFirestore(data, doc.id);
  }
}
