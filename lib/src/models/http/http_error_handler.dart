part of 'http_repository.dart';

/// Class to handle HTTP errors
class _HttpErrorHandler {
  /// Handle HTTP errors
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
  return null;
}
