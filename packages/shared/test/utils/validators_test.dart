import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';

void main() {
  group('Validators', () {
    test('rejects past schedule times', () {
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      expect(Validators.validateScheduleTime(past), isNotNull);
    });

    test('accepts future schedule times', () {
      final future = DateTime.now().add(const Duration(minutes: 30));
      expect(Validators.validateScheduleTime(future), isNull);
    });

    test('validates note length', () {
      expect(Validators.validateNote('short note'), isNull);
      expect(Validators.validateNote('x' * 141), isNotNull);
    });

    test('validates names and email addresses', () {
      expect(Validators.validateName('DK'), isNull);
      expect(Validators.validateName('  '), isNotNull);
      expect(Validators.validateEmail('dk@wtfgym.com'), isNull);
      expect(Validators.validateEmail('bad-email'), isNotNull);
    });

    test('detects slot conflicts by exact date and time', () {
      final slot = DateTime(2026, 5, 27, 18);
      final approved = [DateTime(2026, 5, 27, 18)];
      expect(Validators.hasConflict(slot, approved), isTrue);
      expect(
        Validators.hasConflict(DateTime(2026, 5, 27, 18, 30), approved),
        isFalse,
      );
    });
  });
}
