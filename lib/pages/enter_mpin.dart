import 'package:flutter/material.dart';
import 'package:flutter_practise/theme/app_theme.dart';
import 'package:flutter_practise/services/pin_service.dart';
import 'package:flutter_practise/widgets/gradient_button.dart';
import 'package:flutter_practise/widgets/pin_input.dart';
import 'package:flutter_practise/pages/home.dart';
import 'package:flutter_practise/pages/onboarding.dart';

/// Enter 6-digit M-PIN to unlock the app.
class EnterMpin extends StatefulWidget {
  const EnterMpin({super.key});

  @override
  State<EnterMpin> createState() => _EnterMpinState();
}

class _EnterMpinState extends State<EnterMpin> {
  final _pinController = TextEditingController();

  String _pin = '';
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _pin.length == 6 && !_loading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    final ok = await PinService.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } else {
      setState(() {
        _error = 'Wrong PIN. Please try again.';
        _loading = false;
        _pin = '';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const Onboarding()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Back',
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 48),
                      child: Text(
                        'Enter M-PIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Enter your 6-digit PIN to continue.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      PinInput(
                        controller: _pinController,
                        hintText: '••••••',
                        autofocus: true,
                        onChanged: (v) => setState(() => _pin = v),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _loading ? 'Verifying…' : 'Unlock',
                        onPressed: _canSubmit ? _submit : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
