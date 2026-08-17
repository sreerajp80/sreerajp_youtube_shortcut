import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

/// The frosted-glass floating action button that opens the add form.
class GlassAddFab extends StatelessWidget {
  const GlassAddFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color accent = isDark
        ? const Color(0xFF2DD4BF)
        : const Color(0xFFD73A23);
    const double size = 64;
    const BorderRadius radius = BorderRadius.all(Radius.circular(22));

    final Color fillTop = isDark
        ? accent.withValues(alpha: 0.28)
        : accent.withValues(alpha: 0.22);
    final Color fillBottom = isDark
        ? accent.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.55);
    final Color borderColor = isDark
        ? accent.withValues(alpha: 0.60)
        : accent.withValues(alpha: 0.45);
    final Color innerHighlight = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.85);

    return Tooltip(
      message: l10n.homeAddTooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.45 : 0.32),
                blurRadius: 26,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              if (isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    colors: <Color>[fillTop, fillBottom],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 1,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.transparent,
                              innerHighlight,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: radius,
                        onTap: onPressed,
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: accent,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
