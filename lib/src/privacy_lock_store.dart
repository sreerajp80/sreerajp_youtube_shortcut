import 'package:flutter/widgets.dart';

import 'services/privacy_lock_service.dart';
import 'shortcut_repository.dart';

class PrivacyLockStore extends ChangeNotifier {
  PrivacyLockStore({
    required this.repository,
    PrivacyLockService? privacyLockService,
  }) : privacyLockService = privacyLockService ?? PrivacyLockService();

  final ShortcutRepository repository;
  final PrivacyLockService privacyLockService;

  bool _isLoading = false;
  bool _appLockEnabled = false;
  bool _privateLockEnabled = false;
  bool _isAppLocked = false;
  bool _isPrivateVaultUnlocked = false;
  String? _pinHash;
  String? _pinSalt;
  bool _isBiometricAvailable = false;

  bool get isLoading => _isLoading;
  bool get appLockEnabled => _appLockEnabled;
  bool get privateLockEnabled => _privateLockEnabled;
  bool get isAppLocked => _isAppLocked;
  bool get isPrivateVaultUnlocked => _isPrivateVaultUnlocked;
  bool get hasPinConfigured => _pinHash != null && _pinHash!.isNotEmpty;
  bool get isBiometricAvailable => _isBiometricAvailable;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appLockEnabled = await repository.loadAppLockEnabled();
      _privateLockEnabled = await repository.loadPrivateLockEnabled();
      _pinHash = await repository.loadPinHash();
      _pinSalt = await repository.loadPinSalt();
      _isBiometricAvailable = await privacyLockService.isBiometricAvailable();

      if (_appLockEnabled && hasPinConfigured) {
        _isAppLocked = true;
      } else {
        _isAppLocked = false;
      }

      if (_privateLockEnabled && hasPinConfigured) {
        _isPrivateVaultUnlocked = false;
      } else {
        _isPrivateVaultUnlocked = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setupPin(String newPin) async {
    if (newPin.trim().length < 4) {
      return false;
    }
    final String salt = privacyLockService.generateSalt();
    final String hash = privacyLockService.hashPin(newPin, salt);
    await repository.savePinSalt(salt);
    await repository.savePinHash(hash);
    _pinSalt = salt;
    _pinHash = hash;
    notifyListeners();
    return true;
  }

  bool verifyPin(String pin) {
    if (!hasPinConfigured || _pinSalt == null || _pinHash == null) {
      return false;
    }
    return privacyLockService.verifyPin(
      pin: pin,
      saltBase64: _pinSalt!,
      storedHashBase64: _pinHash!,
    );
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (!verifyPin(oldPin)) {
      return false;
    }
    return setupPin(newPin);
  }

  Future<void> clearPin() async {
    await repository.savePinHash(null);
    await repository.savePinSalt(null);
    await repository.saveAppLockEnabled(false);
    await repository.savePrivateLockEnabled(false);
    _pinHash = null;
    _pinSalt = null;
    _appLockEnabled = false;
    _privateLockEnabled = false;
    _isAppLocked = false;
    _isPrivateVaultUnlocked = true;
    notifyListeners();
  }

  Future<bool> setAppLockEnabled(bool enabled) async {
    if (enabled && !hasPinConfigured) {
      return false;
    }
    await repository.saveAppLockEnabled(enabled);
    _appLockEnabled = enabled;
    if (!enabled) {
      _isAppLocked = false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> setPrivateLockEnabled(bool enabled) async {
    if (enabled && !hasPinConfigured) {
      return false;
    }
    await repository.savePrivateLockEnabled(enabled);
    _privateLockEnabled = enabled;
    if (!enabled) {
      _isPrivateVaultUnlocked = true;
    } else {
      _isPrivateVaultUnlocked = false;
    }
    notifyListeners();
    return true;
  }

  void unlockAppWithPin(String pin) {
    if (verifyPin(pin)) {
      _isAppLocked = false;
      notifyListeners();
    }
  }

  Future<bool> unlockAppWithBiometric() async {
    if (!_isBiometricAvailable) return false;
    final bool success = await privacyLockService.authenticateWithBiometric(
      localizedReason: 'Unlock YT Shortcuts',
    );
    if (success) {
      _isAppLocked = false;
      notifyListeners();
    }
    return success;
  }

  bool unlockPrivateVaultWithPin(String pin) {
    if (verifyPin(pin)) {
      _isPrivateVaultUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> unlockPrivateVaultWithBiometric() async {
    if (!_isBiometricAvailable) return false;
    final bool success = await privacyLockService.authenticateWithBiometric(
      localizedReason: 'Unlock private shortcuts',
    );
    if (success) {
      _isPrivateVaultUnlocked = true;
      notifyListeners();
    }
    return success;
  }

  void lockApp() {
    if (_appLockEnabled && hasPinConfigured) {
      _isAppLocked = true;
      notifyListeners();
    }
  }

  void lockPrivateVault() {
    if (_privateLockEnabled && hasPinConfigured) {
      _isPrivateVaultUnlocked = false;
      notifyListeners();
    }
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      lockApp();
      lockPrivateVault();
    }
  }
}
