import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

class ShortcutBehaviorScreen extends StatelessWidget {
  const ShortcutBehaviorScreen({super.key});

  /// What YouTube tends to open for each channel state, worst case to best.
  List<_FallbackCase> _fallbackCases(AppLocalizations l10n) {
    return <_FallbackCase>[
      _FallbackCase(
        state: l10n.behaviorCaseStreamingState,
        result: l10n.behaviorCaseStreamingResult,
      ),
      _FallbackCase(
        state: l10n.behaviorCaseUpcomingState,
        result: l10n.behaviorCaseUpcomingResult,
      ),
      _FallbackCase(
        state: l10n.behaviorCasePastState,
        result: l10n.behaviorCasePastResult,
      ),
      _FallbackCase(
        state: l10n.behaviorCaseNeverState,
        result: l10n.behaviorCaseNeverResult,
      ),
      _FallbackCase(
        state: l10n.behaviorCaseInvalidState,
        result: l10n.behaviorCaseInvalidResult,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.behaviorScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.behaviorHowItWorksTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.behaviorHowItWorksBody,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  _UrlPill(text: l10n.behaviorLiveUrlPattern),
                  const SizedBox(height: 12),
                  Text(
                    l10n.behaviorRoutingBody,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.behaviorNotLiveSection),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.behaviorNotLiveIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  ..._fallbackCases(
                    l10n,
                  ).map((_FallbackCase entry) => _FallbackRow(entry: entry)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.behaviorCasesFootnote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.behaviorGoodToKnowSection),
          const SizedBox(height: 10),
          _NoteCard(
            title: l10n.behaviorNoConnectivityTitle,
            body: l10n.behaviorNoConnectivityBody,
          ),
          const SizedBox(height: 12),
          _NoteCard(
            title: l10n.behaviorChannelPageTitle,
            body: l10n.behaviorChannelPageBody,
          ),
        ],
      ),
    );
  }
}

class _UrlPill extends StatelessWidget {
  const _UrlPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          height: 1.3,
        ),
      ),
    );
  }
}

class _FallbackRow extends StatelessWidget {
  const _FallbackRow({required this.entry});

  final _FallbackCase entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            entry.state,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.result,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _FallbackCase {
  const _FallbackCase({required this.state, required this.result});

  final String state;
  final String result;
}
