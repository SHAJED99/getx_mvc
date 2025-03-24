part of 'http_repository.dart';

/// Class to handle HTTP errors
class _HttpErrorHandler {
  /// Handle HTTP errors
  Future<HTTPErrorEnum> errorHandler({
    bool showError = true,
    required Future<void> Function() function,
  }) async {
    HTTPErrorEnum? error;
    String? message;
    try {
      await function();
      return HTTPErrorEnum.done;
    } on dio.DioException catch (e) {
      error = _getErrorType(e.response?.statusCode);
      message = e.response?.data.toString();
    } on TypeError catch (e) {
      error = HTTPErrorEnum.parseError;
      message = e.toString();
    } catch (e) {
      if (e is dio.Response) {
        error = _getErrorType(e.statusCode);
        message = e.data.toString();
      }
    }

    final HTTPErrorEnum resultError = error ?? HTTPErrorEnum.unknown;

    if (showError) {
      final ColorScheme colorScheme = Get.theme.colorScheme;
      showSnackBar(
        title: 'Error',
        message: resultError.errorMessage,
        titleColor: colorScheme.onError,
        messageColor: colorScheme.onError,
        backgroundColor: colorScheme.error,
        icon: Icon(
          Icons.error,
          color: colorScheme.onError,
        ),
      );
    }

    devPrint(
      '''Error:\t${resultError.errorMessage}(${resultError.errorCode})
Data:\t$message''',
      heading: 'HttpErrorHandler',
      color: DevPrintColorEnum.red,
    );

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
  return null;
}
