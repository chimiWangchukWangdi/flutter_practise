import 'package:flutter/material.dart';
import 'package:flutter_practise/pages/enter_mpin.dart';
import 'package:flutter_practise/pages/onboarding.dart';
import 'package:flutter_practise/services/pin_service.dart';
import 'package:flutter_practise/theme/app_theme.dart';

/// Decides initial screen: if user has M-PIN → [EnterMpin], else → [Onboarding].
class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasPin = await PinService.hasPin();
    if (!mounted) return;
    setState(() => _hasPin = hasPin);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPin == null) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  'Test Bank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasPin!) {
      return const EnterMpin();
    }
    return const Onboarding();
  }
}
