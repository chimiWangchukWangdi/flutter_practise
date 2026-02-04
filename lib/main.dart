import 'package:flutter/material.dart';
import 'package:flutter_practise/pages/onboarding.dart';
import 'package:flutter_practise/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Bank',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const Onboarding(),
    );
  }
}
