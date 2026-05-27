import 'package:json_annotation/json_annotation.dart';

import 'json_helpers.dart';

part 'message.g.dart';

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('read')
  read,
}

@JsonSerializable()
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  final MessageStatus status;
  final bool isSystemMessage;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
    required this.isSystemMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  factory Message.fromFirestore(Map<String, dynamic> data, String docId) {
    return Message.fromJson({...data, 'id': docId});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
    bool? isSystemMessage,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }
}
