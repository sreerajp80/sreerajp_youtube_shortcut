import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/services/share_intent_service.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/screens/qr_scanner_screen.dart';

class AddShortcutScreen extends StatefulWidget {
  const AddShortcutScreen({
    super.key,
    this.initialEntry,
    this.initialUrlInput,
    this.initialNameInput,
    this.initialTags,
  });

  final ShortcutEntry? initialEntry;
  final String? initialUrlInput;
  final String? initialNameInput;
  final List<String>? initialTags;

  @override
  State<AddShortcutScreen> createState() => _AddShortcutScreenState();
}

class _AddShortcutScreenState extends State<AddShortcutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _isSaving = false;
  bool _isFavorite = false;
  bool _isPrivate = false;
  List<String> _tags = <String>[];
  String? _customColorHex;
  String? _customIconName;
  String? _clipboardSuggestion;
  bool _clipboardSuggestionResolved = false;

  static const List<String> _suggestedTags = <String>[
    '#Tech',
    '#Music',
    '#News',
    '#Education',
    '#Personal',
  ];

  /// Accent presets. The key is a stable id used for the localized name; the
  /// value is the stored hex. Only the hex is persisted.
  static const List<MapEntry<String, String>> _accentColorPresets =
      <MapEntry<String, String>>[
        MapEntry<String, String>('crimson', '#D73A23'),
        MapEntry<String, String>('orange', '#EA580C'),
        MapEntry<String, String>('amber', '#CA8A04'),
        MapEntry<String, String>('emerald', '#059669'),
        MapEntry<String, String>('teal', '#0D9488'),
        MapEntry<String, String>('cyan', '#0891B2'),
        MapEntry<String, String>('blue', '#2563EB'),
        MapEntry<String, String>('indigo', '#6366F1'),
        MapEntry<String, String>('purple', '#7C3AED'),
        MapEntry<String, String>('pink', '#DB2777'),
        MapEntry<String, String>('slate', '#475569'),
      ];

  static String _accentColorName(AppLocalizations l10n, String id) {
    switch (id) {
      case 'crimson':
        return l10n.colorCrimson;
      case 'orange':
        return l10n.colorOrange;
      case 'amber':
        return l10n.colorAmber;
      case 'emerald':
        return l10n.colorEmerald;
      case 'teal':
        return l10n.colorTeal;
      case 'cyan':
        return l10n.colorCyan;
      case 'blue':
        return l10n.colorBlue;
      case 'indigo':
        return l10n.colorIndigo;
      case 'purple':
        return l10n.colorPurple;
      case 'pink':
        return l10n.colorPink;
      default:
        return l10n.colorSlate;
    }
  }

  static const Map<String, IconData> _iconPresets = <String, IconData>{
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

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final ShortcutEntry? initialEntry = widget.initialEntry;
    if (initialEntry != null) {
      _nameController.text = initialEntry.name;
      _urlController.text = initialEntry.sourceUrl;
      _isFavorite = initialEntry.isFavorite;
      _isPrivate = initialEntry.isPrivate;
      _tags = List<String>.from(initialEntry.tags);
      _customColorHex = initialEntry.customColorHex;
      _customIconName = initialEntry.customIconName;
      return;
    }

    if (widget.initialNameInput != null &&
        widget.initialNameInput!.isNotEmpty) {
      _nameController.text = widget.initialNameInput!;
    }

    if (widget.initialTags != null && widget.initialTags!.isNotEmpty) {
      _tags = List<String>.from(widget.initialTags!);
    }

    final String? initialUrlInput = widget.initialUrlInput;
    if (initialUrlInput != null && initialUrlInput.isNotEmpty) {
      _urlController.text = initialUrlInput;
      return;
    }

    _urlController.addListener(_handleUrlChangedForSuggestion);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForYoutubeUrl();
    });
  }

  @override
  void dispose() {
    _urlController.removeListener(_handleUrlChangedForSuggestion);
    _nameController.dispose();
    _urlController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _handleUrlChangedForSuggestion() {
    if (_clipboardSuggestion == null) {
      return;
    }
    if (_urlController.text.isNotEmpty) {
      setState(() {
        _clipboardSuggestion = null;
        _clipboardSuggestionResolved = true;
      });
    }
  }

  Future<void> _checkClipboardForYoutubeUrl() async {
    if (!mounted ||
        _clipboardSuggestionResolved ||
        _urlController.text.isNotEmpty) {
      return;
    }

    ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {
      return;
    }

    final String? raw = data?.text;
    if (raw == null || !mounted) {
      return;
    }

    final String? candidate = extractFirstUrlOrRaw(raw);
    if (candidate == null ||
        candidate.isEmpty ||
        !looksLikeYoutubeUrl(candidate)) {
      return;
    }

    if (_clipboardSuggestionResolved || _urlController.text.isNotEmpty) {
      return;
    }

    setState(() {
      _clipboardSuggestion = candidate;
    });
  }

  void _applyClipboardSuggestion() {
    final String? suggestion = _clipboardSuggestion;
    if (suggestion == null) {
      return;
    }
    _urlController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    setState(() {
      _clipboardSuggestion = null;
      _clipboardSuggestionResolved = true;
    });
  }

  void _dismissClipboardSuggestion() {
    setState(() {
      _clipboardSuggestion = null;
      _clipboardSuggestionResolved = true;
    });
  }

  void _addTag(String rawTag) {
    String formatted = rawTag.trim();
    if (formatted.isEmpty) return;
    if (!formatted.startsWith('#')) {
      formatted = '#$formatted';
    }
    if (!_tags.contains(formatted)) {
      setState(() {
        _tags = <String>[..._tags, formatted];
        _tagController.clear();
      });
    } else {
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((String t) => t != tag).toList();
    });
  }

  void _toggleSuggestedTag(String tag) {
    if (_tags.contains(tag)) {
      _removeTag(tag);
    } else {
      _addTag(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String pageTitle = _isEditing ? l10n.addEditTitle : l10n.addNewTitle;
    final String heroTitle = _isEditing
        ? l10n.addEditHeroTitle
        : l10n.addNewHeroTitle;
    final String heroDescription = _isEditing
        ? l10n.addEditHeroBody
        : l10n.addNewHeroBody;
    final String actionLabel = _isEditing
        ? l10n.addSaveChanges
        : l10n.addSaveShortcut;
    final String savingLabel = _isEditing ? l10n.addUpdating : l10n.addSaving;

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF26120C), Color(0xFF8B2A17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  heroTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  heroDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFFFE6DE),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.addNameLabel,
              hintText: l10n.addNameHint,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: l10n.addUrlLabel,
              hintText: l10n.addUrlHint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded),
                tooltip: l10n.addScanQrTooltip,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const QrScannerScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _urlController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
                  final String? previewUrl = context
                      .read<ShortcutStore>()
                      .fullUrlPreviewForInput(value.text);
                  if (previewUrl == null) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    l10n.addFullUrlPreview(previewUrl),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
          ),
          if (_clipboardSuggestion != null) ...<Widget>[
            const SizedBox(height: 12),
            _ClipboardSuggestionBanner(
              suggestion: _clipboardSuggestion!,
              onPaste: _applyClipboardSuggestion,
              onDismiss: _dismissClipboardSuggestion,
            ),
          ],
          const SizedBox(height: 20),
          // Favorite Switch Tile
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainerHigh,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: SwitchListTile(
                value: _isFavorite,
                onChanged: (bool value) {
                  setState(() => _isFavorite = value);
                },
                secondary: Icon(
                  _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _isFavorite
                      ? Colors.amber
                      : theme.colorScheme.onSurface,
                ),
                title: Text(
                  l10n.addFavoriteTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(l10n.addFavoriteSubtitle),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainerHigh,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: SwitchListTile(
                value: _isPrivate,
                onChanged: (bool value) {
                  setState(() => _isPrivate = value);
                },
                secondary: Icon(
                  _isPrivate ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: _isPrivate
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                title: Text(
                  l10n.addPrivateTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(l10n.addPrivateSubtitle),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Custom Card Accent Color Section
          Text(
            l10n.addAccentColorSection,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.addColorDefault),
                  selected: _customColorHex == null,
                  onSelected: (_) {
                    setState(() => _customColorHex = null);
                  },
                ),
                const SizedBox(width: 8),
                ..._accentColorPresets.map((MapEntry<String, String> preset) {
                  final String hex = preset.value;
                  final Color color = _parseColorHex(hex)!;
                  final bool isSelected = _customColorHex == hex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: _accentColorName(l10n, preset.key),
                      child: InkWell(
                        onTap: () {
                          setState(() => _customColorHex = hex);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.black26,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Custom Card Icon Section
          Text(
            l10n.addIconSection,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.addIconDefault),
                  selected: _customIconName == null,
                  onSelected: (_) {
                    setState(() => _customIconName = null);
                  },
                ),
                const SizedBox(width: 8),
                ..._iconPresets.entries.map((MapEntry<String, IconData> entry) {
                  final String key = entry.key;
                  final IconData icon = entry.value;
                  final bool isSelected = _customIconName == key;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(icon, size: 18),
                      label: Text(key[0].toUpperCase() + key.substring(1)),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _customIconName = isSelected ? null : key;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Custom Tags Section
          Text(
            l10n.addTagsSection,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _tagController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.addTagLabel,
                    hintText: l10n.addTagHint,
                  ),
                  onSubmitted: (String val) => _addTag(val),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: l10n.addTagLabel,
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _addTag(_tagController.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Selected Tags Chips
          if (_tags.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((String tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close_rounded, size: 18),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          // Suggested Tags
          Text(
            l10n.addSuggestedTags,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedTags.map((String tag) {
              final bool isSelected = _tags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) => _toggleSuggestedTag(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveShortcut,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? savingLabel : actionLabel),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.addOfflineFootnote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _saveShortcut() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await context.read<ShortcutStore>().updateShortcut(
          id: widget.initialEntry!.id,
          nameInput: _nameController.text,
          urlInput: _urlController.text,
          tags: _tags,
          isFavorite: _isFavorite,
          isPrivate: _isPrivate,
          customColorHex: _customColorHex,
          clearCustomColorHex: _customColorHex == null,
          customIconName: _customIconName,
          clearCustomIconName: _customIconName == null,
        );
      } else {
        await context.read<ShortcutStore>().addShortcut(
          nameInput: _nameController.text,
          urlInput: _urlController.text,
          tags: _tags,
          isFavorite: _isFavorite,
          isPrivate: _isPrivate,
          customColorHex: _customColorHex,
          customIconName: _customIconName,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pop(_isEditing ? l10n.addShortcutUpdated : l10n.addShortcutSaved);
    } on ShortcutValidationException catch (error) {
      _showMessage(error.localized(l10n));
    } on ShortcutStorageException catch (error) {
      _showMessage(error.localized(l10n));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ClipboardSuggestionBanner extends StatelessWidget {
  const _ClipboardSuggestionBanner({
    required this.suggestion,
    required this.onPaste,
    required this.onDismiss,
  });

  final String suggestion;
  final VoidCallback onPaste;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.secondaryContainer,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.content_paste_rounded,
                size: 20,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.addPasteSuggestionTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: onDismiss,
                child: Text(l10n.addPasteDismiss),
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                onPressed: onPaste,
                icon: const Icon(Icons.content_paste_go_rounded, size: 18),
                label: Text(l10n.addPasteAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
