import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_page.dart';

void main() {
  runApp(const MolinaOSApp());
}

class MolinaOSApp extends StatelessWidget {
  const MolinaOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOLINA OS',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        cardTheme: const CardThemeData(
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C1C1E),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}