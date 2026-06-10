import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/splash/screens/splash_screen.dart';
import '../shared/game/game_controller.dart';
import '../shared/game/game_repository.dart';
import '../shared/settings/app_settings.dart';
import '../shared/theme/app_theme.dart';

class LostSignalApp extends StatefulWidget {
  const LostSignalApp({super.key});

  @override
  State<LostSignalApp> createState() => _LostSignalAppState();
}

class _LostSignalAppState extends State<LostSignalApp> {
  late final AppSettingsController _settingsController;
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _gameController = GameController(
      FirebaseAuth.instance,
      GameRepository(FirebaseFirestore.instance),
    );
    _gameController.initialize();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settingsController,
      child: GameScope(
        controller: _gameController,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lost Signal',
          theme: AppTheme.dark,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
