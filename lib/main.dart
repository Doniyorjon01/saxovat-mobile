import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/connection_screen.dart';

void main() {
  runApp(const SahovatApp());
}

class SahovatApp extends StatelessWidget {
  const SahovatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahovat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ConnectionScreen(),
    );
  }
}