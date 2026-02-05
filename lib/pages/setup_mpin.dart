import 'package:flutter/material.dart';
import 'package:flutter_practise/theme/app_theme.dart';
import 'package:flutter_practise/services/pin_service.dart';
import 'package:flutter_practise/services/biometric_service.dart';
import 'package:flutter_practise/widgets/gradient_button.dart';
import 'package:flutter_practise/widgets/pin_input.dart';
import 'package:flutter_practise/pages/home.dart';

/// Set up 6-digit M-PIN (create + confirm). Stored hashed in SQLite.
class SetupMpin extends StatefulWidget {
  const SetupMpin({super.key});

  @override
  State<SetupMpin> createState() => _SetupMpinState();
}

class _SetupMpinState extends State<SetupMpin> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  String _pin = '';
  String _confirmPin = '';
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _pin.length == 6 &&
      _confirmPin.length == 6 &&
      _pin == _confirmPin &&
      !_loading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await PinService.setPin(_pin);
      if (!mounted) return;
      final hasBiometrics = await BiometricService.deviceHasBiometrics;
      if (!mounted) return;
      if (hasBiometrics) {
        final useBiometrics = await _showEnableBiometricsDialog();
        if (!mounted) return;
        if (useBiometrics) {
          await BiometricService.setBiometricsEnabled(true);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } on ArgumentError catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  Future<bool> _showEnableBiometricsDialog() async {
    final label = await BiometricService.getBiometricLabel();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Use biometrics to unlock?'),
        content: Text(
          'You can use $label to unlock the app instead of entering your PIN each time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    return result ?? false;
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Back',
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 48),
                      child: Text(
                        'Set up M-PIN',
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
                  'Create a 6-digit PIN to secure your app. Do not share it.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Enter PIN',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PinInput(
                          controller: _pinController,
                          hintText: '••••••',
                          autofocus: true,
                          onChanged: (v) => setState(() => _pin = v),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Confirm PIN',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PinInput(
                          controller: _confirmController,
                          hintText: '••••••',
                          onChanged: (v) => setState(() => _confirmPin = v),
                        ),
                        if (_pin.isNotEmpty &&
                            _confirmPin.isNotEmpty &&
                            _pin != _confirmPin) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'PINs do not match',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        GradientButton(
                          label: _loading ? 'Creating…' : 'Create M-PIN',
                          onPressed: _canSubmit ? _submit : null,
                        ),
                      ],
                    ),
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
