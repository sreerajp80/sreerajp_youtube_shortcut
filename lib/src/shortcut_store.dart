import 'package:flutter/foundation.dart';

import 'shortcut_models.dart';
import 'shortcut_services.dart';

class ShortcutStore extends ChangeNotifier {
  ShortcutStore({
    required ShortcutRepository repository,
    required YoutubeUrlFormatter formatter,
    required YoutubeLauncher launcher,
  }) : _repository = repository,
       _formatter = formatter,
       _launcher = launcher;

  final ShortcutRepository _repository;
  final YoutubeUrlFormatter _formatter;
  final YoutubeLauncher _launcher;

  List<ShortcutEntry> _entries = const <ShortcutEntry>[];
  bool _isLoading = false;
  String? _launchingShortcutId;

  List<ShortcutEntry> get entries => List<ShortcutEntry>.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get launchingShortcutId => _launchingShortcutId;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<ShortcutEntry> loadedEntries = await _repository
          .loadShortcuts();
      _entries = _sortEntries(loadedEntries);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShortcut({
    required String nameInput,
    required String urlInput,
  }) async {
    final ShortcutEntry newEntry = _formatter.createEntry(
      nameInput: nameInput,
      urlInput: urlInput,
    );

    _throwIfDuplicateName(normalizedName: newEntry.name.trim().toLowerCase());

    final List<ShortcutEntry> updatedEntries = _sortEntries(<ShortcutEntry>[
      newEntry,
      ..._entries,
    ]);

    await _repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> updateShortcut({
    required String id,
    required String nameInput,
    required String urlInput,
  }) async {
    final ShortcutEntry existingEntry = _entries.firstWhere(
      (ShortcutEntry entry) => entry.id == id,
      orElse: () => throw const ShortcutStorageException(
        'This shortcut no longer exists. Reload and try again.',
      ),
    );

    final ShortcutEntry updatedEntry = _formatter.updateEntry(
      existingEntry: existingEntry,
      nameInput: nameInput,
      urlInput: urlInput,
    );

    _throwIfDuplicateName(
      normalizedName: updatedEntry.name.trim().toLowerCase(),
      excludedId: updatedEntry.id,
    );

    final List<ShortcutEntry> updatedEntries = _sortEntries(
      _entries
          .map((ShortcutEntry entry) => entry.id == id ? updatedEntry : entry)
          .toList(growable: false),
    );

    await _repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> deleteShortcut(String id) async {
    final List<ShortcutEntry> updatedEntries = _entries
        .where((ShortcutEntry entry) => entry.id != id)
        .toList(growable: false);

    await _repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.saveShortcuts(const <ShortcutEntry>[]);
    _entries = const <ShortcutEntry>[];
    notifyListeners();
  }

  Future<void> launchShortcut(ShortcutEntry entry) async {
    _launchingShortcutId = entry.id;
    notifyListeners();

    try {
      await _launcher.openShortcut(entry);
    } finally {
      _launchingShortcutId = null;
      notifyListeners();
    }
  }

  void _throwIfDuplicateName({
    required String normalizedName,
    String? excludedId,
  }) {
    final bool duplicateName = _entries.any((ShortcutEntry entry) {
      if (excludedId != null && entry.id == excludedId) {
        return false;
      }
      return entry.name.trim().toLowerCase() == normalizedName;
    });

    if (duplicateName) {
      throw const ShortcutValidationException(
        'Choose a different shortcut name. Names must be unique.',
      );
    }
  }

  List<ShortcutEntry> _sortEntries(List<ShortcutEntry> entries) {
    final List<ShortcutEntry> sortedEntries = List<ShortcutEntry>.from(entries);
    sortedEntries.sort(
      (ShortcutEntry left, ShortcutEntry right) =>
          right.updatedAt.compareTo(left.updatedAt),
    );
    return sortedEntries;
  }
}
