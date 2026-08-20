import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/app/app_shell.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/repositories/shortcut_repository.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_launcher_service.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_url_formatter.dart';

void main() {
  testWidgets('renders the empty shortcut state', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.text('No shortcuts yet'), findsOneWidget);
    expect(find.text('Build your quick-launch shelf'), findsOneWidget);
    expect(find.byTooltip('Add shortcut'), findsOneWidget);
  });
  testWidgets(
    'shows full-url preview for handle input on add shortcut screen',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byTooltip('Add shortcut'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), 'asianetnews');
      await tester.pump();

      expect(
        find.text('Full URL: https://www.youtube.com/@asianetnews/live'),
        findsOneWidget,
      );
    },
  );

  testWidgets('hides full-url preview when a full url is entered', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Add shortcut'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(1),
      'https://www.youtube.com/@asianetnews/live',
    );
    await tester.pump();

    expect(find.textContaining('Full URL:'), findsNothing);
  });

  testWidgets('uses compact shortcut cards without url helper text', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'Janam TV',
      urlInput: 'https://youtu.be/abc123xyz',
    );

    await _pumpApp(tester, store: store);

    expect(find.text('Janam TV'), findsOneWidget);
    expect(find.text('Tap to open'), findsNothing);
    expect(
      find.text('https://www.youtube.com/watch?v=abc123xyz'),
      findsNothing,
    );
  });

  testWidgets('updates theme preference from Appearance screen', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await _pumpApp(tester, store: store);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.text('Visual Customization'), findsOneWidget);

    await tester.tap(find.text('Classic Dark'));
    await tester.pumpAndSettle();

    expect(store.themePreference, AppThemePreference.dark);

    await tester.tap(find.text('AMOLED Pure Black'));
    await tester.pumpAndSettle();

    expect(store.themePreference, AppThemePreference.amoled);
  });

  testWidgets('opens Features through Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Features'));
    await tester.pumpAndSettle();

    expect(find.text('Features'), findsOneWidget);
    expect(find.text('SreerajP YouTube Shortcuts Features'), findsOneWidget);
    expect(find.text('QUICK-LAUNCH & PLAYBACK'), findsOneWidget);

    final Finder orgHeader = find.text('ORGANIZATION & VISUAL STYLING');
    await tester.scrollUntilVisible(
      orgHeader,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(orgHeader, findsOneWidget);

    final Finder qrHeader = find.text('AIR-GAPPED QR CODE SYSTEM');
    await tester.scrollUntilVisible(
      qrHeader,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(qrHeader, findsOneWidget);
  });

  testWidgets('opens Help hub and navigates to help screens', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final Finder helpTile = find.text('Help & User Guides');
    await tester.scrollUntilVisible(
      helpTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(helpTile);
    await tester.pumpAndSettle();

    expect(find.text('Help & User Guides'), findsOneWidget);
    expect(find.text('SreerajP YouTube Shortcuts Help'), findsOneWidget);
    expect(find.text('Creating & Managing Shortcuts'), findsOneWidget);

    // Open Getting Started
    await tester.tap(find.text('Creating & Managing Shortcuts'));
    await tester.pumpAndSettle();

    expect(find.text('ADDING SHORTCUTS'), findsOneWidget);
    expect(find.text('How do I add a new shortcut?'), findsOneWidget);

    // Go back to Help hub
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Open FAQs & Troubleshooting
    final Finder faqTile = find.text('FAQs & Troubleshooting Guide');
    await tester.scrollUntilVisible(
      faqTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(faqTile);
    await tester.pumpAndSettle();

    expect(find.text('FAQs & Troubleshooting'), findsOneWidget);
    expect(find.text('GENERAL QUESTIONS'), findsOneWidget);
  });

  testWidgets('opens About through the new Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    final Finder aboutTile = find.text('About');
    await tester.scrollUntilVisible(
      aboutTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(aboutTile);
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('SreerajP YouTube Shortcuts'), findsOneWidget);
  });

  testWidgets('opens Permissions through the new Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final Finder permissionsTile = find.text('Permissions');
    await tester.scrollUntilVisible(
      permissionsTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(permissionsTile);
    await tester.pumpAndSettle();

    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('Explicit Permissions'), findsOneWidget);
    expect(find.text('Implicit Permissions / Declarations'), findsOneWidget);
  });

  testWidgets('opens Channel handles info through the Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final Finder handlesTile = find.text('Channel handles');
    await tester.scrollUntilVisible(
      handlesTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(handlesTile);
    await tester.pumpAndSettle();

    expect(find.text('Channel handles'), findsOneWidget);
    expect(find.text("How '@' shortcuts work"), findsOneWidget);
    expect(find.text("If the channel isn't live"), findsOneWidget);
  });

  testWidgets('long-press enters selection mode with the pressed card', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await store.addShortcut(
      nameInput: 'Music',
      urlInput: 'https://youtu.be/music12345',
    );
    await _pumpApp(tester, store: store);

    await tester.longPress(find.text('News'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.byTooltip('Add shortcut'), findsNothing);
    expect(find.byTooltip('Edit shortcut'), findsOneWidget);
    expect(find.byTooltip('Copy URL'), findsOneWidget);
    expect(find.byTooltip('Delete selected'), findsOneWidget);
    expect(find.byTooltip('Export selected'), findsOneWidget);
  });

  testWidgets('long-press no longer opens the per-card bottom sheet', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await _pumpApp(tester, store: store);

    await tester.longPress(find.text('News'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Edit shortcut'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Delete shortcut'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Copy URL'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Reorder shortcuts'), findsNothing);
  });

  testWidgets('tap toggles selection while in selection mode', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await store.addShortcut(
      nameInput: 'Music',
      urlInput: 'https://youtu.be/music12345',
    );
    await _pumpApp(tester, store: store);

    await tester.longPress(find.text('News'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.byTooltip('Edit shortcut'), findsNothing);
    expect(find.byTooltip('Copy URL'), findsNothing);

    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('1')),
      findsOneWidget,
    );

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Clear selection'), findsNothing);
    expect(find.byTooltip('Add shortcut'), findsOneWidget);
  });

  testWidgets('clear-selection button exits selection mode', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await _pumpApp(tester, store: store);

    await tester.longPress(find.text('News'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Clear selection'), findsNothing);
    expect(find.byTooltip('Add shortcut'), findsOneWidget);
  });

  testWidgets('bulk delete removes only the selected shortcuts', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await store.addShortcut(
      nameInput: 'Music',
      urlInput: 'https://youtu.be/music12345',
    );
    await store.addShortcut(
      nameInput: 'Talk',
      urlInput: 'https://youtu.be/talk12345',
    );
    await _pumpApp(tester, store: store);

    await tester.longPress(find.text('News'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Talk'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete selected'));
    await tester.pumpAndSettle();

    expect(find.text('Delete 2 shortcuts?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(store.entries.map((ShortcutEntry e) => e.name), <String>['Music']);
    expect(find.byTooltip('Clear selection'), findsNothing);
  });

  testWidgets('reorder mode is reachable from the home AppBar overflow menu', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await _pumpApp(tester, store: store);

    await tester.tap(find.byTooltip('Options'));
    await tester.pumpAndSettle();

    expect(find.text('Reorder shortcuts'), findsOneWidget);
    await tester.tap(find.text('Reorder shortcuts'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Reorder shortcuts'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets(
    'search bar filters shortcuts by name (substring, case-insensitive)',
    (WidgetTester tester) async {
      final ShortcutStore store = _buildStore();
      await store.addShortcut(
        nameInput: 'News Channel',
        urlInput: 'https://youtu.be/news12345',
      );
      await store.addShortcut(
        nameInput: 'Music Mix',
        urlInput: 'https://youtu.be/music12345',
      );
      await store.addShortcut(
        nameInput: 'Tech Talk',
        urlInput: 'https://youtu.be/talk12345',
      );
      await _pumpApp(tester, store: store);

      expect(find.text('News Channel'), findsOneWidget);
      expect(find.text('Music Mix'), findsOneWidget);
      expect(find.text('Tech Talk'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Search shortcuts'),
        'mUs',
      );
      await tester.pumpAndSettle();

      expect(find.text('Music Mix'), findsOneWidget);
      expect(find.text('News Channel'), findsNothing);
      expect(find.text('Tech Talk'), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      expect(find.text('News Channel'), findsOneWidget);
      expect(find.text('Music Mix'), findsOneWidget);
      expect(find.text('Tech Talk'), findsOneWidget);
    },
  );

  testWidgets('target-type chip filters narrow the visible shortcuts', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'Asianet',
      urlInput: 'https://www.youtube.com/@asianetnews/live',
    );
    await store.addShortcut(
      nameInput: 'Funny Clip',
      urlInput: 'https://youtu.be/clip12345',
    );
    await _pumpApp(tester, store: store);

    expect(find.text('Asianet'), findsOneWidget);
    expect(find.text('Funny Clip'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Channel'));
    await tester.pumpAndSettle();

    expect(find.text('Asianet'), findsOneWidget);
    expect(find.text('Funny Clip'), findsNothing);
  });

  testWidgets('shows the no-match state when filter excludes everything', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news12345',
    );
    await _pumpApp(tester, store: store);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search shortcuts'),
      'zzz nothing',
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching shortcuts'), findsOneWidget);
    expect(find.text('News'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('News'), findsOneWidget);
    expect(find.text('No matching shortcuts'), findsNothing);
  });

  testWidgets('opens Backup & Restore through the Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final Finder backupTile = find.text('Backup & Restore');
    await tester.scrollUntilVisible(
      backupTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(backupTile);
    await tester.pumpAndSettle();

    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.text('Move shortcuts between devices'), findsOneWidget);
    expect(find.text('Export to file'), findsOneWidget);
    expect(find.text('Import & merge'), findsOneWidget);
    expect(find.text('Import & replace'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester, {ShortcutStore? store}) async {
  final ShortcutStore resolvedStore = store ?? _buildStore();

  await tester.pumpWidget(
    ShortcutApp(
      store: resolvedStore,
      aboutInfo: const AboutInfo(
        author: 'SreerajP',
        version: '1.0.0',
        buildNumber: '1',
        buildDate: '2026-04-03',
        aiUsed: 'OpenAI GPT-5',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ShortcutStore _buildStore() {
  return ShortcutStore(
    repository: MemoryShortcutRepository(),
    formatter: const YoutubeUrlFormatter(),
    launcher: _FakeYoutubeLauncher(),
  );
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}
