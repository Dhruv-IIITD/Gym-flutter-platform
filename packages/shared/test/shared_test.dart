import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';

void main() {
  test('shared package exports validators', () {
    expect(Validators.validateName('DK'), isNull);
  });
}
