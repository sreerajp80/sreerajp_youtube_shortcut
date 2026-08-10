import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../shortcut_models.dart';
import '../shortcut_store.dart';
import '../widgets/shortcut_qr_dialog.dart';
import 'add_shortcut_screen.dart';

class ShortcutDetailScreen extends StatelessWidget {
  const ShortcutDetailScreen({super.key, required this.shortcutId});

  final String shortcutId;

  @override
  Widget build(BuildContext context) {
    final ShortcutStore store = context.watch<ShortcutStore>();
    final ShortcutEntry? entry = _lookup(store);

    if (entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final ThemeData theme = Theme.of(context);
    final bool isLaunching = store.launchingShortcutId == entry.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shortcut details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Show QR Code',
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () => ShortcutQrDialog.show(context, entry),
          ),
          IconButton(
            tooltip: entry.isFavorite ? 'Unpin favorite' : 'Pin favorite',
            icon: Icon(
              entry.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: entry.isFavorite ? Colors.amber : null,
            ),
            onPressed: () => store.toggleFavorite(entry.id),
          ),
          IconButton(
            tooltip: 'Edit shortcut',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editEntry(context, entry),
          ),
          IconButton(
            tooltip: 'Delete shortcut',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _deleteEntry(context, entry),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          _DetailHeader(entry: entry),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isLaunching ? null : () => _launchEntry(context, entry),
            icon: isLaunching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(isLaunching ? 'Opening...' : 'Open in YouTube'),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ShortcutQrDialog.show(context, entry),
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: const Text('QR Code'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyUrl(context, entry),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy URL'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editEntry(context, entry),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: 'Destination'),
          const SizedBox(height: 8),
          _UrlCard(
            label: 'Full URL',
            url: entry.canonicalUrl,
            onCopy: () => _copyUrl(context, entry),
          ),
          if (entry.sourceUrl.trim() != entry.canonicalUrl) ...<Widget>[
            const SizedBox(height: 12),
            _UrlCard(
              label: 'Original input',
              url: entry.sourceUrl,
              onCopy: () => _copyText(
                context,
                entry.sourceUrl,
                successMessage: 'Original input copied to clipboard.',
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionLabel(text: 'Activity'),
          const SizedBox(height: 8),
          _MetadataCard(
            rows: <_MetadataRow>[
              _MetadataRow(
                icon: Icons.play_circle_outline_rounded,
                label: 'Last launched',
                value: entry.lastLaunchedAt == null
                    ? 'Never launched'
                    : _formatAbsolute(entry.lastLaunchedAt!),
              ),
              _MetadataRow(
                icon: Icons.local_fire_department_outlined,
                label: 'Launch count',
                value: _formatLaunchCount(entry.launchCount),
              ),
              _MetadataRow(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: _formatAbsolute(entry.createdAt),
              ),
              _MetadataRow(
                icon: Icons.history_rounded,
                label: 'Updated',
                value: entry.updatedAt == entry.createdAt
                    ? 'Same as created'
                    : _formatAbsolute(entry.updatedAt),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Activity is tracked locally on this device only.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  ShortcutEntry? _lookup(ShortcutStore store) {
    for (final ShortcutEntry entry in store.entries) {
      if (entry.id == shortcutId) {
        return entry;
      }
    }
    return null;
  }

  Future<void> _launchEntry(BuildContext context, ShortcutEntry entry) async {
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

  Future<void> _editEntry(BuildContext context, ShortcutEntry entry) async {
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

  Future<void> _copyUrl(BuildContext context, ShortcutEntry entry) async {
    await _copyText(
      context,
      entry.canonicalUrl,
      successMessage: 'URL copied to clipboard.',
    );
  }

  Future<void> _copyText(
    BuildContext context,
    String text, {
    required String successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }

  Future<void> _deleteEntry(BuildContext context, ShortcutEntry entry) async {
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

    final String name = entry.name;
    await context.read<ShortcutStore>().deleteShortcut(entry.id);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop<String>('Removed "$name".');
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.entry});

  final ShortcutEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? customColor = _parseColorHex(entry.customColorHex);
    final Color avatarColor = customColor ?? _avatarColorFor(entry.id);
    final String avatarLetters = _avatarLettersFor(entry.name);
    final IconData? customIcon = _parseIconData(entry.customIconName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: customIcon != null
                  ? Icon(
                      customIcon,
                      color: Colors.white,
                      size: 28,
                    )
                  : Text(
                      avatarLetters,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (entry.isFavorite)
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.targetType.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final String tag in entry.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _UrlCard extends StatelessWidget {
  const _UrlCard({
    required this.label,
    required this.url,
    required this.onCopy,
  });

  final String label;
  final String url;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  url,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.rows});

  final List<_MetadataRow> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: List<Widget>.generate(rows.length, (int index) {
          final _MetadataRow row = rows[index];
          return Column(
            children: <Widget>[
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      row.icon,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MetadataRow {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatAbsolute(DateTime utc) {
  final DateTime local = utc.isUtc ? utc.toLocal() : utc;
  final String month = _shortMonths[local.month - 1];
  final String day = local.day.toString();
  final String year = local.year.toString();
  final int hour24 = local.hour;
  final int displayHour = hour24 == 0
      ? 12
      : (hour24 > 12 ? hour24 - 12 : hour24);
  final String minute = local.minute.toString().padLeft(2, '0');
  final String period = hour24 < 12 ? 'AM' : 'PM';
  return '$month $day, $year at $displayHour:$minute $period';
}

String _formatLaunchCount(int count) {
  if (count <= 0) {
    return 'Never launched';
  }
  if (count == 1) {
    return '1 launch';
  }
  return '$count launches';
}

const List<Color> _avatarPalette = <Color>[
  Color(0xFFD73A23),
  Color(0xFFEA580C),
  Color(0xFFCA8A04),
  Color(0xFF65A30D),
  Color(0xFF059669),
  Color(0xFF0D9488),
  Color(0xFF0891B2),
  Color(0xFF2563EB),
  Color(0xFF6366F1),
  Color(0xFF7C3AED),
  Color(0xFFC026D3),
  Color(0xFFDB2777),
];

Color _avatarColorFor(String seed) {
  int hash = 0;
  for (final int unit in seed.codeUnits) {
    hash = (hash * 31 + unit) & 0x7FFFFFFF;
  }
  return _avatarPalette[hash % _avatarPalette.length];
}

String _avatarLettersFor(String name) {
  final List<String> words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) {
    return '?';
  }
  if (words.length == 1) {
    final String word = words.first;
    final String taken = word.length >= 2 ? word.substring(0, 2) : word;
    return taken.toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

Color? _parseColorHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final String clean = hex.replaceAll('#', '');
  if (clean.length == 6) {
    final int? val = int.tryParse('FF$clean', radix: 16);
    if (val != null) return Color(val);
  }
  return null;
}

IconData? _parseIconData(String? name) {
  if (name == null || name.isEmpty) return null;
  const Map<String, IconData> icons = <String, IconData>{
    'play': Icons.play_arrow_rounded,
    'star': Icons.star_rounded,
    'music': Icons.music_note_rounded,
    'game': Icons.sports_esports_rounded,
    'code': Icons.code_rounded,
    'tv': Icons.tv_rounded,
    'flame': Icons.local_fire_department_rounded,
    'headphones': Icons.headphones_rounded,
    'bookmark': Icons.bookmark_rounded,
    'video': Icons.video_library_rounded,
    'heart': Icons.favorite_rounded,
    'lightning': Icons.bolt_rounded,
    'sparkles': Icons.auto_awesome_rounded,
  };
  return icons[name];
}
