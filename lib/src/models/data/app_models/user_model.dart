import 'dart:convert';

import '../../../utils/functions/string_conversion.dart';

/// User Information for authentication
class UserModel {
  /// Convert from Json
  factory UserModel.fromJson(String source) => UserModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Convert from Map
  ///
  /// Throws a [FormatException] when the token is absent, so that a malformed
  /// API response or a session stored by an older build is rejected instead of
  /// silently producing the literal string `'null'` as a token.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final Object? token = map['accessToken'];

    if (token is! String || token.isEmpty) {
      throw const FormatException('UserModel: accessToken is missing.');
    }

    return UserModel(token: token);
  }

  /// UserModel Constructor
  const UserModel({
    required this.token,
  });

  /// User Token
  final String token;

  /// CopyWith method
  UserModel copyWith({
    String? token,
  }) {
    return UserModel(
      token: token ?? this.token,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': token,
    };
  }

  /// Convert to Json
  String toJson() => json.encode(toMap());

  @override
  String toString() => '''
UserModel(
  token: ${token.customCutString(replaceString: '...')},
)
''';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.token == token;
  }

  @override
  int get hashCode => token.hashCode;
}
