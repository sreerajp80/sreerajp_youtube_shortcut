import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';

class PrivacyLockService {
  PrivacyLockService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  static const int pbkdf2Iterations = 10000;
  static const int keySizeBytes = 32;
  static const int saltSizeBytes = 16;
  static const int hmacBlockSize = 64;

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        return false;
      }
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric({
    String localizedReason = 'Authenticate to access YT Shortcuts',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  String generateSalt() {
    final Random random = Random.secure();
    final Uint8List bytes = Uint8List(saltSizeBytes);
    for (int i = 0; i < saltSizeBytes; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  String hashPin(String pin, String saltBase64) {
    final Uint8List salt = base64Decode(saltBase64);
    final PBKDF2KeyDerivator pbkdf2 = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), hmacBlockSize),
    )..init(Pbkdf2Parameters(salt, pbkdf2Iterations, keySizeBytes));
    
    final Uint8List key = pbkdf2.process(Uint8List.fromList(utf8.encode(pin)));
    return base64Encode(key);
  }

  bool verifyPin({
    required String pin,
    required String saltBase64,
    required String storedHashBase64,
  }) {
    if (pin.isEmpty || saltBase64.isEmpty || storedHashBase64.isEmpty) {
      return false;
    }
    final String computed = hashPin(pin, saltBase64);
    return computed == storedHashBase64;
  }
}
