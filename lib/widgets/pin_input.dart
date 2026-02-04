import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 6-digit PIN field (masked, digits only).
class PinInput extends StatelessWidget {
  const PinInput({
    super.key,
    required this.controller,
    this.hintText = '••••••',
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  static const int _pinLength = 6;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: _pinLength,
      textAlign: TextAlign.center,
      style: const TextStyle(
        letterSpacing: 8,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_pinLength),
      ],
      onChanged: (value) {
        if (value.length == _pinLength) {
          onChanged?.call(value);
        }
      },
    );
  }
}
