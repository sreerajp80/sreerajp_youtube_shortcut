import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/model_labels.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

/// Search box plus the target-type and tag filter chips.
class ShortcutFilterBar extends StatelessWidget {
  const ShortcutFilterBar({
    super.key,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.homeSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.homeClearSearchTooltip,
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
                label: Text(type.label(l10n)),
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
