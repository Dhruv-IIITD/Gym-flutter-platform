import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

part 'auth_providers.g.dart';

@riverpod
AuthService authService(Ref ref) => AuthService();

@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() {
    return ref.watch(authServiceProvider).getCurrentUser();
  }

  Future<void> login(
    String name,
    String email,
    UserRole role, {
    String? assignedTrainerId,
    String? id,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.watch(authServiceProvider).login(
            name,
            email,
            role,
            assignedTrainerId: assignedTrainerId,
            id: id,
          ),
    );
  }

  Future<void> setCurrentUser(User user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(authServiceProvider).saveCurrentUser(user);
      return user;
    });
  }

  Future<void> logout() async {
    await ref.watch(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

@riverpod
Future<bool> isOnboarded(Ref ref) {
  return ref.watch(authServiceProvider).isOnboarded();
}

@riverpod
Stream<List<User>> trainers(Ref ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'trainer')
      .snapshots()
      .map((snapshot) {
    final trainers = snapshot.docs
        .map((doc) => User.fromFirestore(doc.data(), doc.id))
        .toList();
    return trainers.isEmpty ? seedTrainers : trainers;
  }).handleError((Object _) => seedTrainers);
}
