import 'package:flutter/material.dart';

import '../features/splash/screens/splash_screen.dart';
import '../shared/settings/app_settings.dart';
import '../shared/theme/app_theme.dart';

class LostSignalApp extends StatefulWidget {
  const LostSignalApp({super.key});

  @override
  State<LostSignalApp> createState() => _LostSignalAppState();
}

class _LostSignalAppState extends State<LostSignalApp> {
  late final AppSettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settingsController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lost Signal',
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
