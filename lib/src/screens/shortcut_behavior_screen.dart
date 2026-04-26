import 'package:flutter/material.dart';

class ShortcutBehaviorScreen extends StatelessWidget {
  const ShortcutBehaviorScreen({super.key});

  static const List<_FallbackCase> _fallbackCases = <_FallbackCase>[
    _FallbackCase(
      state: 'Currently streaming',
      result: 'Opens the live watch page (the intended outcome).',
    ),
    _FallbackCase(
      state: 'Has an upcoming or scheduled stream',
      result:
          'Opens the upcoming stream page with the countdown and waiting room.',
    ),
    _FallbackCase(
      state: 'Has past live streams only',
      result:
          "Often opens the most recent finished live stream as a video, or the channel's Live tab.",
    ),
    _FallbackCase(
      state: 'Has never gone live',
      result: "Falls back to the channel's home page.",
    ),
    _FallbackCase(
      state: 'Handle is invalid or misspelled',
      result: "YouTube shows its 'page not available' state inside the app.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Channel handles')),
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
                    "How '@' shortcuts work",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'When you save a shortcut using a bare channel handle '
                    '(for example "@JanamTVMedia" or "JanamTVMedia"), the app '
                    'rewrites it to the YouTube live URL:',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  _UrlPill(text: 'https://www.youtube.com/@<handle>/live'),
                  const SizedBox(height: 12),
                  Text(
                    "YouTube uses this URL convention to route viewers to a "
                    "channel's currently-live stream. Tapping the shortcut "
                    "sends this URL to the YouTube app, which then decides "
                    'what to show.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: "If the channel isn't live"),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'This app stays offline and cannot check live status in '
                    'advance — it just hands the URL to YouTube. What you '
                    "see depends on YouTube's handling for that channel:",
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  ..._fallbackCases.map(
                    (_FallbackCase entry) => _FallbackRow(entry: entry),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "YouTube can change these behaviours at any time; the app "
                    'has no control over what loads after the URL is opened.',
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
          const _SectionTitle(title: 'Good to know'),
          const SizedBox(height: 10),
          const _NoteCard(
            title: 'No connectivity check',
            body:
                'This app is fully offline and never reaches the internet. '
                'It cannot verify in advance whether a handle exists or is '
                'live. Handles are validated only for shape (3-30 letters, '
                'digits, dot, dash, or underscore).',
          ),
          const SizedBox(height: 12),
          const _NoteCard(
            title: 'To open the channel page instead of live',
            body:
                'Bare handles always route to /live. To pin a shortcut that '
                'opens the channel home page, save the full URL — for '
                'example: https://www.youtube.com/@JanamTVMedia',
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
