import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service wrapper that holds a static reference to the initialized [FlutterSecureStorage].
class SecureStorageService {
  SecureStorageService._();

  static late final FlutterSecureStorage instance;

  static void init() {
    instance = const FlutterSecureStorage();
  }
}
