import 'package:flutter/material.dart';
import 'package:shared/utils/theme.dart';

import 'router.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WTF Guru',
      theme: buildGuruTheme(),
      routerConfig: guruRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
