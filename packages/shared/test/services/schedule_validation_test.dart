import 'package:flutter_test/flutter_test.dart';
import 'package:shared/services/schedule_service.dart';

void main() {
  group('ScheduleService', () {
    test('generates 30 minute slots from 06:00 to 22:00', () {
      final service = ScheduleService();
      final slots = service.generateTimeSlots(DateTime(2026, 5, 27));
      expect(slots.first.hour, 6);
      expect(slots.first.minute, 0);
      expect(slots.last.hour, 22);
      expect(slots.last.minute, 0);
      expect(slots[1].difference(slots[0]), const Duration(minutes: 30));
    });

    test('returns three available dates', () {
      final service = ScheduleService();
      expect(service.getAvailableDates(), hasLength(3));
    });
  });
}
