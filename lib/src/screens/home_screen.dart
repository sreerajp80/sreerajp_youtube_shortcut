import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shortcut_models.dart';
import '../shortcut_store.dart';
import 'add_shortcut_screen.dart';
import 'settings_screen.dart';

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
            tooltip: 'Settings',
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined),
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
                : 'Long-press and drag cards to rearrange them. Tap a card to open it in the YouTube app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
            _ShortcutGrid(
              entries: store.entries,
              launchingShortcutId: store.launchingShortcutId,
              onOpen: (ShortcutEntry entry) => _launchShortcut(context, entry),
              onEdit: (ShortcutEntry entry) =>
                  _openEditShortcut(context, entry),
              onDelete: (ShortcutEntry entry) =>
                  _deleteShortcut(context, entry),
              onReorder: (int oldIndex, int newIndex) {
                _reorderShortcuts(context, oldIndex, newIndex);
              },
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

  Future<void> _openSettings(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SettingsScreen(),
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

  Future<void> _reorderShortcuts(
    BuildContext context,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      await context.read<ShortcutStore>().reorderShortcuts(oldIndex, newIndex);
    } on ShortcutStorageException catch (error) {
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

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.entries,
    required this.launchingShortcutId,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final List<ShortcutEntry> entries;
  final String? launchingShortcutId;
  final ValueChanged<ShortcutEntry> onOpen;
  final ValueChanged<ShortcutEntry> onEdit;
  final ValueChanged<ShortcutEntry> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 12;
        final int columnCount = constraints.maxWidth >= 680 ? 3 : 2;
        final double cardWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List<Widget>.generate(entries.length, (int index) {
            final ShortcutEntry entry = entries[index];

            return SizedBox(
              width: cardWidth,
              child: _ReorderableShortcutGridCard(
                index: index,
                cardWidth: cardWidth,
                entry: entry,
                isLaunching: launchingShortcutId == entry.id,
                onOpen: () => onOpen(entry),
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry),
                onReorder: onReorder,
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReorderableShortcutGridCard extends StatelessWidget {
  const _ReorderableShortcutGridCard({
    required this.index,
    required this.cardWidth,
    required this.entry,
    required this.isLaunching,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final int index;
  final double cardWidth;
  final ShortcutEntry entry;
  final bool isLaunching;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> details) {
        return details.data != index;
      },
      onAcceptWithDetails: (DragTargetDetails<int> details) {
        final int oldIndex = details.data;
        final int newIndex = oldIndex < index ? index + 1 : index;
        onReorder(oldIndex, newIndex);
      },
      builder:
          (
            BuildContext context,
            List<int?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final bool isTargeted = candidateData.isNotEmpty;
            final Widget card = _ShortcutCard(
              entry: entry,
              isLaunching: isLaunching,
              onOpen: onOpen,
              onEdit: onEdit,
              onDelete: onDelete,
            );

            final Widget decoratedCard = AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: isTargeted
                    ? Border.all(color: theme.colorScheme.primary, width: 1.6)
                    : null,
              ),
              child: card,
            );

            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: cardWidth,
                  child: Opacity(opacity: 0.92, child: card),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.35, child: decoratedCard),
              child: decoratedCard,
            );
          },
    );
  }
}

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
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 30,
                color: theme.colorScheme.onSecondaryContainer,
              ),
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
    final bool isDark = theme.brightness == Brightness.dark;
    final _ShortcutTypeVisual visual = entry.targetType.visual(
      theme.brightness,
    );
    const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(20));

    final Color cardTopColor = Color.alphaBlend(
      visual.accent.withValues(alpha: isDark ? 0.22 : 0.08),
      theme.colorScheme.surfaceContainerHigh,
    );
    final Color cardBottomColor = theme.colorScheme.surfaceContainerLow;
    final Color borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.92 : 0.55,
    );

    final List<BoxShadow> cardShadows = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0.5,
            ),
          ]
        : const <BoxShadow>[
            BoxShadow(
              color: Color(0x14A56E5A),
              offset: Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0.5,
            ),
            BoxShadow(
              color: Color(0x10D29E89),
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
            BoxShadow(
              color: Color(0xC9FFFFFF),
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ];

    return DecoratedBox(
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
            border: Border.fromBorderSide(BorderSide(color: borderColor)),
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
                          theme.colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.07 : 0.035,
                          ),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: const Alignment(0.4, 0.2),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: cardBorderRadius,
                onTap: isLaunching ? null : onOpen,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
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
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        theme.colorScheme.surface,
                                        visual.accent.withValues(
                                          alpha: isDark ? 0.2 : 0.08,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: visual.accent.withValues(
                                        alpha: isDark ? 0.42 : 0.22,
                                      ),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: visual.accent.withValues(
                                          alpha: isDark ? 0.2 : 0.14,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    visual.icon,
                                    color: visual.accent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      entry.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      visual.accent.withValues(
                                        alpha: isDark ? 0.28 : 0.18,
                                      ),
                                      visual.accent.withValues(
                                        alpha: isDark ? 0.18 : 0.1,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: visual.accent.withValues(
                                      alpha: isDark ? 0.5 : 0.22,
                                    ),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: visual.accent.withValues(
                                        alpha: isDark ? 0.2 : 0.1,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  entry.targetType.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: visual.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: isLaunching ? null : onEdit,
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            const SizedBox(height: 2),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: isLaunching ? null : onDelete,
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
  _ShortcutTypeVisual visual(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    switch (this) {
      case ShortcutTargetType.video:
        return _ShortcutTypeVisual(
          Icons.play_circle_fill_rounded,
          isDark ? const Color(0xFFFF8A65) : const Color(0xFFD73A23),
        );
      case ShortcutTargetType.shortVideo:
        return _ShortcutTypeVisual(
          Icons.flash_on_rounded,
          isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00),
        );
      case ShortcutTargetType.playlist:
        return _ShortcutTypeVisual(
          Icons.queue_music_rounded,
          isDark ? const Color(0xFFBCAAA4) : const Color(0xFF6D4C41),
        );
      case ShortcutTargetType.channel:
        return _ShortcutTypeVisual(
          Icons.person_pin_circle_rounded,
          isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B),
        );
    }
  }
}
