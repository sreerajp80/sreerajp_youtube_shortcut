import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/privacy_lock_store.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_repository.dart';

void main() {
  group('PrivacyLockStore', () {
    late MemoryShortcutRepository repository;
    late PrivacyLockStore store;

    setUp(() {
      repository = MemoryShortcutRepository();
      store = PrivacyLockStore(repository: repository);
    });

    test('initial state has no PIN configured and app unlocked', () async {
      await store.load();
      expect(store.hasPinConfigured, isFalse);
      expect(store.appLockEnabled, isFalse);
      expect(store.privateLockEnabled, isFalse);
      expect(store.isAppLocked, isFalse);
      expect(store.isPrivateVaultUnlocked, isTrue);
    });

    test('setting up PIN configures PIN and allows toggling app lock', () async {
      await store.load();
      final bool pinSet = await store.setupPin('1234');
      expect(pinSet, isTrue);
      expect(store.hasPinConfigured, isTrue);

      final bool enabled = await store.setAppLockEnabled(true);
      expect(enabled, isTrue);
      expect(store.appLockEnabled, isTrue);
    });

    test('unlocks app with correct PIN', () async {
      await store.load();
      await store.setupPin('4321');
      await store.setAppLockEnabled(true);

      store.lockApp();
      expect(store.isAppLocked, isTrue);

      store.unlockAppWithPin('4321');
      expect(store.isAppLocked, isFalse);
    });

    test('locks app and private vault on lifecycle paused state', () async {
      await store.load();
      await store.setupPin('1234');
      await store.setAppLockEnabled(true);
      await store.setPrivateLockEnabled(true);

      expect(store.isAppLocked, isFalse);
      store.handleAppLifecycleState(AppLifecycleState.paused);

      expect(store.isAppLocked, isTrue);
      expect(store.isPrivateVaultUnlocked, isFalse);
    });

    test('clearing PIN resets all lock settings', () async {
      await store.load();
      await store.setupPin('1234');
      await store.setAppLockEnabled(true);
      await store.setPrivateLockEnabled(true);

      await store.clearPin();

      expect(store.hasPinConfigured, isFalse);
      expect(store.appLockEnabled, isFalse);
      expect(store.privateLockEnabled, isFalse);
      expect(store.isAppLocked, isFalse);
      expect(store.isPrivateVaultUnlocked, isTrue);
    });
  });
}
