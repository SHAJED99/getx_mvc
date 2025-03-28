part of 'http_repository.dart';

const Duration _apiCallTimeOut = Duration(seconds: 30);
const DevPrintColorEnum _color = DevPrintColorEnum.magenta;
const String _tab = '\t';

/// Http Client for calling API
class _HttpClient {
  /// Constructor
  _HttpClient() {
    // Initialize default headers
    _dio.options.headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': '/',
    };

    // Set default timeout
    _dio.options.connectTimeout = _apiCallTimeOut;
    _dio.options.receiveTimeout = _apiCallTimeOut;

    // Add interceptor to catch cookies
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onResponse: (
          dio.Response<dynamic> response,
          dio.ResponseInterceptorHandler handler,
        ) {
          if (response.headers.map['set-cookie'] != null &&
              response.headers.map['set-cookie']!.isNotEmpty) {
            _cookie =
                response.headers.map['set-cookie']![0].split(';')[0].trim();
          }
          return handler.next(response);
        },
      ),
    );
  }
  final AuthController _controller = AuthController.find;
  final dio.Dio _dio = dio.Dio();

  String _cookie = '';

  String get _getToken => '''Bearer ${_controller.user.value?.token ?? ""}''';
  String get _baseLink => Environment.apiBaseUrl;

  /// Get request
  Future<dio.Response<Map<String, dynamic>>> get(
    String url, {
    String? token,
    Map<String, String>? headerParameter,
    Map<String, String>? additionalHeaderParameter,
    bool addCookie = false,
    String? customBaseLink,
  }) async {
    if (kDebugMode) showToast(title: null, message: url);

    final dio.Options options = dio.Options(headers: <String, String>{});

    if (headerParameter != null) {
      options.headers?.addAll(headerParameter);
    }

    if (additionalHeaderParameter != null) {
      options.headers?.addAll(additionalHeaderParameter);
    }

    if ((token) != null || _getToken.isNotEmpty) {
      options.headers?[HttpHeaders.authorizationHeader] = token ?? _getToken;
    }

    if (addCookie && _cookie.isNotEmpty) {
      options.headers?['Cookie'] = _cookie;
    }

    String sendLink = (customBaseLink ?? _baseLink) + url;
    devPrint(
      '''Url:$_tab$sendLink''',
      heading: 'HttpCall: Get - Requesting',
      color: _color,
    );

    final dio.Response<Map<String, dynamic>> response = await _dio.get(
      sendLink,
      options: options,
    );
    devPrint(
      '''Url: $sendLink (${response.statusCode})
Header:$_tab${response.headers}
Data:$_tab${response.data}''',
      heading: 'HttpCall: Get - Response',
      color: _color,
    );
    return response;
  }

  /// Post request
  Future<dio.Response<Map<String, dynamic>>> post(
    String url, {
    bool isAuthServer = false,
    String? token,
    Map<String, String>? headerParameter,
    Map<String, String>? additionalHeaderParameter,
    bool addCookie = false,
    Object? body,
    String? customBaseLink,
    bool doEncode = true,
  }) async {
    // if (kDebugMode) showToast(title: null, message: url);

    final dio.Options options = dio.Options(headers: <String, String>{});

    if (headerParameter != null) {
      options.headers?.addAll(headerParameter);
    }

    if (additionalHeaderParameter != null) {
      options.headers?.addAll(additionalHeaderParameter);
    }

    if ((token) != null || _getToken.isNotEmpty) {
      options.headers?[HttpHeaders.authorizationHeader] = token ?? _getToken;
    }

    if (addCookie && _cookie.isNotEmpty) {
      options.headers?['Cookie'] = _cookie;
    }

    String? processedBody;
    if (body != null) {
      if (doEncode && body is Map<String, dynamic>) {
        processedBody = jsonEncode(body);
      } else {
        processedBody = body.toString();
      }
    }

    String sendLink = (customBaseLink ?? _baseLink) + url;
    devPrint(
      '''Url:$_tab$sendLink
Body:$_tab${processedBody.toString()}''',
      heading: 'HttpCall: POST - Requesting',
      color: _color,
    );

    final dio.Response<Map<String, dynamic>> response = await _dio.post(
      sendLink,
      data: processedBody,
      options: options,
    );
    devPrint(
      '''Url: $sendLink (${response.statusCode})
Header:$_tab${response.headers}
Body: $_tab${processedBody.toString()}
Data:$_tab${response.data}''',
      heading: 'HttpCall: POST - Response',
      color: _color,
    );
    return response;
  }
}
