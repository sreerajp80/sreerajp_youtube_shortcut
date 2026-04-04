import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shortcut_models.dart';
import '../shortcut_store.dart';

class AddShortcutScreen extends StatefulWidget {
  const AddShortcutScreen({super.key, this.initialEntry});

  final ShortcutEntry? initialEntry;

  @override
  State<AddShortcutScreen> createState() => _AddShortcutScreenState();
}

class _AddShortcutScreenState extends State<AddShortcutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final ShortcutEntry? initialEntry = widget.initialEntry;
    if (initialEntry == null) {
      return;
    }

    _nameController.text = initialEntry.name;
    _urlController.text = initialEntry.sourceUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
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
