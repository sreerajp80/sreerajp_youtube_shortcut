import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/app_shell.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_services.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_store.dart';

void main() {
  testWidgets('renders the empty shortcut state', (WidgetTester tester) async {
    final ShortcutStore store = ShortcutStore(
      repository: MemoryShortcutRepository(),
      formatter: const YoutubeUrlFormatter(),
      launcher: _FakeYoutubeLauncher(),
    );

    await tester.pumpWidget(
      ShortcutApp(
        store: store,
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

    expect(find.text('No shortcuts yet'), findsOneWidget);
    expect(find.text('Build your quick-launch shelf'), findsOneWidget);
    expect(find.text('Add shortcut'), findsOneWidget);
  });
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}
