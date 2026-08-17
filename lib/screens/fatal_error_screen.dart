import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

class FatalErrorScreen extends StatelessWidget {
  const FatalErrorScreen({super.key, this.details});

  /// Optional extra detail. When null, the generic bootstrap message is shown.
  final String? details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.warning_amber_rounded, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).fatalErrorTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    details ??
                        AppLocalizations.of(context).fatalErrorBootstrapDetails,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
