import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/services/privacy_lock_service.dart';

void main() {
  group('PrivacyLockService', () {
    late PrivacyLockService service;

    setUp(() {
      service = PrivacyLockService();
    });

    test('generates valid non-empty base64 salt', () {
      final String salt1 = service.generateSalt();
      final String salt2 = service.generateSalt();

      expect(salt1, isNotEmpty);
      expect(salt2, isNotEmpty);
      expect(salt1, isNot(equals(salt2)));
    });

    test('hashes PIN deterministically given the same salt', () {
      final String salt = service.generateSalt();
      final String hash1 = service.hashPin('1234', salt);
      final String hash2 = service.hashPin('1234', salt);

      expect(hash1, equals(hash2));
    });

    test('hashes PIN differently for different salts or different PINs', () {
      final String salt1 = service.generateSalt();
      final String salt2 = service.generateSalt();

      final String hash1 = service.hashPin('1234', salt1);
      final String hash2 = service.hashPin('1234', salt2);
      final String hash3 = service.hashPin('5678', salt1);

      expect(hash1, isNot(equals(hash2)));
      expect(hash1, isNot(equals(hash3)));
    });

    test('verifies correct PIN and rejects incorrect PIN', () {
      final String salt = service.generateSalt();
      final String hash = service.hashPin('123456', salt);

      final bool valid = service.verifyPin(
        pin: '123456',
        saltBase64: salt,
        storedHashBase64: hash,
      );

      final bool invalid = service.verifyPin(
        pin: '000000',
        saltBase64: salt,
        storedHashBase64: hash,
      );

      expect(valid, isTrue);
      expect(invalid, isFalse);
    });
  });
}
