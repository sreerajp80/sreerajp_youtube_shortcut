import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/model_labels.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';

/// One shortcut, drawn as a launcher card in the grid or list.
class ShortcutCard extends StatelessWidget {
  const ShortcutCard({
    super.key,
    required this.entry,
    required this.isLaunching,
    required this.isReorderMode,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onOpen,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  final ShortcutEntry entry;
  final bool isLaunching;
  final bool isReorderMode;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color typeAccent = entry.targetType.accent(theme.brightness);
    final Color? customColor = _parseColorHex(entry.customColorHex);
    final Color avatarColor = customColor ?? _avatarColorFor(entry.id);
    final String avatarLetters = _avatarLettersFor(entry.name);
    final IconData? customIcon = _parseIconData(entry.customIconName);
    const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(20));

    const Color darkBaseTop = Color(0xFF12181A);
    const Color darkBaseBottom = Color(0xFF0A0E10);
    const Color lightBaseTop = Color(0xFFFFFFFF);
    const Color lightBaseBottom = Color(0xFFF6F1EE);

    final Color cardTopColor = isDark
        ? Color.alphaBlend(typeAccent.withValues(alpha: 0.18), darkBaseTop)
        : Color.alphaBlend(typeAccent.withValues(alpha: 0.08), lightBaseTop);
    final Color cardBottomColor = isDark
        ? Color.alphaBlend(typeAccent.withValues(alpha: 0.05), darkBaseBottom)
        : Color.alphaBlend(typeAccent.withValues(alpha: 0.03), lightBaseBottom);
    final Color baseBorderColor = typeAccent.withValues(
      alpha: isDark ? 0.40 : 0.28,
    );
    final Color borderColor = isSelected
        ? theme.colorScheme.primary
        : baseBorderColor;
    final double borderWidth = isSelected ? 2.0 : 1.0;

    final List<BoxShadow> cardShadows = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: typeAccent.withValues(alpha: 0.22),
              offset: const Offset(0, 6),
              blurRadius: 22,
              spreadRadius: 0.5,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              offset: const Offset(0, 10),
              blurRadius: 18,
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: typeAccent.withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 22,
              spreadRadius: 0.5,
            ),
            const BoxShadow(
              color: Color(0x14A56E5A),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
            const BoxShadow(
              color: Color(0xC9FFFFFF),
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ];

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: cardBorderRadius,
          boxShadow: cardShadows,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: cardBorderRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: cardBorderRadius,
              border: Border.fromBorderSide(
                BorderSide(color: borderColor, width: borderWidth),
              ),
              gradient: LinearGradient(
                colors: <Color>[cardTopColor, cardBottomColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: cardBorderRadius,
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.white.withValues(
                              alpha: isDark ? 0.10 : 0.45,
                            ),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: const Alignment(0.5, 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: cardBorderRadius,
                  onTap: (isLaunching || isReorderMode)
                      ? null
                      : (isSelectionMode ? onToggleSelect : onOpen),
                  onLongPress: (isLaunching || isReorderMode)
                      ? null
                      : onLongPress,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: avatarColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: avatarColor.withValues(
                                      alpha: isDark ? 0.45 : 0.30,
                                    ),
                                    offset: const Offset(0, 3),
                                    blurRadius: 12,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: customIcon != null
                                    ? Icon(
                                        customIcon,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : Text(
                                        avatarLetters,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.2,
                                          height: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  entry.name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      typeAccent.withValues(
                                        alpha: isDark ? 0.36 : 0.22,
                                      ),
                                      typeAccent.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: typeAccent.withValues(
                                      alpha: isDark ? 0.62 : 0.30,
                                    ),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: typeAccent.withValues(
                                        alpha: isDark ? 0.26 : 0.12,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  entry.targetType.label(l10n),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: typeAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              for (final String tag in entry.tags)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer
                                        .withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !isLaunching,
                    child: AnimatedOpacity(
                      opacity: isLaunching ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: cardBorderRadius,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: isLaunching
                                ? const CircularProgressIndicator.adaptive(
                                    strokeWidth: 2.5,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isSelectionMode && !isReorderMode)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: entry.isFavorite
                          ? l10n.homeUnpinFavorite
                          : l10n.homePinFavorite,
                      icon: Icon(
                        entry.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: entry.isFavorite
                            ? Colors.amber
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.45,
                              ),
                      ),
                      onPressed: () {
                        context.read<ShortcutStore>().toggleFavorite(entry.id);
                      },
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IgnorePointer(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const List<Color> _avatarPalette = <Color>[
  Color(0xFFD73A23),
  Color(0xFFEA580C),
  Color(0xFFCA8A04),
  Color(0xFF65A30D),
  Color(0xFF059669),
  Color(0xFF0D9488),
  Color(0xFF0891B2),
  Color(0xFF2563EB),
  Color(0xFF6366F1),
  Color(0xFF7C3AED),
  Color(0xFFC026D3),
  Color(0xFFDB2777),
];

Color _avatarColorFor(String seed) {
  int hash = 0;
  for (final int unit in seed.codeUnits) {
    hash = (hash * 31 + unit) & 0x7FFFFFFF;
  }
  return _avatarPalette[hash % _avatarPalette.length];
}

String _avatarLettersFor(String name) {
  final List<String> words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) {
    return '?';
  }
  if (words.length == 1) {
    final String word = words.first;
    final String taken = word.length >= 2 ? word.substring(0, 2) : word;
    return taken.toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

Color? _parseColorHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final String clean = hex.replaceAll('#', '');
  if (clean.length == 6) {
    final int? val = int.tryParse('FF$clean', radix: 16);
    if (val != null) return Color(val);
  }
  return null;
}

IconData? _parseIconData(String? name) {
  if (name == null || name.isEmpty) return null;
  const Map<String, IconData> icons = <String, IconData>{
    'play': Icons.play_arrow_rounded,
    'star': Icons.star_rounded,
    'music': Icons.music_note_rounded,
    'game': Icons.sports_esports_rounded,
    'code': Icons.code_rounded,
    'tv': Icons.tv_rounded,
    'flame': Icons.local_fire_department_rounded,
    'headphones': Icons.headphones_rounded,
    'bookmark': Icons.bookmark_rounded,
    'video': Icons.video_library_rounded,
    'heart': Icons.favorite_rounded,
    'lightning': Icons.bolt_rounded,
    'sparkles': Icons.auto_awesome_rounded,
  };
  return icons[name];
}

/// Accent colour per target type, tuned for each brightness.
extension on ShortcutTargetType {
  Color accent(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    const Color lightAccent = Color(0xFFD73A23);

    switch (this) {
      case ShortcutTargetType.video:
        return isDark ? const Color(0xFFFF8A65) : lightAccent;
      case ShortcutTargetType.shortVideo:
        return isDark ? const Color(0xFFFFB74D) : lightAccent;
      case ShortcutTargetType.playlist:
        return isDark ? const Color(0xFFBCAAA4) : lightAccent;
      case ShortcutTargetType.channel:
        return isDark ? const Color(0xFF4DB6AC) : lightAccent;
    }
  }
}
