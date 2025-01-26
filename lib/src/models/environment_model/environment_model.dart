import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../utils/dev_functions/dev_print.dart';

/// ENV reading model
///
/// .env file data will be configure according to this class
class EnvironmentModel {
  /// .env Data is needed
  Future<EnvironmentModel> get init async {
    await dotenv.load();
    _fromMap(dotenv.env);
    return this;
  }

  /// API base URL
  late final String apiBaseUrl;

  /// API Version
  late final String apiVersion;

  void _fromMap(Map<String, dynamic> map) {
    try {
      apiBaseUrl = map['API_BASE_URL'];
      apiVersion = map['API_VERSION'];
    } catch (e) {
      devPrint('EnvironmentModel: $e', color: DevPrintColorEnum.red);
    }
  }

  @override
  String toString() => '''
EnvironmentModel(
  apiBaseUrl: $apiBaseUrl,
  apiVersion: $apiVersion
)
''';
}
