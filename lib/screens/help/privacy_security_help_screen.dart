import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

class PrivacySecurityHelpScreen extends StatelessWidget {
  const PrivacySecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpVaultTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _buildHeroHeader(theme, l10n),
          const SizedBox(height: 20),
          _buildSectionHeader(theme, l10n.helpSecPinSetup, Icons.pin_outlined),
          const SizedBox(height: 10),
          _HelpCard(
            question: l10n.helpFaqPinSetup,
            answer: l10n.helpFaqPinSetupAns,
          ),
          const SizedBox(height: 10),
          _HelpCard(
            question: l10n.helpFaqBiometrics,
            answer: l10n.helpFaqBiometricsAns,
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(
            theme,
            l10n.helpSecPrivateVault,
            Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 10),
          _HelpCard(
            question: l10n.helpFaqPrivateShortcuts,
            answer: l10n.helpFaqPrivateShortcutsAns,
          ),
          const SizedBox(height: 10),
          _HelpCard(
            question: l10n.helpFaqOfflineGuarantee,
            answer: l10n.helpFaqOfflineGuaranteeAns,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.helpVaultIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              question,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
