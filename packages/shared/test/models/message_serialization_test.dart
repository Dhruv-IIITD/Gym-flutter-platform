import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/message.dart';

void main() {
  group('Message serialization', () {
    test('toJson/fromJson round-trip preserves all fields', () {
      final message = Message(
        id: 'msg-001',
        chatId: 'chat-001',
        senderId: 'user-a',
        receiverId: 'user-b',
        text: 'Hello!',
        createdAt: DateTime(2026, 5, 27, 14, 30),
        status: MessageStatus.sent,
        isSystemMessage: false,
      );

      final json = message.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, equals(message.id));
      expect(restored.chatId, equals(message.chatId));
      expect(restored.senderId, equals(message.senderId));
      expect(restored.receiverId, equals(message.receiverId));
      expect(restored.text, equals(message.text));
      expect(restored.createdAt, equals(message.createdAt));
      expect(restored.status, equals(MessageStatus.sent));
      expect(restored.isSystemMessage, isFalse);
    });

    test('fromJson handles all MessageStatus enum values', () {
      for (final status in MessageStatus.values) {
        final json = {
          'id': 'test',
          'chatId': 'test',
          'senderId': 'a',
          'receiverId': 'b',
          'text': 'hi',
          'createdAt': DateTime(2026, 5, 27, 14, 30).toIso8601String(),
          'status': status.name,
          'isSystemMessage': false,
        };
        final message = Message.fromJson(json);
        expect(message.status, equals(status));
      }
    });
  });
}
