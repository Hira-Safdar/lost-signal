import 'package:flutter/material.dart';

import '../features/splash/screens/splash_screen.dart';
import '../shared/theme/app_theme.dart';

class LostSignalApp extends StatelessWidget {
  const LostSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost Signal',
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
