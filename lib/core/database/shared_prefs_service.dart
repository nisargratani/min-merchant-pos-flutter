import 'package:shared_preferences/shared_preferences.dart';

/// Service wrapper that holds a static reference to the initialized [SharedPreferences].
/// This allows synchronous access through Riverpod providers without requiring overrides.
class SharedPrefsService {
  SharedPrefsService._();

  /// The static initialized instance of [SharedPreferences]
  static late final SharedPreferences instance;

  /// Initializes the [SharedPreferences] instance. Must be called in main().
  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }
}
