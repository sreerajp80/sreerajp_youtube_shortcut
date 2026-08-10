class AboutInfo {
  const AboutInfo({
    required this.author,
    required this.version,
    required this.buildNumber,
    required this.buildDate,
    required this.aiUsed,
  });

  final String author;
  final String version;
  final String buildNumber;
  final String buildDate;
  final String aiUsed;
}

enum AppLayoutPreference {
  grid('Grid'),
  list('List');

  const AppLayoutPreference(this.label);

  final String label;

  String get storageValue => name;

  static AppLayoutPreference fromStorageValue(String? value) {
    for (final AppLayoutPreference preference in AppLayoutPreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return AppLayoutPreference.grid;
  }
}

enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Classic Dark'),
  amoled('AMOLED Pure Black'),
  warmSepia('Warm Sepia'),
  forestDark('Forest Dark'),
  cyberpunkNeon('Cyberpunk Neon');

  const AppThemePreference(this.label);

  final String label;

  String get storageValue => name;

  static AppThemePreference fromStorageValue(String? value) {
    for (final AppThemePreference preference in AppThemePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return AppThemePreference.system;
  }
}

enum ShortcutSortPreference {
  manual('Manual order'),
  alphabetical('Alphabetical (A–Z)'),
  newest('Newest first'),
  recent('Recently launched'),
  mostUsed('Most launched');

  const ShortcutSortPreference(this.label);

  final String label;

  String get storageValue => name;

  static ShortcutSortPreference fromStorageValue(String? value) {
    for (final ShortcutSortPreference preference
        in ShortcutSortPreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return ShortcutSortPreference.manual;
  }
}

enum ShortcutTargetType {
  video('Video'),
  shortVideo('Shorts'),
  playlist('Playlist'),
  channel('Channel');

  const ShortcutTargetType(this.label);

  final String label;
}

class ShortcutEntry {
  const ShortcutEntry({
    required this.id,
    required this.name,
    required this.sourceUrl,
    required this.canonicalUrl,
    required this.targetType,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.lastLaunchedAtIso,
    this.launchCount = 0,
    this.isFavorite = false,
    this.isPrivate = false,
    this.tags = const <String>[],
    this.customColorHex,
    this.customIconName,
  });

  final String id;
  final String name;
  final String sourceUrl;
  final String canonicalUrl;
  final ShortcutTargetType targetType;
  final String createdAtIso;
  final String updatedAtIso;
  final String? lastLaunchedAtIso;
  final int launchCount;
  final bool isFavorite;
  final bool isPrivate;
  final List<String> tags;
  final String? customColorHex;
  final String? customIconName;

  DateTime get createdAt => DateTime.parse(createdAtIso);
  DateTime get updatedAt => DateTime.parse(updatedAtIso);
  DateTime? get lastLaunchedAt =>
      lastLaunchedAtIso == null ? null : DateTime.parse(lastLaunchedAtIso!);

  ShortcutEntry copyWith({
    String? id,
    String? name,
    String? sourceUrl,
    String? canonicalUrl,
    ShortcutTargetType? targetType,
    String? createdAtIso,
    String? updatedAtIso,
    String? lastLaunchedAtIso,
    int? launchCount,
    bool? isFavorite,
    bool? isPrivate,
    List<String>? tags,
    String? customColorHex,
    bool clearCustomColorHex = false,
    String? customIconName,
    bool clearCustomIconName = false,
  }) {
    return ShortcutEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      targetType: targetType ?? this.targetType,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      lastLaunchedAtIso: lastLaunchedAtIso ?? this.lastLaunchedAtIso,
      launchCount: launchCount ?? this.launchCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
      customColorHex: clearCustomColorHex
          ? null
          : (customColorHex ?? this.customColorHex),
      customIconName: clearCustomIconName
          ? null
          : (customIconName ?? this.customIconName),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sourceUrl': sourceUrl,
      'canonicalUrl': canonicalUrl,
      'targetType': targetType.name,
      'createdAtIso': createdAtIso,
      'updatedAtIso': updatedAtIso,
      if (lastLaunchedAtIso != null) 'lastLaunchedAtIso': lastLaunchedAtIso,
      if (launchCount != 0) 'launchCount': launchCount,
      if (isFavorite) 'isFavorite': isFavorite,
      if (isPrivate) 'isPrivate': isPrivate,
      if (tags.isNotEmpty) 'tags': tags,
      if (customColorHex != null) 'customColorHex': customColorHex,
      if (customIconName != null) 'customIconName': customIconName,
    };
  }

  factory ShortcutEntry.fromJson(Map<String, dynamic> json) {
    final dynamic launchCountRaw = json['launchCount'];
    final int parsedLaunchCount = launchCountRaw is int
        ? launchCountRaw
        : (launchCountRaw is num ? launchCountRaw.toInt() : 0);

    final bool parsedIsFavorite = json['isFavorite'] as bool? ?? false;
    final bool parsedIsPrivate = json['isPrivate'] as bool? ?? false;
    final List<dynamic>? rawTags = json['tags'] as List<dynamic>?;
    final List<String> parsedTags = rawTags != null
        ? rawTags.map((dynamic e) => e.toString()).toList(growable: false)
        : const <String>[];

    return ShortcutEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceUrl: json['sourceUrl'] as String,
      canonicalUrl: json['canonicalUrl'] as String,
      targetType: ShortcutTargetType.values.firstWhere(
        (ShortcutTargetType value) => value.name == json['targetType'],
        orElse: () => ShortcutTargetType.video,
      ),
      createdAtIso: json['createdAtIso'] as String,
      updatedAtIso: json['updatedAtIso'] as String,
      lastLaunchedAtIso: json['lastLaunchedAtIso'] as String?,
      launchCount: parsedLaunchCount < 0 ? 0 : parsedLaunchCount,
      isFavorite: parsedIsFavorite,
      isPrivate: parsedIsPrivate,
      tags: parsedTags,
      customColorHex: json['customColorHex'] as String?,
      customIconName: json['customIconName'] as String?,
    );
  }
}
