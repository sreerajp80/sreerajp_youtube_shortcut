sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ShortcutValidationException extends AppException {
  const ShortcutValidationException(super.message);
}

final class ShortcutStorageException extends AppException {
  const ShortcutStorageException(super.message);
}

final class YoutubeLaunchException extends AppException {
  const YoutubeLaunchException(super.message);
}
