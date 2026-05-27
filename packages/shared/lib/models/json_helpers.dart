import 'package:cloud_firestore/cloud_firestore.dart';

DateTime dateTimeFromJson(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  throw FormatException('Unsupported DateTime value: $value');
}

String dateTimeToJson(DateTime value) => value.toIso8601String();

DateTime? nullableDateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return dateTimeFromJson(value);
}

String? nullableDateTimeToJson(DateTime? value) => value?.toIso8601String();
