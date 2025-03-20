import 'package:dio/dio.dart';
import 'package:getx_mvc/src/models/http/http_error_enum.dart';
import 'package:getx_mvc/src/utils/dev_functions/dev_print.dart';
import 'package:getx_mvc/src/utils/user_message/snackbar.dart';

class HttpErrorHandler {
  Future<HTTPErrorEnum> errorHandler({
    bool showError = true,
    required Future<void> Function() function,
  }) async {
    HTTPErrorEnum? error;
    try {
      await function();
      return HTTPErrorEnum.done;
    } on DioException catch (e) {
      error = _getErrorType(e.response?.statusCode);
    } catch (e) {
      if (e is Response) {
        error = _getErrorType(e.statusCode);
      }
    }

    final HTTPErrorEnum resultError = error ?? HTTPErrorEnum.unknown;

    if (showError) {
      showSnackBar(title: 'Error', message: resultError.errorMessage);
    }

    return resultError;
  }
}

HTTPErrorEnum? _getErrorType(int? statusCode) {
  if (statusCode == null) return null;
  for (final HTTPErrorEnum error in HTTPErrorEnum.values) {
    if (error.errorCode == statusCode) {
      return error;
    }
  }
}
