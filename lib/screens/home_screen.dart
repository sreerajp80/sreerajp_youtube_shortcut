import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/services/backup_service.dart';
import 'package:sreerajp_youtube_shortcut/state/privacy_lock_store.dart';
import 'package:sreerajp_youtube_shortcut/services/share_intent_service.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/l10n/model_labels.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/widgets/shortcut_grid.dart';
import 'package:sreerajp_youtube_shortcut/widgets/shortcut_filter_bar.dart';
import 'package:sreerajp_youtube_shortcut/widgets/home_states.dart';
import 'package:sreerajp_youtube_shortcut/widgets/glass_add_fab.dart';
import 'package:sreerajp_youtube_shortcut/widgets/shortcut_qr_dialog.dart';
import 'package:sreerajp_youtube_shortcut/screens/add_shortcut_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/qr_scanner_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/settings_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/shortcut_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Localized strings for this screen.
  AppLocalizations get l10n => AppLocalizations.of(context);

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
            final bool urlMatch = entry.canonicalUrl.toLowerCase().contains(
              query,
            );
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
          tooltip: l10n.homeExitReorderTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: _exitReorderMode,
        ),
        title: Text(l10n.homeReorderTitle),
        actions: <Widget>[
          TextButton(onPressed: _exitReorderMode, child: Text(l10n.commonDone)),
        ],
      );
    } else if (_isSelectionMode) {
      appBar = _buildSelectionAppBar(context, store, visibleEntries);
    } else {
      appBar = _buildDefaultAppBar(context, store);
    }

    final String subtitle;
    if (store.entries.isEmpty) {
      subtitle = l10n.homeSubtitleEmpty;
    } else if (_isReorderMode) {
      subtitle = l10n.homeSubtitleReorder;
    } else if (_isSelectionMode) {
      subtitle = l10n.homeSubtitleSelection;
    } else {
      subtitle = l10n.homeSubtitleNormal;
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
            : GlassAddFab(onPressed: () => _openAddShortcut(context)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
          children: <Widget>[
            if (store.entries.isEmpty) ...<Widget>[
              HomeHero(entryCount: store.entries.length),
              const SizedBox(height: 20),
            ],
            Row(
              children: <Widget>[
                Text(
                  l10n.homeSectionsHeading,
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
                          ? l10n.homeFilteredCount(
                              visibleEntries.length,
                              store.entries.length,
                            )
                          : l10n.homeTotalCount(store.entries.length),
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
              ShortcutFilterBar(
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
              EmptyShortcutState(onAddPressed: () => _openAddShortcut(context))
            else if (showNoMatches)
              NoFilterMatchesState(onClear: _clearAllFilters)
            else
              ShortcutGrid(
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
      title: Text(l10n.appTitle),
      actions: <Widget>[
        IconButton(
          tooltip: l10n.homeScanQrTooltip,
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
                ? l10n.homeSwitchToList
                : l10n.homeSwitchToGrid,
            icon: Icon(
              store.layoutPreference == AppLayoutPreference.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            onPressed: () => _toggleLayout(context, store.layoutPreference),
          ),
          PopupMenuButton<dynamic>(
            tooltip: l10n.homeSortTooltip,
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
                child: Text(l10n.homeFavoritesFirst),
              ),
              const PopupMenuDivider(),
              for (final ShortcutSortPreference preference
                  in ShortcutSortPreference.values)
                CheckedPopupMenuItem<ShortcutSortPreference>(
                  value: preference,
                  checked: store.sortPreference == preference,
                  child: Text(preference.label(l10n)),
                ),
            ],
          ),
          PopupMenuButton<_HomeAction>(
            tooltip: l10n.homeOptionsTooltip,
            onSelected: (_HomeAction action) =>
                _handleHomeAction(context, action),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_HomeAction>>[
                  PopupMenuItem<_HomeAction>(
                    value: _HomeAction.reorder,
                    enabled: sortIsManual,
                    child: Text(
                      sortIsManual
                          ? l10n.homeReorderTitle
                          : l10n.homeReorderDisabled,
                    ),
                  ),
                  PopupMenuItem<_HomeAction>(
                    value: _HomeAction.clearAll,
                    child: Text(l10n.homeClearAllAction),
                  ),
                ],
          ),
        ],
        IconButton(
          tooltip: l10n.homeSettingsTooltip,
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
      await context.read<ShortcutStore>().setFavoritesFirst(
        !currentFavoritesFirst,
      );
    } on ShortcutStorageException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
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
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
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
        tooltip: l10n.homeClearSelectionTooltip,
        icon: const Icon(Icons.close_rounded),
        onPressed: _clearSelection,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.homeSelectionCount(count)),
          const SizedBox(width: 6),
          const Icon(Icons.check_rounded, size: 20),
        ],
      ),
      actions: <Widget>[
        if (single && singleEntry != null) ...<Widget>[
          IconButton(
            tooltip: l10n.homeShowQrTooltip,
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () => ShortcutQrDialog.show(context, singleEntry),
          ),
          IconButton(
            tooltip: l10n.homeDetailsTooltip,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _openDetailsFromSelection(context, singleEntry),
          ),
          IconButton(
            tooltip: l10n.homeEditTooltip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editFromSelection(context, singleEntry),
          ),
          IconButton(
            tooltip: l10n.homeCopyUrlTooltip,
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copyUrlFromSelection(context, singleEntry),
          ),
        ],
        IconButton(
          tooltip: l10n.homeExportSelectedTooltip,
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
          tooltip: l10n.homeDeleteSelectedTooltip,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _deleteSelection(context, store),
        ),
        if (!allVisibleSelected)
          PopupMenuButton<_SelectionAction>(
            tooltip: l10n.homeMoreTooltip,
            onSelected: (_SelectionAction action) {
              if (action == _SelectionAction.selectAll) {
                _selectAll(visibleEntries);
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_SelectionAction>>[
                  PopupMenuItem<_SelectionAction>(
                    value: _SelectionAction.selectAll,
                    child: Text(l10n.homeSelectAll),
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
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
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
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
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
          title: Text(l10n.homeDeleteManyTitle(1)),
          content: Text(l10n.homeDeleteOneBody(entry.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
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
    ).showSnackBar(SnackBar(content: Text(l10n.homeRemovedOne(entry.name))));

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
          title: Text(l10n.homeClearAllTitle),
          content: Text(l10n.homeClearAllBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.homeClearAllConfirm),
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
    ).showSnackBar(SnackBar(content: Text(l10n.homeClearedMessage)));
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
    ).showSnackBar(SnackBar(content: Text(l10n.homeUrlCopied)));
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
        ? l10n.homeDeleteOneBody(picked.first.name)
        : l10n.homeDeleteManyBody(count);

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.homeDeleteManyTitle(count)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
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
        ? l10n.homeRemovedOne(picked.first.name)
        : l10n.homeRemovedMany(count);
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
                l10n.homeExportedMessage(exportedCount, destinationLabel),
              ),
            ),
          );
        case BackupExportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupExportCancelled)));
      }
    } on ShortcutBackupException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    } finally {
      if (mounted) {
        setState(() => _isExportingSelection = false);
      }
    }
  }
}

enum _HomeAction { reorder, clearAll }

enum _SelectionAction { selectAll }
