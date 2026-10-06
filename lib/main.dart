import 'package:flutter/material.dart';
import 'core/native_bridge/platform_native_bridge.dart';
import 'features/target_apps/presentation/background_interception_manager.dart';
import 'features/target_apps/presentation/target_apps_settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FrictionXApp());
}

class FrictionXApp extends StatefulWidget {
  const FrictionXApp({super.key});

  @override
  State<FrictionXApp> createState() => _FrictionXAppState();
}

class _FrictionXAppState extends State<FrictionXApp> {
  late final BackgroundInterceptionManager _interceptionManager;

  @override
  void initState() {
    super.initState();
    _interceptionManager = BackgroundInterceptionManager(
      navigatorKey: rootNavigatorKey,
    );
    _interceptionManager.initialize();
  }

  @override
  void dispose() {
    _interceptionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Friction-X',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0C0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF141419),
        ),
      ),
      home: const TargetAppsSettingsScreen(),
    );
  }
}
