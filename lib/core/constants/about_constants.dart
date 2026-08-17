/// Build-time default values for About metadata.
///
/// These are `String.fromEnvironment` fallbacks, so they must stay compile-time
/// constants and cannot come from `AppLocalizations`. All *user-visible* About
/// text lives in `lib/l10n/app_en.arb`.
class AboutConstants {
  const AboutConstants._();

  static const String defaultAuthor = 'SreerajP';
  static const String defaultAiUsed = 'OpenAI GPT-5';
}
