import 'package:flutter/material.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/widgets/sessions_list_screen.dart';

class TrainerSessionsWrapper extends StatelessWidget {
  const TrainerSessionsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionsListScreen(
      userId: seedTrainers.first.id,
      role: UserRole.trainer,
    );
  }
}
