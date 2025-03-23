part of '../../../views/screens/authentication/authentication_wrapper_screen.dart';

class _AuthenticationScreenRepository extends HttpRepository {
  /// [login]
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    UserModel? result;

    // TODO: Simulate a network request
    await errorHandler.errorHandler(
      function: () async {
        final String url = 'auth/login';
        final dio.Response<Map<String, dynamic>> response =
            await httpClient.post(
          url,
          body: <String, String>{
            'userName': email,
            'password': password,
          },
        );

        if (response.statusCode != 200 || response.data == null) {
          throw response;
        }

        result = UserModel.fromMap(response.data!);
      },
    );

    return result;
  }

  /// [signup]
  Future<UserModel?> signup({
    required String email,
    required String password,
  }) async {
    UserModel? result;

    // TODO: Simulate a network request
    await errorHandler.errorHandler(
      function: () async {
        final String url = 'auth/login';
        final dio.Response<Map<String, dynamic>> response =
            await httpClient.post(
          url,
          body: <String, String>{
            'userName': email,
            'password': password,
          },
        );

        if (response.statusCode != 200 || response.data == null) {
          throw response;
        }

        result = UserModel.fromMap(response.data!);
      },
    );

    return result;
  }
}
