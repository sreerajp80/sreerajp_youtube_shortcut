import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../share_intent_service.dart';
import '../shortcut_models.dart';
import '../shortcut_store.dart';

class AddShortcutScreen extends StatefulWidget {
  const AddShortcutScreen({super.key, this.initialEntry, this.initialUrlInput});

  final ShortcutEntry? initialEntry;
  final String? initialUrlInput;

  @override
  State<AddShortcutScreen> createState() => _AddShortcutScreenState();
}

class _AddShortcutScreenState extends State<AddShortcutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isSaving = false;
  String? _clipboardSuggestion;
  bool _clipboardSuggestionResolved = false;

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final ShortcutEntry? initialEntry = widget.initialEntry;
    if (initialEntry != null) {
      _nameController.text = initialEntry.name;
      _urlController.text = initialEntry.sourceUrl;
      return;
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String pageTitle = _isEditing ? 'Edit shortcut' : 'Add shortcut';
    final String heroTitle = _isEditing
        ? 'Update this shortcut'
        : 'Create a quick-launch card';
    final String heroDescription = _isEditing
        ? 'Change the shortcut name or handle. The app will re-validate and normalize the destination before saving.'
        : 'Enter a channel handle or paste a YouTube URL. The app can auto-build a live link and normalize it for direct handoff to YouTube.';
    final String actionLabel = _isEditing ? 'Save changes' : 'Save shortcut';
    final String savingLabel = _isEditing ? 'Updating...' : 'Saving...';

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
            decoration: const InputDecoration(
              labelText: 'Shortcut name',
              hintText: 'Example: Morning Mix',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Channel handle or YouTube URL',
              hintText: '@MyChannel or https://www.youtube.com/@MyChannel/live',
            ),
            onSubmitted: (_) {
              if (_isSaving) {
                return;
              }
              _saveShortcut();
            },
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
                    'Full URL: $previewUrl',
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
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const <Widget>[
              Chip(label: Text('@handle')),
              Chip(label: Text('watch')),
              Chip(label: Text('youtu.be')),
              Chip(label: Text('live')),
              Chip(label: Text('shorts')),
              Chip(label: Text('playlist')),
              Chip(label: Text('channel')),
            ],
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
            'The app stores the shortcut locally and does not request internet access.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveShortcut() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await context.read<ShortcutStore>().updateShortcut(
          id: widget.initialEntry!.id,
          nameInput: _nameController.text,
          urlInput: _urlController.text,
        );
      } else {
        await context.read<ShortcutStore>().addShortcut(
          nameInput: _nameController.text,
          urlInput: _urlController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pop(_isEditing ? 'Shortcut updated.' : 'Shortcut saved.');
    } on ShortcutValidationException catch (error) {
      _showMessage(error.message);
    } on ShortcutStorageException catch (error) {
      _showMessage(error.message);
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
                      'Paste this link?',
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
              TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                onPressed: onPaste,
                icon: const Icon(Icons.content_paste_go_rounded, size: 18),
                label: const Text('Paste'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
