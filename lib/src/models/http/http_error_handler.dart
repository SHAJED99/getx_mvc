import 'package:dio/dio.dart';
import 'package:getx_mvc/src/models/http/http_error_enum.dart';

// class HttpErrorHandler {
//   Future<HTTPErrorEnum> errorHandler({
//     bool showError = true,
//     required Future<void> Function() function,
//   }) async {
//     try {
//       await function();
//       return HTTPErrorEnum.done;
//     } on DioException catch (e) {
//     } catch (e) {}
//   }
// }
