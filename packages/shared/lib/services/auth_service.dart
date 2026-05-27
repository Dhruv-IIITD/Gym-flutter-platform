import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../utils/logger.dart';

class AuthService {
  AuthService({
    FirebaseFirestore? firestore,
    SharedPreferencesAsync? preferences,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferences = preferences ?? SharedPreferencesAsync();

  static const _currentUserKey = 'current_user';
  static const _isLoggedInKey = 'is_logged_in';
  static const _isOnboardedKey = 'is_onboarded';

  final FirebaseFirestore _firestore;
  final SharedPreferencesAsync _preferences;

  Future<User> login(
    String name,
    String email,
    UserRole role, {
    String? assignedTrainerId,
    String? id,
  }) async {
    final user = User(
      id: id ?? const Uuid().v4(),
      role: role,
      name: name,
      email: email,
      assignedTrainerId: assignedTrainerId,
    );
    await _preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
    await _preferences.setBool(_isLoggedInKey, true);
    WtfLogger.auth('Logged in ${user.name} as ${user.role.name}');
    return user;
  }

  Future<void> saveCurrentUser(User user) async {
    await _preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
    await _preferences.setBool(_isLoggedInKey, true);
  }

  Future<void> logout() async {
    await _preferences.remove(_currentUserKey);
    await _preferences.setBool(_isLoggedInKey, false);
    WtfLogger.auth('Logged out');
  }

  Future<bool> isLoggedIn() async {
    return await _preferences.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> isOnboarded() async {
    return await _preferences.getBool(_isOnboardedKey) ?? false;
  }

  Future<void> markOnboarded() async {
    await _preferences.setBool(_isOnboardedKey, true);
  }

  Future<User?> getCurrentUser() async {
    final raw = await _preferences.getString(_currentUserKey);
    if (raw == null) {
      return null;
    }
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> seedTrainersIfNeeded() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'trainer')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }
    for (final trainer in seedTrainers) {
      await _firestore
          .collection('users')
          .doc(trainer.id)
          .set(trainer.toFirestore());
    }
    WtfLogger.auth('Seeded trainers');
  }
}

const seedTrainers = [
  User(
    id: 'trainer-aarav-001',
    role: UserRole.trainer,
    name: 'Aarav',
    email: 'aarav@wtfgym.com',
  ),
  User(
    id: 'trainer-priya-002',
    role: UserRole.trainer,
    name: 'Priya',
    email: 'priya@wtfgym.com',
  ),
  User(
    id: 'trainer-rahul-003',
    role: UserRole.trainer,
    name: 'Rahul',
    email: 'rahul@wtfgym.com',
  ),
];
