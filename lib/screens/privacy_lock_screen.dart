import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/state/privacy_lock_store.dart';

class PrivacyLockScreen extends StatefulWidget {
  const PrivacyLockScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onUnlocked,
  });

  /// Falls back to the app-locked title when null.
  final String? title;

  /// Falls back to the standard PIN instruction when null.
  final String? subtitle;
  final VoidCallback? onUnlocked;

  @override
  State<PrivacyLockScreen> createState() => _PrivacyLockScreenState();
}

class _PrivacyLockScreenState extends State<PrivacyLockScreen> {
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyPress(String val) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _errorMessage = null;
      _enteredPin += val;
    });
    if (_enteredPin.length >= 4) {
      _attemptUnlock();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _onClear() {
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
    });
  }

  void _attemptUnlock() {
    final PrivacyLockStore lockStore = context.read<PrivacyLockStore>();
    final bool valid = lockStore.verifyPin(_enteredPin);
    if (valid) {
      lockStore.unlockAppWithPin(_enteredPin);
      lockStore.unlockPrivateVaultWithPin(_enteredPin);
      widget.onUnlocked?.call();
    } else {
      if (_enteredPin.length >= 4) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).privacyLockIncorrectPin;
          _enteredPin = '';
        });
      }
    }
  }

  Future<void> _attemptBiometric() async {
    final PrivacyLockStore lockStore = context.read<PrivacyLockStore>();
    final bool success = await lockStore.unlockAppWithBiometric();
    if (success) {
      widget.onUnlocked?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PrivacyLockStore lockStore = context.watch<PrivacyLockStore>();
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title ?? l10n.privacyLockAppLockedTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.subtitle ?? l10n.privacyLockSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(6, (int index) {
                final bool filled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                );
              }),
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const Spacer(),
            _buildNumpad(context, lockStore.isBiometricAvailable),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(BuildContext context, bool showBiometric) {
    final ThemeData theme = Theme.of(context);

    Widget numButton(String label) {
      return Container(
        margin: const EdgeInsets.all(8),
        width: 72,
        height: 72,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          onPressed: () => _onKeyPress(label),
          child: Text(
            label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[numButton('1'), numButton('2'), numButton('3')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[numButton('4'), numButton('5'), numButton('6')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[numButton('7'), numButton('8'), numButton('9')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(8),
              width: 72,
              height: 72,
              child: showBiometric
                  ? IconButton(
                      icon: const Icon(Icons.fingerprint, size: 36),
                      onPressed: _attemptBiometric,
                      tooltip: AppLocalizations.of(
                        context,
                      ).privacyLockBiometricTooltip,
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: _onClear,
                      tooltip: AppLocalizations.of(
                        context,
                      ).privacyLockClearTooltip,
                    ),
            ),
            numButton('0'),
            Container(
              margin: const EdgeInsets.all(8),
              width: 72,
              height: 72,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onBackspace,
                tooltip: AppLocalizations.of(
                  context,
                ).privacyLockBackspaceTooltip,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
