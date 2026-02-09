# Test Bank — Flutter Practice App

A Flutter practice app that demonstrates **auth and security patterns** suitable for banking-style applications: M-PIN, optional biometrics, and secure storage.

## Features

- **M-PIN (6-digit)** — Set and verify a 6-digit PIN. Stored only as an Argon2 hash with salt in platform secure storage (iOS Keychain / Android Keystore).
- **Biometrics** — Optional fingerprint or Face ID to unlock after entering PIN once; preference stored locally, no biometric data leaves the device.
- **Sign in / Sign up** — Onboarding with mock email/password; first-time users are guided to set M-PIN, then reach Home.
- **App start behaviour** — If the user already has M-PIN set, the app opens directly to **Enter M-PIN**; otherwise to **Onboarding** (Sign in / Sign up).
- **Logout** — Logging out from Home returns to **Enter M-PIN** (lock screen), not onboarding, so returning users unlock with PIN or biometrics.

## Security

- **PIN never stored in plain text** — Argon2id hash + random salt; verification uses constant-time comparison.
- **Sensitive data in secure storage** — PIN hash and salt live in `flutter_secure_storage` (Keychain/Keystore); Android uses `encryptedSharedPreferences: true`.
- **Biometrics are local-only** — The app only stores a “use biometrics” preference; actual authentication is handled by the OS via `local_auth`.

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK ^3.10.8)
- iOS simulator/device or Android emulator/device (biometrics work best on a real device)

## Getting started

```bash
# Clone (or open) the project, then:
cd flutter_practise
flutter pub get
flutter run
```

Pick a device when prompted (e.g. iOS Simulator or Android Emulator).

## Project structure

```
lib/
├── main.dart                 # App entry, theme, home: AppStart
├── pages/
│   ├── app_start.dart        # Decides Enter M-PIN vs Onboarding on launch
│   ├── onboarding.dart      # Sign in / Sign up
│   ├── signin.dart           # M-PIN, biometrics, or email/password
│   ├── signup.dart
│   ├── setup_mpin.dart       # Create 6-digit M-PIN (first time)
│   ├── enter_mpin.dart       # Unlock with M-PIN or biometrics
│   └── home.dart            # Placeholder home after auth; Logout → Enter M-PIN
├── services/
│   ├── pin_service.dart     # Set/verify/clear PIN (Argon2, secure storage)
│   └── biometric_service.dart  # Local biometric auth (local_auth)
├── storage/
│   └── secure_auth_storage.dart  # Keychain/Keystore for PIN hash, salt, prefs
├── database/
│   └── app_database.dart    # Abstraction over secure auth storage (no SQLite)
├── theme/
│   └── app_theme.dart       # Brand colors, gradient, theme
└── widgets/
    ├── gradient_button.dart
    └── pin_input.dart
```

## Dependencies

| Package | Purpose |
|--------|---------|
| `argon2` | Hash M-PIN with salt (no plain PIN storage) |
| `flutter_secure_storage` | Store PIN hash/salt in Keychain (iOS) / Keystore (Android) |
| `local_auth` | Fingerprint / Face ID prompt (local only) |

## Licence

Practice project — not for production use as-is.
