import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('trainer')
  trainer,
  @JsonValue('member')
  member,
}

@JsonSerializable()
class User {
  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? assignedTrainerId;

  const User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromFirestore(Map<String, dynamic> data, String docId) {
    return User.fromJson({...data, 'id': docId});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  User copyWith({
    String? id,
    UserRole? role,
    String? name,
    String? email,
    String? avatarUrl,
    String? assignedTrainerId,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    );
  }
}
