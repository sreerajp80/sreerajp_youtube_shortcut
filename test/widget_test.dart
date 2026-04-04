import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/app_shell.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_services.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_store.dart';

void main() {
  testWidgets('renders the empty shortcut state', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.text('No shortcuts yet'), findsOneWidget);
    expect(find.text('Build your quick-launch shelf'), findsOneWidget);
    expect(find.text('Add shortcut'), findsOneWidget);
  });
  testWidgets(
    'shows full-url preview for handle input on add shortcut screen',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Add shortcut'));
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

    await tester.tap(find.text('Add shortcut'));
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

  testWidgets('updates theme preference from Settings screen', (
    WidgetTester tester,
  ) async {
    final ShortcutStore store = _buildStore();
    await _pumpApp(tester, store: store);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(store.themePreference, AppThemePreference.dark);
  });
  testWidgets('opens About through the new Settings screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'About'));
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

    await tester.tap(find.widgetWithText(ListTile, 'Permissions'));
    await tester.pumpAndSettle();

    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('Explicit Permissions'), findsOneWidget);
    expect(find.text('Implicit Permissions / Declarations'), findsOneWidget);
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
