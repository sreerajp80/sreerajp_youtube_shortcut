import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

/// One feature item displayed on the Features screen.
class _AppFeature {
  const _AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.highlights,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;
}

/// A category grouping related features.
class _FeatureCategory {
  const _FeatureCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.features,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<_AppFeature> features;
}

/// Lists all features of SreerajP YouTube Shortcuts, grouped by category.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  List<_FeatureCategory> _buildCategories(AppLocalizations l10n) {
    return <_FeatureCategory>[
      _FeatureCategory(
        name: l10n.featuresCatQuickLaunch,
        subtitle: l10n.featuresCatQuickLaunchSub,
        icon: Icons.play_circle_outline_rounded,
        features: <_AppFeature>[
          _AppFeature(
            title: l10n.featureInstantLaunchTitle,
            description: l10n.featureInstantLaunchDesc,
            icon: Icons.bolt_rounded,
            highlights: const <String>[
              'Explicit Android Intent',
              'Zero Browser Delay',
              'Direct App Launch',
            ],
          ),
          _AppFeature(
            title: l10n.featureCanonicalUrlTitle,
            description: l10n.featureCanonicalUrlDesc,
            icon: Icons.link_rounded,
            highlights: const <String>[
              'URL Sanitization',
              'Strip Tracking Params',
              'youtu.be Support',
            ],
          ),
          _AppFeature(
            title: l10n.featureHandleRoutingTitle,
            description: l10n.featureHandleRoutingDesc,
            icon: Icons.alternate_email_rounded,
            highlights: const <String>[
              '@Handle Format',
              '/live URL Auto-Build',
              'Shape Validation',
            ],
          ),
          _AppFeature(
            title: l10n.featureMultiTypeTitle,
            description: l10n.featureMultiTypeDesc,
            icon: Icons.category_outlined,
            highlights: const <String>[
              'Videos',
              'Shorts',
              'Playlists',
              'Channels',
            ],
          ),
          _AppFeature(
            title: l10n.featureClipboardPasteTitle,
            description: l10n.featureClipboardPasteDesc,
            icon: Icons.content_paste_rounded,
            highlights: const <String>[
              'Automatic Detection',
              '1-Tap Paste',
              'Local-Only Read',
            ],
          ),
        ],
      ),
      _FeatureCategory(
        name: l10n.featuresCatOrganization,
        subtitle: l10n.featuresCatOrganizationSub,
        icon: Icons.dashboard_customize_outlined,
        features: <_AppFeature>[
          _AppFeature(
            title: l10n.featureThemePresetsTitle,
            description: l10n.featureThemePresetsDesc,
            icon: Icons.palette_outlined,
            highlights: const <String>[
              'AMOLED Pitch Black',
              'Cyberpunk Neon',
              'Warm Sepia',
              'Forest Dark',
            ],
          ),
          _AppFeature(
            title: l10n.featureCustomColorsTitle,
            description: l10n.featureCustomColorsDesc,
            icon: Icons.color_lens_outlined,
            highlights: const <String>[
              '11 Accent Colors',
              'Card Distinction',
              'Custom Themes',
            ],
          ),
          _AppFeature(
            title: l10n.featureCustomIconsTitle,
            description: l10n.featureCustomIconsDesc,
            icon: Icons.star_outline_rounded,
            highlights: const <String>[
              '14 Themed Icons',
              'Auto Initials',
              'Visual Hierarchy',
            ],
          ),
          _AppFeature(
            title: l10n.featureTagsSearchTitle,
            description: l10n.featureTagsSearchDesc,
            icon: Icons.label_outline_rounded,
            highlights: const <String>[
              'Tag Filtering',
              'Instant Search',
              'Custom Categories',
            ],
          ),
          _AppFeature(
            title: l10n.featureReorderLayoutsTitle,
            description: l10n.featureReorderLayoutsDesc,
            icon: Icons.swap_vert_rounded,
            highlights: const <String>[
              'Manual Reorder',
              'Grid View',
              'List View',
              'Sort Options',
            ],
          ),
        ],
      ),
      _FeatureCategory(
        name: l10n.featuresCatQrSystem,
        subtitle: l10n.featuresCatQrSystemSub,
        icon: Icons.qr_code_2_rounded,
        features: <_AppFeature>[
          _AppFeature(
            title: l10n.featureAirGappedQrTitle,
            description: l10n.featureAirGappedQrDesc,
            icon: Icons.qr_code_rounded,
            highlights: const <String>[
              'Air-Gapped Payload',
              'Zero Network Needed',
              'Universal Scanner Support',
            ],
          ),
          _AppFeature(
            title: l10n.featureAnimatedQrBackupTitle,
            description: l10n.featureAnimatedQrBackupDesc,
            icon: Icons.motion_photos_on_outlined,
            highlights: const <String>[
              'Multi-Frame Streaming',
              'Fountain QR Codes',
              'Instant Device Migration',
            ],
          ),
          _AppFeature(
            title: l10n.featureOfflineQrScannerTitle,
            description: l10n.featureOfflineQrScannerDesc,
            icon: Icons.qr_code_scanner_rounded,
            highlights: const <String>[
              'On-Device ML Vision',
              'Flash & Camera Switch',
              'Gallery Image Scan',
            ],
          ),
        ],
      ),
      _FeatureCategory(
        name: l10n.featuresCatPrivacy,
        subtitle: l10n.featuresCatPrivacySub,
        icon: Icons.security_rounded,
        features: <_AppFeature>[
          _AppFeature(
            title: l10n.featurePinBiometricsTitle,
            description: l10n.featurePinBiometricsDesc,
            icon: Icons.fingerprint_rounded,
            highlights: const <String>[
              '4-6 Digit Security PIN',
              'Biometrics / Face Unlock',
              'App Startup Gate',
            ],
          ),
          _AppFeature(
            title: l10n.featurePrivateVaultTitle,
            description: l10n.featurePrivateVaultDesc,
            icon: Icons.lock_outline_rounded,
            highlights: const <String>[
              'Hidden from List',
              'Gated by PIN/Biometric',
              'Encrypted Flag',
            ],
          ),
          _AppFeature(
            title: l10n.featureStrictOfflineTitle,
            description: l10n.featureStrictOfflineDesc,
            icon: Icons.wifi_off_rounded,
            highlights: const <String>[
              'No INTERNET Permission',
              'Zero Tracking / Ads',
              'Strict Local Storage',
            ],
          ),
        ],
      ),
      _FeatureCategory(
        name: l10n.featuresCatBackup,
        subtitle: l10n.featuresCatBackupSub,
        icon: Icons.import_export_rounded,
        features: <_AppFeature>[
          _AppFeature(
            title: l10n.featureJsonExportImportTitle,
            description: l10n.featureJsonExportImportDesc,
            icon: Icons.file_present_rounded,
            highlights: const <String>[
              'Standard JSON Schema',
              'Storage Access Framework',
              'No Broad Storage Permission',
            ],
          ),
          _AppFeature(
            title: l10n.featureEncryptedBackupTitle,
            description: l10n.featureEncryptedBackupDesc,
            icon: Icons.enhanced_encryption_rounded,
            highlights: const <String>[
              'AES-256-GCM',
              'PBKDF2 Key Derivation',
              'Password Protection',
            ],
          ),
          _AppFeature(
            title: l10n.featureMergeReplaceModesTitle,
            description: l10n.featureMergeReplaceModesDesc,
            icon: Icons.merge_type_rounded,
            highlights: const <String>[
              'Safe Merge Mode',
              'Clean Full Restore',
              'Duplicate Detection',
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<_FeatureCategory> categories = _buildCategories(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.featuresScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _buildHeaderCard(theme, l10n),
          const SizedBox(height: 20),
          for (final _FeatureCategory category in categories) ...<Widget>[
            _buildCategoryHeader(theme, category),
            const SizedBox(height: 10),
            _buildCategoryCard(theme, category),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
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
                Icons.stars_rounded,
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
                    l10n.featuresHeroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.featuresHeroBody,
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

  Widget _buildCategoryHeader(ThemeData theme, _FeatureCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(category.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                category.name.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            category.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme, _FeatureCategory category) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < category.features.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            _buildFeatureTile(theme, category.features[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureTile(ThemeData theme, _AppFeature feature) {
    final Color accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  feature.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (feature.highlights.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: feature.highlights.map((String h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
