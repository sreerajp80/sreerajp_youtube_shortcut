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

enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

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
  });

  final String id;
  final String name;
  final String sourceUrl;
  final String canonicalUrl;
  final ShortcutTargetType targetType;
  final String createdAtIso;
  final String updatedAtIso;

  DateTime get updatedAt => DateTime.parse(updatedAtIso);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sourceUrl': sourceUrl,
      'canonicalUrl': canonicalUrl,
      'targetType': targetType.name,
      'createdAtIso': createdAtIso,
      'updatedAtIso': updatedAtIso,
    };
  }

  factory ShortcutEntry.fromJson(Map<String, dynamic> json) {
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
    );
  }
}

class ShortcutValidationException implements Exception {
  const ShortcutValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ShortcutStorageException implements Exception {
  const ShortcutStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class YoutubeLaunchException implements Exception {
  const YoutubeLaunchException(this.message);

  final String message;

  @override
  String toString() => message;
}
