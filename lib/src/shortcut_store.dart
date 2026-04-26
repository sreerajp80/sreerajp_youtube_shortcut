import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import 'backup_service.dart';
import 'shortcut_models.dart';
import 'shortcut_repository.dart';
import 'youtube_launcher_service.dart';
import 'youtube_url_formatter.dart';

class ShortcutStore extends ChangeNotifier {
  ShortcutStore({
    required ShortcutRepository repository,
    required YoutubeUrlFormatter formatter,
    required YoutubeLauncher launcher,
    ShortcutBackupService backupService = const ShortcutBackupService(),
    BackupFileGateway backupGateway = const NoOpBackupFileGateway(),
  }) : _repository = repository,
       _formatter = formatter,
       _launcher = launcher,
       _backupService = backupService,
       _backupGateway = backupGateway;

  final ShortcutRepository _repository;
  final YoutubeUrlFormatter _formatter;
  final YoutubeLauncher _launcher;
  final ShortcutBackupService _backupService;
  final BackupFileGateway _backupGateway;

  List<ShortcutEntry> _entries = const <ShortcutEntry>[];
  bool _isLoading = false;
  String? _launchingShortcutId;
  AppThemePreference _themePreference = AppThemePreference.system;
  AppLayoutPreference _layoutPreference = AppLayoutPreference.grid;
  ShortcutSortPreference _sortPreference = ShortcutSortPreference.manual;

  List<ShortcutEntry> get entries => List<ShortcutEntry>.unmodifiable(_entries);
  List<ShortcutEntry> get entriesSorted =>
      List<ShortcutEntry>.unmodifiable(_applySort(_entries, _sortPreference));
  bool get isLoading => _isLoading;
  String? get launchingShortcutId => _launchingShortcutId;
  AppThemePreference get themePreference => _themePreference;
  AppLayoutPreference get layoutPreference => _layoutPreference;
  ShortcutSortPreference get sortPreference => _sortPreference;

  String? fullUrlPreviewForInput(String urlInput) {
    try {
      return _formatter.buildDisplayUrlPreview(urlInput);
    } on ShortcutValidationException {
      return null;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<ShortcutEntry> loadedEntries = await _repository
          .loadShortcuts();
      final AppThemePreference loadedThemePreference = await _repository
          .loadThemePreference();
      final AppLayoutPreference loadedLayoutPreference = await _repository
          .loadLayoutPreference();
      final ShortcutSortPreference loadedSortPreference = await _repository
          .loadSortPreference();
      _entries = loadedEntries;
      _themePreference = loadedThemePreference;
      _layoutPreference = loadedLayoutPreference;
      _sortPreference = loadedSortPreference;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLayoutPreference(AppLayoutPreference preference) async {
    if (_layoutPreference == preference) {
      return;
    }

    await _repository.saveLayoutPreference(preference);
    _layoutPreference = preference;
    notifyListeners();
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    await _repository.saveThemePreference(preference);
    _themePreference = preference;
    notifyListeners();
  }

  Future<void> setSortPreference(ShortcutSortPreference preference) async {
    if (_sortPreference == preference) {
      return;
    }

    await _repository.saveSortPreference(preference);
    _sortPreference = preference;
    notifyListeners();
  }

  static List<ShortcutEntry> _applySort(
    List<ShortcutEntry> entries,
    ShortcutSortPreference preference,
  ) {
    if (preference == ShortcutSortPreference.manual || entries.length < 2) {
      return entries;
    }

    final List<MapEntry<int, ShortcutEntry>> indexed =
        <MapEntry<int, ShortcutEntry>>[
          for (int i = 0; i < entries.length; i++)
            MapEntry<int, ShortcutEntry>(i, entries[i]),
        ];

    indexed.sort((
      MapEntry<int, ShortcutEntry> a,
      MapEntry<int, ShortcutEntry> b,
    ) {
      final ShortcutEntry x = a.value;
      final ShortcutEntry y = b.value;

      switch (preference) {
        case ShortcutSortPreference.manual:
          return a.key.compareTo(b.key);
        case ShortcutSortPreference.alphabetical:
          final int byName = x.name.toLowerCase().compareTo(
            y.name.toLowerCase(),
          );
          if (byName != 0) return byName;
          return a.key.compareTo(b.key);
        case ShortcutSortPreference.newest:
          final int byCreated = y.createdAtIso.compareTo(x.createdAtIso);
          if (byCreated != 0) return byCreated;
          return a.key.compareTo(b.key);
        case ShortcutSortPreference.recent:
          final int recency = _compareRecency(x, y);
          if (recency != 0) return recency;
          return a.key.compareTo(b.key);
        case ShortcutSortPreference.mostUsed:
          final int usage = y.launchCount.compareTo(x.launchCount);
          if (usage != 0) return usage;
          final int recency = _compareRecency(x, y);
          if (recency != 0) return recency;
          return a.key.compareTo(b.key);
      }
    });

    return indexed
        .map((MapEntry<int, ShortcutEntry> e) => e.value)
        .toList(growable: false);
  }

  static int _compareRecency(ShortcutEntry a, ShortcutEntry b) {
    final String? aIso = a.lastLaunchedAtIso;
    final String? bIso = b.lastLaunchedAtIso;
    if (aIso == null && bIso == null) return 0;
    if (aIso == null) return 1;
    if (bIso == null) return -1;
    return bIso.compareTo(aIso);
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

    final List<ShortcutEntry> updatedEntries = <ShortcutEntry>[
      newEntry,
      ..._entries,
    ];

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

    final List<ShortcutEntry> updatedEntries = _entries
        .map((ShortcutEntry entry) => entry.id == id ? updatedEntry : entry)
        .toList(growable: false);

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

  Future<void> deleteShortcuts(Iterable<String> ids) async {
    final Set<String> idsToRemove = ids.toSet();
    if (idsToRemove.isEmpty) {
      return;
    }

    final List<ShortcutEntry> updatedEntries = _entries
        .where((ShortcutEntry entry) => !idsToRemove.contains(entry.id))
        .toList(growable: false);

    if (updatedEntries.length == _entries.length) {
      return;
    }

    await _repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.saveShortcuts(const <ShortcutEntry>[]);
    _entries = const <ShortcutEntry>[];
    notifyListeners();
  }

  Future<void> reorderShortcuts(int oldIndex, int newIndex) async {
    final List<ShortcutEntry> updatedEntries = List<ShortcutEntry>.from(
      _entries,
    );
    if (oldIndex < 0 ||
        oldIndex >= updatedEntries.length ||
        newIndex < 0 ||
        newIndex > updatedEntries.length) {
      return;
    }

    int targetIndex = newIndex;
    if (oldIndex < newIndex) {
      targetIndex -= 1;
    }
    if (oldIndex == targetIndex) {
      return;
    }

    final ShortcutEntry movedEntry = updatedEntries.removeAt(oldIndex);
    updatedEntries.insert(targetIndex, movedEntry);

    await _repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<BackupExportOutcome> exportShortcutsToFile({
    Iterable<ShortcutEntry>? entriesOverride,
  }) async {
    final List<ShortcutEntry> entriesToExport = entriesOverride == null
        ? _entries
        : List<ShortcutEntry>.unmodifiable(entriesOverride);

    final DateTime now = DateTime.now().toUtc();
    final String contents = _backupService.encode(
      entries: entriesToExport,
      exportedAtUtc: now,
    );
    final String suggestedName = _backupService.suggestedFileName(now);

    final String? destination = await _backupGateway
        .writeBackupToUserChosenLocation(
          suggestedFileName: suggestedName,
          contents: contents,
        );

    if (destination == null) {
      return const BackupExportCancelled();
    }

    return BackupExportSuccess(
      exportedCount: entriesToExport.length,
      destinationLabel: destination.isEmpty ? suggestedName : destination,
    );
  }

  Future<BackupImportOutcome> importShortcutsFromFile({
    required BackupImportMode mode,
  }) async {
    final BackupFileReadResult? fileResult = await _backupGateway
        .readBackupFromUserChosenLocation();
    if (fileResult == null) {
      return const BackupImportCancelled();
    }

    final List<ShortcutEntry> incomingEntries = _backupService.decode(
      fileResult.contents,
    );

    final List<ShortcutEntry> nextEntries;
    final int added;
    final int skipped;

    switch (mode) {
      case BackupImportMode.replace:
        nextEntries = List<ShortcutEntry>.from(incomingEntries);
        added = incomingEntries.length;
        skipped = 0;
        break;
      case BackupImportMode.merge:
        final Set<String> existingNames = _entries
            .map((ShortcutEntry entry) => entry.name.trim().toLowerCase())
            .toSet();
        final List<ShortcutEntry> additions = <ShortcutEntry>[];
        for (final ShortcutEntry entry in incomingEntries) {
          final String key = entry.name.trim().toLowerCase();
          if (existingNames.add(key)) {
            additions.add(entry);
          }
        }
        nextEntries = <ShortcutEntry>[...additions, ..._entries];
        added = additions.length;
        skipped = incomingEntries.length - added;
        break;
    }

    await _repository.saveShortcuts(nextEntries);
    _entries = nextEntries;
    notifyListeners();

    return BackupImportSuccess(
      mode: mode,
      fileEntryCount: incomingEntries.length,
      added: added,
      skipped: skipped,
      totalAfter: nextEntries.length,
    );
  }

  Future<void> launchShortcut(ShortcutEntry entry) async {
    _launchingShortcutId = entry.id;
    notifyListeners();

    try {
      await _launcher.openShortcut(entry);
      await _recordSuccessfulLaunch(entry.id);
    } finally {
      _launchingShortcutId = null;
      notifyListeners();
    }
  }

  Future<void> _recordSuccessfulLaunch(String entryId) async {
    final int index = _entries.indexWhere(
      (ShortcutEntry entry) => entry.id == entryId,
    );
    if (index < 0) {
      return;
    }

    final ShortcutEntry existing = _entries[index];
    final ShortcutEntry updated = existing.copyWith(
      lastLaunchedAtIso: DateTime.now().toUtc().toIso8601String(),
      launchCount: existing.launchCount + 1,
    );

    final List<ShortcutEntry> next = List<ShortcutEntry>.from(_entries);
    next[index] = updated;

    try {
      await _repository.saveShortcuts(next);
      _entries = next;
    } on ShortcutStorageException {
      // Best-effort telemetry: a failed write must not surface as a launch
      // failure to the user, who already saw the YouTube app open.
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
}
