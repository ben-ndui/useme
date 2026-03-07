import 'package:flutter/widgets.dart';

/// Returns a locale code safe for the `intl` package (DateFormat, etc.).
/// Falls back to French for unsupported locales like Sango (sg).
String intlLocale(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'sg' ? 'fr' : code;
}
