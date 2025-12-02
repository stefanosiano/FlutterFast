/// Generate the [Preference] code to save it in [fileName] and a [PreferencesRepository] with a load() method.
/// Multiple classes should be in the same file, in order to generate the correct [PreferencesRepository].
/// E.g. to generate a preference:
/// ```dart
/// @Pref('pref_file.dat')
/// class AppPreferences extends FastPreferenceManager {
///   final myPref = Preference<String>('defaultValue', 'myPrefKey');
/// }
/// ```
class Pref {
  final String fileName;
  final bool logEverything;

  /// Generate the [Preference] code to save it in [fileName] and a [PreferencesRepository] with a load() method.
  /// If [logEverything] is true, debug log is enabled for this class preferences.
  /// Multiple classes should be in the same file, in order to generate the correct [PreferencesRepository].
  /// E.g. to generate a preference:
  /// ```dart
  /// @Pref(fileName: 'pref_file.dat', logAlways: true)
  /// class AppPreferences extends FastPreferenceManager {
  ///   final myPref = Preference<String>('defaultValue', 'myPrefKey');
  /// }
  /// ```
  const Pref({required this.fileName, this.logEverything = false});
}
