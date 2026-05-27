import 'package:flutter/material.dart';
import 'package:shared/utils/theme.dart';

import 'router.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WTF Trainer',
      theme: buildTrainerTheme(),
      routerConfig: trainerRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
