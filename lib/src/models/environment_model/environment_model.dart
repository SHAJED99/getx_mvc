import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../utils/dev_functions/dev_print.dart';

/// ENV reading model
///
/// .env file data will be configure according to this class
class EnvironmentModel {
  /// .env Data is needed
  static Future<void> get init async {
    await dotenv.load();
    _fromMap(dotenv.env);
    devPrint(__message, color: DevPrintColorEnum.black);
  }

  /// API base URL
  static late final String apiBaseUrl;

  /// API Version
  static late final String apiVersion;

  static void _fromMap(Map<String, dynamic> map) {
    try {
      apiBaseUrl = map['API_BASE_URL'];
      apiVersion = map['API_VERSION'];
    } catch (e) {
      devPrint('EnvironmentModel: $e', color: DevPrintColorEnum.red);
    }
  }

  static String get __message => '''
EnvironmentModel(
  apiBaseUrl: $apiBaseUrl,
  apiVersion: $apiVersion
)
''';
}
