import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/call_request.dart';
import '../models/room_meta.dart';
import '../models/user.dart';
import '../repositories/schedule_repository.dart';
import '../services/schedule_service.dart';

part 'schedule_providers.g.dart';

@riverpod
ScheduleRepository scheduleRepository(Ref ref) => ScheduleRepository();

@riverpod
ScheduleService scheduleService(Ref ref) {
  return ScheduleService(repository: ref.watch(scheduleRepositoryProvider));
}

@riverpod
Stream<List<CallRequest>> callRequests(
  Ref ref,
  String userId,
  UserRole role,
) {
  return ref.watch(scheduleRepositoryProvider).watchCallRequests(userId, role);
}

@riverpod
List<DateTime> availableDates(Ref ref) {
  return ref.watch(scheduleServiceProvider).getAvailableDates();
}

@riverpod
List<DateTime> availableSlots(Ref ref, DateTime date) {
  return ref.watch(scheduleServiceProvider).generateTimeSlots(date);
}

@riverpod
class ScheduleActions extends _$ScheduleActions {
  @override
  FutureOr<void> build() {}

  Future<void> createRequest({
    required String memberId,
    required String trainerId,
    required DateTime scheduledAt,
    required String note,
  }) async {
    final request = CallRequest(
      id: const Uuid().v4(),
      memberId: memberId,
      trainerId: trainerId,
      scheduledAt: scheduledAt,
      note: note,
      status: CallRequestStatus.pending,
      createdAt: DateTime.now(),
    );
    await ref.watch(scheduleRepositoryProvider).createCallRequest(request);
  }

  Future<RoomMeta> approveRequest(
    CallRequest request, {
    String tokenServerBaseUrl = 'http://localhost:3000',
  }) async {
    final repo = ref.watch(scheduleRepositoryProvider);
    final conflict = await ref
        .watch(scheduleServiceProvider)
        .checkConflict(request.trainerId, request.scheduledAt);
    if (conflict) {
      throw StateError('This time slot is already booked.');
    }

    final roomMeta = await _createRoomMeta(
      request,
      tokenServerBaseUrl: tokenServerBaseUrl,
    );
    await repo.saveRoomMeta(roomMeta);
    await repo.updateCallRequestStatus(
      request.id,
      CallRequestStatus.approved,
      roomMetaId: roomMeta.id,
    );
    return roomMeta;
  }

  Future<void> declineRequest(CallRequest request, String reason) async {
    await ref.watch(scheduleRepositoryProvider).updateCallRequestStatus(
          request.id,
          CallRequestStatus.declined,
          reason: reason,
        );
  }

  Future<void> completeRequest(CallRequest request) async {
    await ref.watch(scheduleRepositoryProvider).updateCallRequestStatus(
          request.id,
          CallRequestStatus.completed,
        );
  }

  Future<RoomMeta> _createRoomMeta(
    CallRequest request, {
    required String tokenServerBaseUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$tokenServerBaseUrl/create-room'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': 'call-${request.id}'}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final codes = data['roomCodes'];
        return RoomMeta(
          id: const Uuid().v4(),
          callRequestId: request.id,
          roomId: data['roomId'] as String? ?? 'room-${request.id}',
          trainerRoomCode: codes is Map<String, dynamic>
              ? codes['trainer'] as String? ?? 'trainer-room-code'
              : 'trainer-room-code',
          memberRoomCode: codes is Map<String, dynamic>
              ? codes['member'] as String? ?? 'member-room-code'
              : 'member-room-code',
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {
      // Local demo fallback: allow approval flow without a running token server.
    }
    return RoomMeta(
      id: const Uuid().v4(),
      callRequestId: request.id,
      roomId: 'room-${request.id}',
      trainerRoomCode: 'trainer-room-code',
      memberRoomCode: 'member-room-code',
      createdAt: DateTime.now(),
    );
  }
}
