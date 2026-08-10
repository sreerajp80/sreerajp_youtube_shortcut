import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../backup_service.dart';
import '../privacy_lock_store.dart';
import '../share_intent_service.dart';
import '../shortcut_models.dart';
import '../shortcut_store.dart';
import '../widgets/shortcut_qr_dialog.dart';
import 'add_shortcut_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'shortcut_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isReorderMode = false;
  final Set<String> _selectedIds = <String>{};
  bool _isExportingSelection = false;
  StreamSubscription<String>? _sharedTextSubscription;
  bool _isHandlingSharedText = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<ShortcutTargetType> _typeFilters = <ShortcutTargetType>{};
  final Set<String> _tagFilters = <String>{};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  bool get _isFilterActive =>
      _searchQuery.trim().isNotEmpty ||
      _typeFilters.isNotEmpty ||
      _tagFilters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _consumeInitialSharedText();
      _subscribeToIncomingSharedText();
    });
  }

  @override
  void dispose() {
    _sharedTextSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ShortcutEntry> _applyFilters(
    List<ShortcutEntry> entries, {
    bool hidePrivate = false,
  }) {
    return entries
        .where((ShortcutEntry entry) {
          if (hidePrivate && entry.isPrivate) {
            return false;
          }
          if (_typeFilters.isNotEmpty &&
              !_typeFilters.contains(entry.targetType)) {
            return false;
          }
          if (_tagFilters.isNotEmpty &&
              !_tagFilters.any((String tag) => entry.tags.contains(tag))) {
            return false;
          }
          if (_searchQuery.trim().isNotEmpty) {
            final String query = _searchQuery.trim().toLowerCase();
            final bool nameMatch = entry.name.toLowerCase().contains(query);
            final bool tagMatch = entry.tags.any(
              (String t) => t.toLowerCase().contains(query),
            );
            final bool urlMatch = entry.canonicalUrl
                .toLowerCase()
                .contains(query);
            if (!nameMatch && !tagMatch && !urlMatch) {
              return false;
            }
          }
          return true;
        })
        .toList(growable: false);
  }

  void _onSearchChanged(String value) {
    if (value == _searchQuery) return;
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _toggleTypeFilter(ShortcutTargetType type) {
    setState(() {
      if (!_typeFilters.remove(type)) {
        _typeFilters.add(type);
      }
    });
  }

  void _toggleTagFilter(String tag) {
    setState(() {
      if (!_tagFilters.remove(tag)) {
        _tagFilters.add(tag);
      }
    });
  }

  Future<void> _consumeInitialSharedText() async {
    final SharedTextSource source = context.read<SharedTextSource>();
    final String? text = await source.consumeInitialSharedText();
    if (text == null || !mounted) return;
    await _openAddShortcutFromShare(text);
  }

  void _subscribeToIncomingSharedText() {
    final SharedTextSource source = context.read<SharedTextSource>();
    _sharedTextSubscription = source.incomingSharedText.listen((String text) {
      if (!mounted) return;
      _openAddShortcutFromShare(text);
    });
  }

  Future<void> _openAddShortcutFromShare(String sharedText) async {
    if (_isHandlingSharedText) return;
    final String? prefill = extractFirstUrlOrRaw(sharedText);
    if (prefill == null || prefill.isEmpty || !mounted) return;

    _isHandlingSharedText = true;
    try {
      final String? message = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (BuildContext context) =>
              AddShortcutScreen(initialUrlInput: prefill),
        ),
      );

      if (message == null || !mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      _isHandlingSharedText = false;
    }
  }

  void _enterReorderMode() {
    if (!_isReorderMode) {
      setState(() => _isReorderMode = true);
    }
  }

  void _exitReorderMode() {
    if (_isReorderMode) {
      setState(() => _isReorderMode = false);
    }
  }

  void _enterSelectionWith(String id) {
    setState(() {
      _isReorderMode = false;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    if (_selectedIds.isEmpty) {
      return;
    }
    setState(_selectedIds.clear);
  }

  void _selectAll(List<ShortcutEntry> entries) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(entries.map((ShortcutEntry e) => e.id));
    });
  }

  void _pruneStaleSelectedIds(List<ShortcutEntry> entries) {
    if (_selectedIds.isEmpty) {
      return;
    }
    final Set<String> liveIds = entries.map((ShortcutEntry e) => e.id).toSet();
    _selectedIds.removeWhere((String id) => !liveIds.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    final ShortcutStore store = context.watch<ShortcutStore>();
    final PrivacyLockStore lockStore = context.watch<PrivacyLockStore>();
    final ThemeData theme = Theme.of(context);

    if (_isReorderMode && store.entries.isEmpty) {
      _isReorderMode = false;
    }
    _pruneStaleSelectedIds(store.entries);

    final bool hidePrivate =
        lockStore.privateLockEnabled && !lockStore.isPrivateVaultUnlocked;

    final List<ShortcutEntry> visibleEntries = _isReorderMode
        ? store.entries
        : _applyFilters(store.entriesSorted, hidePrivate: hidePrivate);

    final PreferredSizeWidget appBar;
    if (_isReorderMode) {
      appBar = AppBar(
        leading: IconButton(
          tooltip: 'Exit reorder mode',
          icon: const Icon(Icons.close_rounded),
          onPressed: _exitReorderMode,
        ),
        title: const Text('Reorder shortcuts'),
        actions: <Widget>[
          TextButton(onPressed: _exitReorderMode, child: const Text('Done')),
        ],
      );
    } else if (_isSelectionMode) {
      appBar = _buildSelectionAppBar(context, store, visibleEntries);
    } else {
      appBar = _buildDefaultAppBar(context, store);
    }

    final String subtitle;
    if (store.entries.isEmpty) {
      subtitle =
          'Save the links you open often. Each shortcut stays local on this device.';
    } else if (_isReorderMode) {
      subtitle =
          'Long-press and drag cards to reorder them. Tap Done when finished.';
    } else if (_isSelectionMode) {
      subtitle = 'Tap to toggle selection. Press back to exit.';
    } else {
      subtitle = 'Tap a shortcut to open it. Long-press to select multiple.';
    }

    final bool showFilterBar =
        store.entries.isNotEmpty && !_isReorderMode && !_isSelectionMode;
    final bool showNoMatches =
        !store.isLoading &&
        store.entries.isNotEmpty &&
        visibleEntries.isEmpty &&
        _isFilterActive;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _clearSelection();
      },
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: (_isReorderMode || _isSelectionMode)
            ? null
            : _GlassAddFab(onPressed: () => _openAddShortcut(context)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
          children: <Widget>[
            if (store.entries.isEmpty) ...<Widget>[
              _HomeHero(entryCount: store.entries.length),
              const SizedBox(height: 20),
            ],
            Row(
              children: <Widget>[
                Text(
                  'Shortcut Sections',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (store.entries.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2DD4BF)
                          : const Color(0xFFD73A23),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isFilterActive && !_isReorderMode
                          ? '${visibleEntries.length}/${store.entries.length}'
                          : '${store.entries.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (showFilterBar) ...<Widget>[
              const SizedBox(height: 14),
              _ShortcutFilterBar(
                searchController: _searchController,
                searchQuery: _searchQuery,
                typeFilters: _typeFilters,
                tagFilters: _tagFilters,
                availableTags: () {
                  final Set<String> tagsSet = <String>{};
                  for (final ShortcutEntry entry in store.entries) {
                    tagsSet.addAll(entry.tags);
                  }
                  final List<String> list = tagsSet.toList()..sort();
                  return list;
                }(),
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
                onToggleType: _toggleTypeFilter,
                onToggleTagFilter: _toggleTagFilter,
              ),
            ],
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
            else if (showNoMatches)
              _NoFilterMatchesState(onClear: _clearAllFilters)
            else
              _ShortcutGrid(
                entries: visibleEntries,
                launchingShortcutId: store.launchingShortcutId,
                isList: store.layoutPreference == AppLayoutPreference.list,
                isReorderMode: _isReorderMode,
                isSelectionMode: _isSelectionMode,
                selectedIds: _selectedIds,
                onOpen: (ShortcutEntry entry) =>
                    _launchShortcut(context, entry),
                onSwipeDelete: (ShortcutEntry entry) =>
                    _swipeDeleteShortcut(context, entry),
                onReorder: (int oldIndex, int newIndex) {
                  _reorderShortcuts(context, oldIndex, newIndex);
                },
                onLongPressEntry: (ShortcutEntry entry) =>
                    _enterSelectionWith(entry.id),
                onToggleSelect: (ShortcutEntry entry) =>
                    _toggleSelection(entry.id),
              ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _typeFilters.clear();
      _tagFilters.clear();
    });
  }

  PreferredSizeWidget _buildDefaultAppBar(
    BuildContext context,
    ShortcutStore store,
  ) {
    final bool sortIsManual =
        store.sortPreference == ShortcutSortPreference.manual;
    final ThemeData theme = Theme.of(context);

    return AppBar(
      title: const Text('YT Shortcuts'),
      actions: <Widget>[
        IconButton(
          tooltip: 'Scan QR code',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const QrScannerScreen(),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
        if (store.entries.isNotEmpty) ...<Widget>[
          IconButton(
            tooltip: store.layoutPreference == AppLayoutPreference.grid
                ? 'Switch to list view'
                : 'Switch to grid view',
            icon: Icon(
              store.layoutPreference == AppLayoutPreference.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            onPressed: () => _toggleLayout(context, store.layoutPreference),
          ),
          PopupMenuButton<dynamic>(
            tooltip: 'Sort shortcuts',
            icon: Icon(
              Icons.sort_rounded,
              color: store.favoritesFirst ? theme.colorScheme.primary : null,
            ),
            onSelected: (dynamic value) {
              if (value == 'toggle_favorites_first') {
                _toggleFavoritesFirst(context, store.favoritesFirst);
              } else if (value is ShortcutSortPreference) {
                _setSortPreference(context, value);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
              CheckedPopupMenuItem<String>(
                value: 'toggle_favorites_first',
                checked: store.favoritesFirst,
                child: const Text('Favorites first'),
              ),
              const PopupMenuDivider(),
              for (final ShortcutSortPreference preference
                  in ShortcutSortPreference.values)
                CheckedPopupMenuItem<ShortcutSortPreference>(
                  value: preference,
                  checked: store.sortPreference == preference,
                  child: Text(preference.label),
                ),
            ],
          ),
          PopupMenuButton<_HomeAction>(
            tooltip: 'Options',
            onSelected: (_HomeAction action) =>
                _handleHomeAction(context, action),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_HomeAction>>[
                  PopupMenuItem<_HomeAction>(
                    value: _HomeAction.reorder,
                    enabled: sortIsManual,
                    child: Text(
                      sortIsManual
                          ? 'Reorder shortcuts'
                          : 'Reorder shortcuts (manual sort only)',
                    ),
                  ),
                  const PopupMenuItem<_HomeAction>(
                    value: _HomeAction.clearAll,
                    child: Text('Clear all shortcuts'),
                  ),
                ],
          ),
        ],
        IconButton(
          tooltip: 'Settings',
          onPressed: () => _openSettings(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Future<void> _toggleFavoritesFirst(
    BuildContext context,
    bool currentFavoritesFirst,
  ) async {
    try {
      await context
          .read<ShortcutStore>()
          .setFavoritesFirst(!currentFavoritesFirst);
    } on ShortcutStorageException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _setSortPreference(
    BuildContext context,
    ShortcutSortPreference preference,
  ) async {
    try {
      await context.read<ShortcutStore>().setSortPreference(preference);
    } on ShortcutStorageException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    ShortcutStore store,
    List<ShortcutEntry> visibleEntries,
  ) {
    final int count = _selectedIds.length;
    final bool single = count == 1;
    final bool allVisibleSelected =
        visibleEntries.isNotEmpty &&
        visibleEntries.every((ShortcutEntry e) => _selectedIds.contains(e.id));

    final ShortcutEntry? singleEntry = single
        ? store.entries.firstWhere(
            (ShortcutEntry e) => e.id == _selectedIds.first,
          )
        : null;

    return AppBar(
      leading: IconButton(
        tooltip: 'Clear selection',
        icon: const Icon(Icons.close_rounded),
        onPressed: _clearSelection,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$count'),
          const SizedBox(width: 6),
          const Icon(Icons.check_rounded, size: 20),
        ],
      ),
      actions: <Widget>[
        if (single && singleEntry != null) ...<Widget>[
          IconButton(
            tooltip: 'Show QR code',
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () => ShortcutQrDialog.show(context, singleEntry),
          ),
          IconButton(
            tooltip: 'Shortcut details',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _openDetailsFromSelection(context, singleEntry),
          ),
          IconButton(
            tooltip: 'Edit shortcut',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editFromSelection(context, singleEntry),
          ),
          IconButton(
            tooltip: 'Copy URL',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copyUrlFromSelection(context, singleEntry),
          ),
        ],
        IconButton(
          tooltip: 'Export selected',
          icon: _isExportingSelection
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share_rounded),
          onPressed: _isExportingSelection
              ? null
              : () => _exportSelection(context, store),
        ),
        IconButton(
          tooltip: 'Delete selected',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _deleteSelection(context, store),
        ),
        if (!allVisibleSelected)
          PopupMenuButton<_SelectionAction>(
            tooltip: 'More',
            onSelected: (_SelectionAction action) {
              if (action == _SelectionAction.selectAll) {
                _selectAll(visibleEntries);
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<_SelectionAction>>[
                  PopupMenuItem<_SelectionAction>(
                    value: _SelectionAction.selectAll,
                    child: Text('Select all'),
                  ),
                ],
          ),
      ],
    );
  }

  Future<void> _toggleLayout(
    BuildContext context,
    AppLayoutPreference current,
  ) async {
    final AppLayoutPreference next = current == AppLayoutPreference.grid
        ? AppLayoutPreference.list
        : AppLayoutPreference.grid;
    await context.read<ShortcutStore>().setLayoutPreference(next);
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

  Future<bool?> _swipeDeleteShortcut(
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
      return false;
    }

    await context.read<ShortcutStore>().deleteShortcut(entry.id);

    if (!context.mounted) {
      return true;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "${entry.name}".')));

    return true;
  }

  Future<void> _handleHomeAction(
    BuildContext context,
    _HomeAction action,
  ) async {
    switch (action) {
      case _HomeAction.reorder:
        _enterReorderMode();
      case _HomeAction.clearAll:
        await _confirmAndClearAll(context);
    }
  }

  Future<void> _confirmAndClearAll(BuildContext context) async {
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

  Future<void> _editFromSelection(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    await _openEditShortcut(context, entry);
    if (!mounted) return;
    _clearSelection();
  }

  Future<void> _openDetailsFromSelection(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) =>
            ShortcutDetailScreen(shortcutId: entry.id),
      ),
    );

    if (!mounted) return;
    _clearSelection();

    if (message == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyUrlFromSelection(
    BuildContext context,
    ShortcutEntry entry,
  ) async {
    await Clipboard.setData(ClipboardData(text: entry.canonicalUrl));
    if (!context.mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('URL copied to clipboard.')));
  }

  Future<void> _deleteSelection(
    BuildContext context,
    ShortcutStore store,
  ) async {
    final List<ShortcutEntry> picked = store.entries
        .where((ShortcutEntry entry) => _selectedIds.contains(entry.id))
        .toList(growable: false);
    if (picked.isEmpty) return;

    final int count = picked.length;
    final String message = count == 1
        ? 'Remove "${picked.first.name}" from the local shortcut list?'
        : 'Remove $count shortcuts from the local shortcut list?';

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            count == 1 ? 'Delete shortcut?' : 'Delete $count shortcuts?',
          ),
          content: Text(message),
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

    final List<String> ids = picked
        .map((ShortcutEntry e) => e.id)
        .toList(growable: false);
    await store.deleteShortcuts(ids);
    if (!mounted) return;
    _clearSelection();

    if (!context.mounted) return;
    final String snack = count == 1
        ? 'Removed "${picked.first.name}".'
        : 'Removed $count shortcuts.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
  }

  Future<void> _exportSelection(
    BuildContext context,
    ShortcutStore store,
  ) async {
    final List<ShortcutEntry> picked = store.entries
        .where((ShortcutEntry entry) => _selectedIds.contains(entry.id))
        .toList(growable: false);
    if (picked.isEmpty) return;

    setState(() => _isExportingSelection = true);
    try {
      final BackupExportOutcome outcome = await store.exportShortcutsToFile(
        entriesOverride: picked,
      );
      if (!context.mounted) return;
      switch (outcome) {
        case BackupExportSuccess(
          :final int exportedCount,
          :final String destinationLabel,
        ):
          _clearSelection();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Exported $exportedCount shortcut'
                '${exportedCount == 1 ? '' : 's'} to "$destinationLabel".',
              ),
            ),
          );
        case BackupExportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Export cancelled.')));
      }
    } on ShortcutBackupException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isExportingSelection = false);
      }
    }
  }
}

enum _HomeAction { reorder, clearAll }

enum _SelectionAction { selectAll }

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
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
              child: _ReorderableShortcutGridCard(
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

class _ReorderableShortcutGridCard extends StatelessWidget {
  const _ReorderableShortcutGridCard({
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
            final Widget card = _ShortcutCard(
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

class _ShortcutFilterBar extends StatelessWidget {
  const _ShortcutFilterBar({
    required this.searchController,
    required this.searchQuery,
    required this.typeFilters,
    required this.tagFilters,
    required this.availableTags,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleType,
    required this.onToggleTagFilter,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final Set<ShortcutTargetType> typeFilters;
  final Set<String> tagFilters;
  final List<String> availableTags;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<ShortcutTargetType> onToggleType;
  final ValueChanged<String> onToggleTagFilter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search shortcuts',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClearSearch,
                  ),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.6,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ...ShortcutTargetType.values.map((ShortcutTargetType type) {
              return FilterChip(
                label: Text(type.label),
                selected: typeFilters.contains(type),
                onSelected: (_) => onToggleType(type),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }),
            ...availableTags.map((String tag) {
              final bool isSelected = tagFilters.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) => onToggleTagFilter(tag),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _NoFilterMatchesState extends StatelessWidget {
  const _NoFilterMatchesState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'No matching shortcuts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search term or clear the filters.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
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
    required this.isReorderMode,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onOpen,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  final ShortcutEntry entry;
  final bool isLaunching;
  final bool isReorderMode;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color typeAccent = entry.targetType.accent(theme.brightness);
    final Color? customColor = _parseColorHex(entry.customColorHex);
    final Color avatarColor = customColor ?? _avatarColorFor(entry.id);
    final String avatarLetters = _avatarLettersFor(entry.name);
    final IconData? customIcon = _parseIconData(entry.customIconName);
    const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(20));

    const Color darkBaseTop = Color(0xFF12181A);
    const Color darkBaseBottom = Color(0xFF0A0E10);
    const Color lightBaseTop = Color(0xFFFFFFFF);
    const Color lightBaseBottom = Color(0xFFF6F1EE);

    final Color cardTopColor = isDark
        ? Color.alphaBlend(typeAccent.withValues(alpha: 0.18), darkBaseTop)
        : Color.alphaBlend(typeAccent.withValues(alpha: 0.08), lightBaseTop);
    final Color cardBottomColor = isDark
        ? Color.alphaBlend(typeAccent.withValues(alpha: 0.05), darkBaseBottom)
        : Color.alphaBlend(typeAccent.withValues(alpha: 0.03), lightBaseBottom);
    final Color baseBorderColor = typeAccent.withValues(
      alpha: isDark ? 0.40 : 0.28,
    );
    final Color borderColor = isSelected
        ? theme.colorScheme.primary
        : baseBorderColor;
    final double borderWidth = isSelected ? 2.0 : 1.0;

    final List<BoxShadow> cardShadows = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: typeAccent.withValues(alpha: 0.22),
              offset: const Offset(0, 6),
              blurRadius: 22,
              spreadRadius: 0.5,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              offset: const Offset(0, 10),
              blurRadius: 18,
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: typeAccent.withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 22,
              spreadRadius: 0.5,
            ),
            const BoxShadow(
              color: Color(0x14A56E5A),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
            const BoxShadow(
              color: Color(0xC9FFFFFF),
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ];

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: DecoratedBox(
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
              border: Border.fromBorderSide(
                BorderSide(color: borderColor, width: borderWidth),
              ),
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
                            Colors.white.withValues(
                              alpha: isDark ? 0.10 : 0.45,
                            ),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: const Alignment(0.5, 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: cardBorderRadius,
                  onTap: (isLaunching || isReorderMode)
                      ? null
                      : (isSelectionMode ? onToggleSelect : onOpen),
                  onLongPress: (isLaunching || isReorderMode)
                      ? null
                      : onLongPress,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                color: avatarColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: avatarColor.withValues(
                                      alpha: isDark ? 0.45 : 0.30,
                                    ),
                                    offset: const Offset(0, 3),
                                    blurRadius: 12,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: customIcon != null
                                    ? Icon(
                                        customIcon,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : Text(
                                        avatarLetters,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.2,
                                          height: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  entry.name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
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
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      typeAccent.withValues(
                                        alpha: isDark ? 0.36 : 0.22,
                                      ),
                                      typeAccent.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: typeAccent.withValues(
                                      alpha: isDark ? 0.62 : 0.30,
                                    ),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: typeAccent.withValues(
                                        alpha: isDark ? 0.26 : 0.12,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  entry.targetType.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: typeAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              for (final String tag in entry.tags)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer
                                        .withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme
                                          .colorScheme
                                          .onTertiaryContainer,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !isLaunching,
                    child: AnimatedOpacity(
                      opacity: isLaunching ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: cardBorderRadius,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: isLaunching
                                ? const CircularProgressIndicator.adaptive(
                                    strokeWidth: 2.5,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isSelectionMode && !isReorderMode)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: entry.isFavorite
                          ? 'Unpin favorite'
                          : 'Pin favorite',
                      icon: Icon(
                        entry.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: entry.isFavorite
                            ? Colors.amber
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.45,
                              ),
                      ),
                      onPressed: () {
                        context.read<ShortcutStore>().toggleFavorite(entry.id);
                      },
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IgnorePointer(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassAddFab extends StatelessWidget {
  const _GlassAddFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color accent = isDark
        ? const Color(0xFF2DD4BF)
        : const Color(0xFFD73A23);
    const double size = 64;
    const BorderRadius radius = BorderRadius.all(Radius.circular(22));

    final Color fillTop = isDark
        ? accent.withValues(alpha: 0.28)
        : accent.withValues(alpha: 0.22);
    final Color fillBottom = isDark
        ? accent.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.55);
    final Color borderColor = isDark
        ? accent.withValues(alpha: 0.60)
        : accent.withValues(alpha: 0.45);
    final Color innerHighlight = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.85);

    return Tooltip(
      message: 'Add shortcut',
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.45 : 0.32),
                blurRadius: 26,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              if (isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    colors: <Color>[fillTop, fillBottom],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 1,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.transparent,
                              innerHighlight,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: radius,
                        onTap: onPressed,
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: accent,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on ShortcutTargetType {
  Color accent(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    const Color lightAccent = Color(0xFFD73A23);

    switch (this) {
      case ShortcutTargetType.video:
        return isDark ? const Color(0xFFFF8A65) : lightAccent;
      case ShortcutTargetType.shortVideo:
        return isDark ? const Color(0xFFFFB74D) : lightAccent;
      case ShortcutTargetType.playlist:
        return isDark ? const Color(0xFFBCAAA4) : lightAccent;
      case ShortcutTargetType.channel:
        return isDark ? const Color(0xFF4DB6AC) : lightAccent;
    }
  }
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
