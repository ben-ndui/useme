import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom delegate that provides French MaterialLocalizations as fallback
/// for unsupported locales like Sango (sg).
class SangoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SangoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sg';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate
        .load(const Locale('fr'))
        .then((value) => value);
  }

  @override
  bool shouldReload(
          SangoMaterialLocalizationsDelegate old) =>
      false;
}

/// Custom delegate that provides French CupertinoLocalizations as fallback
/// for unsupported locales like Sango (sg).
class SangoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SangoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate
        .load(const Locale('fr'))
        .then((value) => value);
  }

  @override
  bool shouldReload(
          SangoCupertinoLocalizationsDelegate old) =>
      false;
}
