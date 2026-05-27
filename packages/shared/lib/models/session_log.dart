import 'package:json_annotation/json_annotation.dart';

import 'json_helpers.dart';

part 'session_log.g.dart';

@JsonSerializable()
class SessionLog {
  final String id;
  final String callRequestId;
  final String memberId;
  final String trainerId;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime startedAt;
  @JsonKey(
    fromJson: nullableDateTimeFromJson,
    toJson: nullableDateTimeToJson,
  )
  final DateTime? endedAt;
  final int? durationSec;
  final int? rating;
  final String? trainerNotes;
  final String? memberNotes;

  const SessionLog({
    required this.id,
    required this.callRequestId,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    this.endedAt,
    this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  factory SessionLog.fromJson(Map<String, dynamic> json) =>
      _$SessionLogFromJson(json);

  Map<String, dynamic> toJson() => _$SessionLogToJson(this);

  factory SessionLog.fromFirestore(Map<String, dynamic> data, String docId) {
    return SessionLog.fromJson({...data, 'id': docId});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  static int? calculateDurationSec(DateTime startedAt, DateTime? endedAt) {
    if (endedAt == null) {
      return null;
    }
    final seconds = endedAt.difference(startedAt).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  SessionLog copyWith({
    String? id,
    String? callRequestId,
    String? memberId,
    String? trainerId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    int? rating,
    String? trainerNotes,
    String? memberNotes,
  }) {
    return SessionLog(
      id: id ?? this.id,
      callRequestId: callRequestId ?? this.callRequestId,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      rating: rating ?? this.rating,
      trainerNotes: trainerNotes ?? this.trainerNotes,
      memberNotes: memberNotes ?? this.memberNotes,
    );
  }
}
