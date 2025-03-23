import 'dart:convert';

/// User Information for authentication
class UserModel {
  /// Convert from Json
  factory UserModel.fromJson(String source) => UserModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Convert from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      token: map['token'] as String,
    );
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
      'token': token,
    };
  }

  /// Convert to Json
  String toJson() => json.encode(toMap());

  @override
  String toString() => '''
UserModel(
  token: $token
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
