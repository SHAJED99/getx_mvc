import 'package:get/get.dart';
import 'package:getx_mvc/src/models/environment_model/environment_model.dart';

/// Handles app data
class AppDataController extends GetxController {
  /// AppDataController initialize
  AppDataController({required this.environmentModel});

  /// App environment, Data from .env file
  final EnvironmentModel environmentModel;
}
