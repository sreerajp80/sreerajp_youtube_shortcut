import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/widgets/shortcut_card.dart';

/// Lays the shortcut cards out as a responsive grid or a single column.
class ShortcutGrid extends StatelessWidget {
  const ShortcutGrid({
    super.key,
    required this.entries,
    required this.launchingShortcutId,
    required this.isList,
    required this.isReorderMode,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onOpen,
    required this.onSwipeDelete,
    required this.onReorder,
    required this.onLongPressEntry,
    required this.onToggleSelect,
  });

  final List<ShortcutEntry> entries;
  final String? launchingShortcutId;
  final bool isList;
  final bool isReorderMode;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final ValueChanged<ShortcutEntry> onOpen;
  final Future<bool?> Function(ShortcutEntry) onSwipeDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<ShortcutEntry> onLongPressEntry;
  final ValueChanged<ShortcutEntry> onToggleSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 12;
        final int columnCount = isList
            ? 1
            : (constraints.maxWidth >= 680 ? 3 : 2);
        final double cardWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List<Widget>.generate(entries.length, (int index) {
            final ShortcutEntry entry = entries[index];
            final bool isSelected = selectedIds.contains(entry.id);

            final Widget card = SizedBox(
              width: cardWidth,
              child: ReorderableShortcutGridCard(
                index: index,
                cardWidth: cardWidth,
                entry: entry,
                isLaunching: launchingShortcutId == entry.id,
                isReorderMode: isReorderMode,
                isSelectionMode: isSelectionMode,
                isSelected: isSelected,
                onOpen: () => onOpen(entry),
                onReorder: onReorder,
                onLongPress: () => onLongPressEntry(entry),
                onToggleSelect: () => onToggleSelect(entry),
              ),
            );

            if (isReorderMode || isSelectionMode) {
              return card;
            }

            return Dismissible(
              key: ValueKey<String>(entry.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => onSwipeDelete(entry),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              child: card,
            );
          }),
        );
      },
    );
  }
}

class ReorderableShortcutGridCard extends StatelessWidget {
  const ReorderableShortcutGridCard({
    super.key,
    required this.index,
    required this.cardWidth,
    required this.entry,
    required this.isLaunching,
    required this.isReorderMode,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onOpen,
    required this.onReorder,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  final int index;
  final double cardWidth;
  final ShortcutEntry entry;
  final bool isLaunching;
  final bool isReorderMode;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onOpen;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

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
            final Widget card = ShortcutCard(
              entry: entry,
              isLaunching: isLaunching,
              isReorderMode: isReorderMode,
              isSelectionMode: isSelectionMode,
              isSelected: isSelected,
              onOpen: onOpen,
              onLongPress: onLongPress,
              onToggleSelect: onToggleSelect,
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

            if (!isReorderMode) {
              return decoratedCard;
            }

            return LongPressDraggable<int>(
              data: index,
              delay: const Duration(milliseconds: 200),
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
