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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}