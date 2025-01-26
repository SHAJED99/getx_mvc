import 'package:get/get.dart';
import 'package:getx_mvc/src/models/environment_model/environment_model.dart';

import '../../models/app_models/app_information_model.dart';

/// Handles app data. Exe: Theme, Localization
class AppDataController extends GetxController {
  /// AppDataController initialize
  AppDataController({required this.environmentModel});

  /// App environment, Data from .env file
  final EnvironmentModel environmentModel;
}
