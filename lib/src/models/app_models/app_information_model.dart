import 'dart:convert';

import 'package:flutter/material.dart';

import '../localization/app_translations.dart';

/// Model to store App Information. Exe: languageCode, theme
class AppInformationModel {
  /// Creates an [AppInformationModel] from a JSON string.
  factory AppInformationModel.fromJson(String source) =>
      AppInformationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Creates an [AppInformationModel] from a map representation.
  factory AppInformationModel.fromMap(Map<String, dynamic> map) {
    Locale locale =
        AppTranslations.getLocaleFromLanguageCode(map['local'].toString());

    bool? isDarkMode = bool.tryParse(map['isDarkMode'.toString()]);

    return AppInformationModel(
      local: locale,
      isDarkMode: isDarkMode,
    );
  }

  /// Constructor for initializing the AppInformationModel.
  ///
  /// [local] is required and represents the app's language Locale.
  /// [isDarkMode] is optional and represents whether dark mode is enabled.
  AppInformationModel({
    Locale? local,
    this.isDarkMode,
  }) : local = local ?? AppTranslations.supportedLocales.first;

  /// App languageCode
  final Locale local;

  /// App theme. If null it will be according to system
  final bool? isDarkMode;

  /// Creates a copy of the current [AppInformationModel] with updated values.
  AppInformationModel copyWith({
    Locale? local,
    required bool? isDarkMode,
  }) {
    return AppInformationModel(
      local: local ?? this.local,
      isDarkMode: isDarkMode,
    );
  }

  /// Converts the [AppInformationModel] into a map representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'local': local.languageCode,
      'isDarkMode': isDarkMode,
    };
  }

  /// Converts the [AppInformationModel] to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  String toString() => '''AppInformationModel(
  local: $local,
  isDarkMode: $isDarkMode
)
''';

  @override
  bool operator ==(covariant AppInformationModel other) {
    if (identical(this, other)) return true;

    return other.local == local && other.isDarkMode == isDarkMode;
  }

  @override
  int get hashCode => local.hashCode ^ isDarkMode.hashCode;
}
