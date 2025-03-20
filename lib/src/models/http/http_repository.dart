import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:getx_mvc/src/controllers/data_controllers/auth_controller.dart';

import '../../utils/dev_functions/dev_print.dart';
import '../../utils/user_message/snackbar.dart';
import '../environment/environment.dart';

part 'http_client.dart';

abstract class HttpRepository {
  final _HttpClient _client = _HttpClient();
  // final Error
}
