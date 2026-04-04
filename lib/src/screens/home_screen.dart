import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shortcut_models.dart';
import '../shortcut_store.dart';
import 'about_screen.dart';
import 'add_shortcut_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShortcutStore store = context.watch<ShortcutStore>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YT Shortcuts'),
        actions: <Widget>[
          if (store.entries.isNotEmpty)
            PopupMenuButton<_HomeAction>(
              tooltip: 'Options',
              onSelected: (_HomeAction action) =>
                  _handleHomeAction(context, action),
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<_HomeAction>>[
                    PopupMenuItem<_HomeAction>(
                      value: _HomeAction.clearAll,
                      child: Text('Clear all shortcuts'),
                    ),
                  ],
            ),
          IconButton(
            tooltip: 'About',
            onPressed: () => _openAbout(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddShortcut(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add shortcut'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
        children: <Widget>[
          if (store.entries.isEmpty) ...<Widget>[
            _HomeHero(entryCount: store.entries.length),
            const SizedBox(height: 20),
          ],
          Text(
            'Shortcut section',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            store.entries.isEmpty
                ? 'Save the links you open often. Each shortcut stays local on this device.'
                : 'Tap any card to hand the canonical URL straight to the YouTube app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF66514A),
            ),
          ),
          const SizedBox(height: 16),
          if (store.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (store.entries.isEmpty)
            _EmptyShortcutState(onAddPressed: () => _openAddShortcut(context))
          else
            ...store.entries.map(
              (ShortcutEntry entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ShortcutCard(
                  entry: entry,
                  isLaunching: store.launchingShortcutId == entry.id,
                  onOpen: () => _launchShortcut(context, entry),
                  onEdit: () => _openEditShortcut(context, entry),
                  onDelete: () => _deleteShortcut(context, entry),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openAddShortcut(BuildContext context) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => const AddShortcutScreen(),
      ),
    );

    if (message == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditShortcut(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) =>
            AddShortcutScreen(initialEntry: entry),
      ),
    );

    if (message == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAbout(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AboutScreen(),
      ),
    );
  }

  Future<void> _launchShortcut(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    try {
      await context.read<ShortcutStore>().launchShortcut(entry);
    } on YoutubeLaunchException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteShortcut(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete shortcut?'),
          content: Text('Remove "${entry.name}" from the local shortcut list?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await context.read<ShortcutStore>().deleteShortcut(entry.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "${entry.name}".')));
  }

  Future<void> _handleHomeAction(
    BuildContext context,
    _HomeAction action,
  ) async {
    if (action != _HomeAction.clearAll) {
      return;
    }

    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear all shortcuts?'),
          content: const Text(
            'This removes every saved shortcut from the app. The YouTube links themselves are not deleted.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    await context.read<ShortcutStore>().clearAll();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All shortcuts cleared.')));
  }
}

enum _HomeAction { clearAll }

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFD73A23), Color(0xFFF6874D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Build your quick-launch shelf',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Save the YouTube links you open most often and hand them off to the installed YouTube app with one tap.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFFFE8E0),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                '$entryCount saved shortcut${entryCount == 1 ? '' : 's'}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyShortcutState extends StatelessWidget {
  const _EmptyShortcutState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4D8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.play_circle_fill_rounded, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'No shortcuts yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start with one link you open often. The app stores it locally and formats it for direct YouTube-app launch.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 18),
            FilledButton.tonalIcon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Create first shortcut'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.entry,
    required this.isLaunching,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ShortcutEntry entry;
  final bool isLaunching;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _ShortcutTypeVisual visual = entry.targetType.visual;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFF0DFD6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isLaunching ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: visual.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(visual.icon, color: visual.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: visual.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.targetType.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: visual.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          isLaunching ? 'Opening...' : 'Tap to open',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF7B6258),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entry.canonicalUrl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF725D55),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: isLaunching ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: isLaunching ? null : onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutTypeVisual {
  const _ShortcutTypeVisual(this.icon, this.accent);

  final IconData icon;
  final Color accent;
}

extension on ShortcutTargetType {
  _ShortcutTypeVisual get visual {
    switch (this) {
      case ShortcutTargetType.video:
        return const _ShortcutTypeVisual(
          Icons.play_circle_fill_rounded,
          Color(0xFFD73A23),
        );
      case ShortcutTargetType.shortVideo:
        return const _ShortcutTypeVisual(
          Icons.flash_on_rounded,
          Color(0xFFEF6C00),
        );
      case ShortcutTargetType.playlist:
        return const _ShortcutTypeVisual(
          Icons.queue_music_rounded,
          Color(0xFF6D4C41),
        );
      case ShortcutTargetType.channel:
        return const _ShortcutTypeVisual(
          Icons.person_pin_circle_rounded,
          Color(0xFF00897B),
        );
    }
  }
}
