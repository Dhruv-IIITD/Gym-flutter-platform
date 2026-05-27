import 'package:json_annotation/json_annotation.dart';

import 'json_helpers.dart';

part 'call_request.g.dart';

enum CallRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('declined')
  declined,
  @JsonValue('completed')
  completed,
}

@JsonSerializable()
class CallRequest {
  final String id;
  final String memberId;
  final String trainerId;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime scheduledAt;
  final String note;
  final CallRequestStatus status;
  final String? declineReason;
  final String? roomMetaId;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;

  const CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.scheduledAt,
    required this.note,
    required this.status,
    this.declineReason,
    this.roomMetaId,
    required this.createdAt,
  });

  factory CallRequest.fromJson(Map<String, dynamic> json) =>
      _$CallRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CallRequestToJson(this);

  factory CallRequest.fromFirestore(Map<String, dynamic> data, String docId) {
    return CallRequest.fromJson({...data, 'id': docId});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  CallRequest copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? scheduledAt,
    String? note,
    CallRequestStatus? status,
    String? declineReason,
    String? roomMetaId,
    DateTime? createdAt,
  }) {
    return CallRequest(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      note: note ?? this.note,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
      roomMetaId: roomMetaId ?? this.roomMetaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
