import 'package:flutter/foundation.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/services/backup_service.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/repositories/shortcut_repository.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_launcher_service.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_url_formatter.dart';

class ShortcutStore extends ChangeNotifier {
  ShortcutStore({
    required this.repository,
    required this.formatter,
    required this.launcher,
    this.backupService = const ShortcutBackupService(),
    this.backupGateway = const NoOpBackupFileGateway(),
  });

  final ShortcutRepository repository;
  final YoutubeUrlFormatter formatter;
  final YoutubeLauncher launcher;
  final ShortcutBackupService backupService;
  final BackupFileGateway backupGateway;

  List<ShortcutEntry> _entries = const <ShortcutEntry>[];
  bool _isLoading = false;
  String? _launchingShortcutId;
  AppThemePreference _themePreference = AppThemePreference.system;
  AppLayoutPreference _layoutPreference = AppLayoutPreference.grid;
  ShortcutSortPreference _sortPreference = ShortcutSortPreference.manual;
  bool _favoritesFirst = false;

  List<ShortcutEntry> get entries => List<ShortcutEntry>.unmodifiable(_entries);
  List<ShortcutEntry> get entriesSorted => List<ShortcutEntry>.unmodifiable(
    _applySort(_entries, _sortPreference, _favoritesFirst),
  );
  bool get isLoading => _isLoading;
  String? get launchingShortcutId => _launchingShortcutId;
  AppThemePreference get themePreference => _themePreference;
  AppLayoutPreference get layoutPreference => _layoutPreference;
  ShortcutSortPreference get sortPreference => _sortPreference;
  bool get favoritesFirst => _favoritesFirst;

  String? fullUrlPreviewForInput(String urlInput) {
    try {
      return formatter.buildDisplayUrlPreview(urlInput);
    } on ShortcutValidationException {
      return null;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<ShortcutEntry> loadedEntries = await repository
          .loadShortcuts();
      final AppThemePreference loadedThemePreference = await repository
          .loadThemePreference();
      final AppLayoutPreference loadedLayoutPreference = await repository
          .loadLayoutPreference();
      final ShortcutSortPreference loadedSortPreference = await repository
          .loadSortPreference();
      final bool loadedFavoritesFirst = await repository
          .loadFavoritesFirstPreference();
      _entries = loadedEntries;
      _themePreference = loadedThemePreference;
      _layoutPreference = loadedLayoutPreference;
      _sortPreference = loadedSortPreference;
      _favoritesFirst = loadedFavoritesFirst;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLayoutPreference(AppLayoutPreference preference) async {
    if (_layoutPreference == preference) {
      return;
    }

    await repository.saveLayoutPreference(preference);
    _layoutPreference = preference;
    notifyListeners();
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    await repository.saveThemePreference(preference);
    _themePreference = preference;
    notifyListeners();
  }

  Future<void> setSortPreference(ShortcutSortPreference preference) async {
    if (_sortPreference == preference) {
      return;
    }

    await repository.saveSortPreference(preference);
    _sortPreference = preference;
    notifyListeners();
  }

  Future<void> setFavoritesFirst(bool favoritesFirst) async {
    if (_favoritesFirst == favoritesFirst) {
      return;
    }

    await repository.saveFavoritesFirstPreference(favoritesFirst);
    _favoritesFirst = favoritesFirst;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final int index = _entries.indexWhere((ShortcutEntry e) => e.id == id);
    if (index < 0) return;

    final ShortcutEntry existing = _entries[index];
    final ShortcutEntry updated = existing.copyWith(
      isFavorite: !existing.isFavorite,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    final List<ShortcutEntry> next = List<ShortcutEntry>.from(_entries);
    next[index] = updated;

    await repository.saveShortcuts(next);
    _entries = next;
    notifyListeners();
  }

  static List<ShortcutEntry> _applySort(
    List<ShortcutEntry> entries,
    ShortcutSortPreference preference,
    bool favoritesFirst,
  ) {
    if (entries.length < 2) {
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

      if (favoritesFirst && x.isFavorite != y.isFavorite) {
        return x.isFavorite ? -1 : 1;
      }

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
    List<String> tags = const <String>[],
    bool isFavorite = false,
    bool isPrivate = false,
    String? customColorHex,
    String? customIconName,
  }) async {
    final ShortcutEntry newEntry = formatter.createEntry(
      nameInput: nameInput,
      urlInput: urlInput,
      tags: tags,
      isFavorite: isFavorite,
      isPrivate: isPrivate,
      customColorHex: customColorHex,
      customIconName: customIconName,
    );

    _throwIfDuplicateName(normalizedName: newEntry.name.trim().toLowerCase());

    final List<ShortcutEntry> updatedEntries = <ShortcutEntry>[
      newEntry,
      ..._entries,
    ];

    await repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> updateShortcut({
    required String id,
    required String nameInput,
    required String urlInput,
    List<String>? tags,
    bool? isFavorite,
    bool? isPrivate,
    String? customColorHex,
    bool clearCustomColorHex = false,
    String? customIconName,
    bool clearCustomIconName = false,
  }) async {
    final ShortcutEntry existingEntry = _entries.firstWhere(
      (ShortcutEntry entry) => entry.id == id,
      orElse: () => throw const ShortcutStorageException(
        AppErrorCode.shortcutMissing,
        'This shortcut no longer exists. Reload and try again.',
      ),
    );

    final ShortcutEntry updatedEntry = formatter.updateEntry(
      existingEntry: existingEntry,
      nameInput: nameInput,
      urlInput: urlInput,
      tags: tags,
      isFavorite: isFavorite,
      isPrivate: isPrivate,
      customColorHex: customColorHex,
      clearCustomColorHex: clearCustomColorHex,
      customIconName: customIconName,
      clearCustomIconName: clearCustomIconName,
    );

    _throwIfDuplicateName(
      normalizedName: updatedEntry.name.trim().toLowerCase(),
      excludedId: updatedEntry.id,
    );

    final List<ShortcutEntry> updatedEntries = _entries
        .map((ShortcutEntry entry) => entry.id == id ? updatedEntry : entry)
        .toList(growable: false);

    await repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> deleteShortcut(String id) async {
    final List<ShortcutEntry> updatedEntries = _entries
        .where((ShortcutEntry entry) => entry.id != id)
        .toList(growable: false);

    await repository.saveShortcuts(updatedEntries);
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

    await repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await repository.saveShortcuts(const <ShortcutEntry>[]);
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

    await repository.saveShortcuts(updatedEntries);
    _entries = updatedEntries;
    notifyListeners();
  }

  Future<BackupFileReadResult?> readBackupFromFile() async {
    return backupGateway.readBackupFromUserChosenLocation();
  }

  Future<BackupExportOutcome> exportShortcutsToFile({
    Iterable<ShortcutEntry>? entriesOverride,
    String? passphrase,
  }) async {
    final List<ShortcutEntry> entriesToExport = entriesOverride == null
        ? _entries
        : List<ShortcutEntry>.unmodifiable(entriesOverride);

    final DateTime now = DateTime.now().toUtc();
    final bool useEncryption = passphrase != null && passphrase.isNotEmpty;
    final String contents = useEncryption
        ? backupService.encodeEncrypted(
            entries: entriesToExport,
            passphrase: passphrase,
            exportedAtUtc: now,
          )
        : backupService.encode(entries: entriesToExport, exportedAtUtc: now);
    final String suggestedName = backupService.suggestedFileName(
      now,
      isEncrypted: useEncryption,
    );

    final String? destination = await backupGateway
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
    BackupFileReadResult? fileResultOverride,
    String? passphrase,
  }) async {
    final BackupFileReadResult? fileResult =
        fileResultOverride ??
        await backupGateway.readBackupFromUserChosenLocation();
    if (fileResult == null) {
      return const BackupImportCancelled();
    }

    final bool encrypted = backupService.isEncrypted(fileResult.contents);
    final List<ShortcutEntry> incomingEntries = encrypted
        ? backupService.decodeEncrypted(fileResult.contents, passphrase ?? '')
        : backupService.decode(fileResult.contents);

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

    await repository.saveShortcuts(nextEntries);
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

  Map<String, dynamic> exportSettingsMap() {
    return <String, dynamic>{
      'theme': _themePreference.name,
      'layout': _layoutPreference.name,
      'sort': _sortPreference.name,
      'favoritesFirst': _favoritesFirst,
    };
  }

  Future<BackupImportOutcome> importFullBackupPayload({
    required List<ShortcutEntry> incomingEntries,
    required BackupImportMode mode,
    Map<String, dynamic>? settings,
  }) async {
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

    await repository.saveShortcuts(nextEntries);
    _entries = nextEntries;

    if (settings != null) {
      final String? themeStr = settings['theme']?.toString();
      if (themeStr != null) {
        for (final AppThemePreference pref in AppThemePreference.values) {
          if (pref.name == themeStr) {
            await repository.saveThemePreference(pref);
            _themePreference = pref;
            break;
          }
        }
      }
      final String? layoutStr = settings['layout']?.toString();
      if (layoutStr != null) {
        for (final AppLayoutPreference pref in AppLayoutPreference.values) {
          if (pref.name == layoutStr) {
            await repository.saveLayoutPreference(pref);
            _layoutPreference = pref;
            break;
          }
        }
      }
      final String? sortStr = settings['sort']?.toString();
      if (sortStr != null) {
        for (final ShortcutSortPreference pref
            in ShortcutSortPreference.values) {
          if (pref.name == sortStr) {
            await repository.saveSortPreference(pref);
            _sortPreference = pref;
            break;
          }
        }
      }
      final dynamic favFirstRaw = settings['favoritesFirst'];
      if (favFirstRaw is bool) {
        await repository.saveFavoritesFirstPreference(favFirstRaw);
        _favoritesFirst = favFirstRaw;
      }
    }

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
      await launcher.openShortcut(entry);
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
      await repository.saveShortcuts(next);
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
        AppErrorCode.duplicateName,
        'Choose a different shortcut name. Names must be unique.',
      );
    }
  }
}
