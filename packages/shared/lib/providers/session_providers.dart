import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/session_log.dart';
import '../models/user.dart';
import '../repositories/session_repository.dart';

part 'session_providers.g.dart';

@riverpod
SessionRepository sessionRepository(Ref ref) => SessionRepository();

@riverpod
Stream<List<SessionLog>> sessionLogs(
  Ref ref,
  String userId,
  UserRole role,
) {
  return ref.watch(sessionRepositoryProvider).watchSessionLogs(userId, role);
}

@riverpod
Stream<List<User>> members(Ref ref, String trainerId) {
  return ref.watch(sessionRepositoryProvider).watchMembers(trainerId);
}

@riverpod
class SessionActions extends _$SessionActions {
  @override
  FutureOr<void> build() {}

  Future<SessionLog> createSessionLog({
    required String callRequestId,
    required String memberId,
    required String trainerId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final log = SessionLog(
      id: const Uuid().v4(),
      callRequestId: callRequestId,
      memberId: memberId,
      trainerId: trainerId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: SessionLog.calculateDurationSec(startedAt, endedAt),
    );
    await ref.watch(sessionRepositoryProvider).saveSessionLog(log);
    return log;
  }

  Future<void> updateSessionLog(
    String id, {
    int? rating,
    String? trainerNotes,
    String? memberNotes,
  }) async {
    await ref.watch(sessionRepositoryProvider).updateSessionLog(
          id,
          rating: rating,
          trainerNotes: trainerNotes,
          memberNotes: memberNotes,
        );
  }
}
