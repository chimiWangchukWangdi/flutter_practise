# Presentation & Demo Guide — Flutter Practice (Banking-Ready)

Use this as your outline for the manager presentation, with emphasis on **security**

---

## 1. Opening (1–2 min)

- **Context:** “I’ve been learning Flutter for the past 5 days to prepare for the banking app frontend work.”
- **Goal:** “I built a small practice app that focuses on **auth and security patterns** we’ll need in the real banking app, so I could learn the stack and think security-first.”
- **What you’ll show:** Short demo + technical highlights, especially around secure storage, M-PIN, and biometrics.

---

## 2. What the App Does (1 min)

- **Onboarding** → **Sign in** (M-PIN, optional fingerprint/face, or email/password mock).
- **First-time:** Set 6-digit M-PIN → optional “Use fingerprint” → **Home**.
- **Returning:** Enter M-PIN or use biometrics → **Home**.
- **Logout** brings user back to onboarding.

Keep it high-level; details come in the demo and security section.

---

## 3. Live Demo Script (3–5 min)

Do this on a **device** (simulator is fine; biometrics are more impressive on a real device).

| Step | What to do | What to say (short) |
|------|------------|----------------------|
| 1 | Open app → Onboarding | “Landing: Sign in / Sign up.” |
| 2 | Tap **Sign in** | “Sign-in options: M-PIN, biometrics if available, or email/password.” |
| 3 | Tap **Sign in with M-PIN** (first time) | “First time: we go to Set up M-PIN.” |
| 4 | Enter 6-digit PIN twice, confirm | “Create and confirm 6-digit M-PIN.” |
| 5 | If dialog appears: **Enable fingerprint** (or skip) | “Optional: enable fingerprint for next time—stored as a preference only.” |
| 6 | Land on **Home** | “After auth, user reaches home.” |
| 7 | Tap **Logout** → back to Onboarding → Sign in again | “Logout and sign in again.” |
| 8 | Tap **Sign in with M-PIN** | “Now we get Enter M-PIN.” |
| 9 | Enter correct PIN (or use fingerprint if enabled) | “Correct PIN or biometric unlocks the app.” |
| 10 | Show wrong PIN → error | “Wrong PIN is rejected.” |

**Tip:** Rehearse once so the flow is smooth. If biometrics are flaky on the device, say: “Biometrics are wired; on this device/simulator we’re focusing on the M-PIN flow.”

---

## 4. Security Highlights (Build Trust)

This is the section that shows you take security seriously. Use it as your main “technical credibility” part.

### 4.1 M-PIN is never stored in plain text

- We **never** store the 6-digit PIN.
- We store only a **hash** (Argon2id) + **random salt**.
- Verification: hash(entered PIN, stored salt) and **constant-time compare** with stored hash (reduces timing-attack risk).

*You can briefly open `lib/services/pin_service.dart` and point to `_hashPin`, `_constantTimeEquals`, and that we only pass hashes/salts to storage.*

### 4.2 Sensitive data in platform secure storage

- PIN hash and salt are in **secure storage** (iOS Keychain / Android Keystore), not in plain SQLite.
- Implemented in `lib/storage/secure_auth_storage.dart` with `flutter_secure_storage` and `encryptedSharedPreferences: true` on Android.
- SQLite is only used for a **one-time migration** from older installs; after that, auth is secure-storage only.

*Point to `SecureAuthStorage` and the comment that SQLite is not used for live auth data.*

### 4.3 Biometrics are local-only

- We only store a **preference**: “use fingerprint/face for unlock.”
- Actual biometric data never leaves the device; the OS handles it (`local_auth`).
- Same pattern as typical banking apps: biometrics = alternative to entering PIN, not a separate credential we store.

*Reference `lib/services/biometric_service.dart` and the “local only, no server” comment.*

### 4.4 Structure and maintainability

- Clear separation: **storage** (secure_auth_storage), **database** (migration + API), **services** (pin_service, biometric_service), **pages**, **widgets**, **theme**.
- Easier to review, test, and adapt for the real banking app (e.g. plug in real backend for email/password).

---

## 5. Tech Stack (30 sec)

- **Flutter** (current stable).
- **Auth / security:**  
  `argon2`, `flutter_secure_storage`, `local_auth`.
- **Local DB:** `sqflite` only for migration path; no sensitive auth in SQLite going forward.
- **UI:** Custom theme, reusable widgets (e.g. gradient button, PIN input).

---

## 6. What You’d Do Next (Production / Real Banking App)

Shows you think beyond the practice app and care about production standards.

- **Backend:** Replace mocked email/password with real API; keep M-PIN/biometrics as **local** unlock only.
- **Compliance:** Align with company/regulatory requirements (e.g. session timeout, audit logging, no sensitive data in logs).
- **Hardening:** Certificate pinning, secure backup behavior (e.g. exclude auth data from backup), and optional attestation/device binding if required.
- **UX:** Rate limiting on PIN attempts, “Forgot PIN” flow tied to backend, and consistent error handling and accessibility.

---

## 7. Closing

- **Summary:** “I used this project to learn Flutter and to implement auth and security patterns that matter for a banking app: secure storage, hashed M-PIN, constant-time comparison, and local-only biometrics.”
- **Ask:** “I’m ready to apply this on the real banking app frontend and to work with the team on security and UX standards. Happy to go deeper on any part in code or in design.”

---

## Quick Checklist Before You Present

- [ ] App runs without errors on your demo device/simulator.
- [ ] You’ve done the full flow once (onboarding → sign in → set M-PIN → home → logout → sign in with M-PIN).
- [ ] You know where these files are: `secure_auth_storage.dart`, `pin_service.dart`, `biometric_service.dart`, `app_database.dart`.
- [ ] You’ve decided: show code on screen (2–3 key files) or only describe; either is fine.
- [ ] You’re ready to say what’s mocked (e.g. email/password) and what’s real (M-PIN, secure storage, biometrics).

---

## One-Slide Summary (Optional)

If you use one slide, you could put:

- **Title:** Flutter practice app — auth & security for banking
- **Bullets:**
  - Onboarding → Sign in (M-PIN / biometrics / email)
  - M-PIN: Argon2 hash + salt, constant-time verify, stored in Keychain/Keystore
  - Biometrics: local-only preference; no biometric data stored
  - Clean structure: storage, services, pages, theme — ready to extend for real backend

Good luck with your presentation.
