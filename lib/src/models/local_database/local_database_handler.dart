import 'package:get_storage/get_storage.dart';

/// This class is used to handle the local database.
/// This can be used for saving simple local values in memory.
class LocalDatabaseHandler {
  static bool _isInit = false;
  static final GetStorage _storage = GetStorage();

  static Future<void> get ____init async {
    if (_isInit) return;
    await GetStorage.init();
    _isInit = true;
  }

  /// Save Data
  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    await ____init;
    await _storage.write(key, value);
  }

  /// Read Data
  static Future<T?> readData<T>({
    required String key,
    T? defaultValue,
  }) async {
    await ____init;
    return _storage.read<T>(key) ?? defaultValue;
  }
}
