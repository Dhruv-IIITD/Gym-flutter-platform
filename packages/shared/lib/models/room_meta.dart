import 'package:json_annotation/json_annotation.dart';

import 'json_helpers.dart';

part 'room_meta.g.dart';

@JsonSerializable()
class RoomMeta {
  final String id;
  final String callRequestId;
  final String roomId;
  final String trainerRoomCode;
  final String memberRoomCode;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;

  const RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.roomId,
    required this.trainerRoomCode,
    required this.memberRoomCode,
    required this.createdAt,
  });

  factory RoomMeta.fromJson(Map<String, dynamic> json) =>
      _$RoomMetaFromJson(json);

  Map<String, dynamic> toJson() => _$RoomMetaToJson(this);

  factory RoomMeta.fromFirestore(Map<String, dynamic> data, String docId) {
    return RoomMeta.fromJson({...data, 'id': docId});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
