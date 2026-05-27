import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/session_log.dart';

void main() {
  group('SessionLog', () {
    test('calculates duration when endedAt is present', () {
      final started = DateTime(2026, 5, 27, 18);
      final ended = started.add(const Duration(minutes: 12, seconds: 30));
      expect(SessionLog.calculateDurationSec(started, ended), 750);
    });

    test('returns null duration when endedAt is missing', () {
      final started = DateTime(2026, 5, 27, 18);
      expect(SessionLog.calculateDurationSec(started, null), isNull);
    });

    test('serializes optional notes and rating', () {
      final log = SessionLog(
        id: 'session-1',
        callRequestId: 'call-1',
        memberId: 'member',
        trainerId: 'trainer',
        startedAt: DateTime(2026, 5, 27, 18),
        endedAt: DateTime(2026, 5, 27, 18, 30),
        durationSec: 1800,
        rating: 5,
        trainerNotes: 'Good form',
        memberNotes: 'Felt strong',
      );

      final restored = SessionLog.fromJson(log.toJson());
      expect(restored.durationSec, 1800);
      expect(restored.rating, 5);
      expect(restored.trainerNotes, 'Good form');
      expect(restored.memberNotes, 'Felt strong');
    });
  });
}
