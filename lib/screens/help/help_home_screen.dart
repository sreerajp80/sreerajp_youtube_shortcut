import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/backup_restore_help_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/getting_started_help_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/handles_routing_help_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/privacy_security_help_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/qr_sharing_help_screen.dart';

/// Help & user guides hub screen reached from Settings.
class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _buildHeaderCard(theme, l10n),
          const SizedBox(height: 20),
          _buildSectionHeader(
            theme,
            l10n.helpCatGettingStarted,
            Icons.explore_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.rocket_launch_outlined,
            title: l10n.helpTopicGettingStartedTitle,
            subtitle: l10n.helpTopicGettingStartedSub,
            onTap: () => _push(context, const GettingStartedHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.alternate_email_rounded,
            title: l10n.helpTopicHandlesTitle,
            subtitle: l10n.helpTopicHandlesSub,
            onTap: () => _push(context, const HandlesRoutingHelpScreen()),
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(
            theme,
            l10n.helpCatAdvancedSharing,
            Icons.sync_alt_rounded,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.qr_code_2_rounded,
            title: l10n.helpTopicQrSharingTitle,
            subtitle: l10n.helpTopicQrSharingSub,
            onTap: () => _push(context, const QrSharingHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.import_export_rounded,
            title: l10n.helpTopicBackupTitle,
            subtitle: l10n.helpTopicBackupSub,
            onTap: () => _push(context, const BackupRestoreHelpScreen()),
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(
            theme,
            l10n.helpCatPrivacySecurity,
            Icons.security_rounded,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.shield_outlined,
            title: l10n.helpTopicVaultTitle,
            subtitle: l10n.helpTopicVaultSub,
            onTap: () => _push(context, const PrivacySecurityHelpScreen()),
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(
            theme,
            l10n.helpCatFaq,
            Icons.question_answer_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.help_outline_rounded,
            title: l10n.helpTopicFaqTitle,
            subtitle: l10n.helpTopicFaqSub,
            onTap: () => _push(context, const FaqTroubleshootingHelpScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Widget _buildHeaderCard(ThemeData theme, AppLocalizations l10n) {
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: <Color>[
              primaryColor.withValues(alpha: 0.14),
              secondaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.helpHeroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpHeroBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
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
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
