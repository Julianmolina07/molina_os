import 'package:flutter/material.dart';

import 'core/theme/theme_controller.dart';
import 'features/dashboard/dashboard_page.dart';

void main() {
  runApp(const MolinaOSApp());
}

class MolinaOSApp extends StatefulWidget {
  const MolinaOSApp({super.key});

  @override
  State<MolinaOSApp> createState() => _MolinaOSAppState();
}

class _MolinaOSAppState extends State<MolinaOSApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_onThemeChanged);
    _themeController.load();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeController
      ..removeListener(_onThemeChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOLINA OS',
      themeMode: _themeController.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF16324F),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFDCE7F1),
          onPrimaryContainer: Color(0xFF0D2438),
          secondary: Color(0xFF3E5C76),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFE1E9F0),
          onSecondaryContainer: Color(0xFF1B2D3D),
          surface: Color(0xFFF7F8FA),
          onSurface: Color(0xFF17212B),
          surfaceContainerHighest: Color(0xFFE9EDF1),
          outline: Color(0xFF7A8793),
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        cardTheme: const CardThemeData(color: Colors.white),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardTheme: const CardThemeData(color: Color(0xFF1C1C1E)),
      ),
      home: DashboardPage(themeController: _themeController),
    );
  }
}
