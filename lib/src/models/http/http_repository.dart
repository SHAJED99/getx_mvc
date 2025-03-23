import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/data_controllers/auth_controller.dart';
import '../../utils/dev_functions/dev_print.dart';
import '../../utils/user_message/snackbar.dart';
import '../environment/environment.dart';
import 'http_error_enum.dart';

part 'http_client.dart';
part 'http_error_handler.dart';

/// Base class for HTTP repositories
///
/// [client] for HTTP requests
///
/// [errorHandler] for handling HTTP errors
abstract class HttpRepository {
  final AuthController authController = AuthController.find;
  final _HttpClient client = _HttpClient();
  final _HttpErrorHandler errorHandler = _HttpErrorHandler();
}
