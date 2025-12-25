import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_event.dart';
import 'locale_state.dart';

/// BLoC for managing app locale.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'app_locale';

  LocaleBloc() : super(const LocaleState()) {
    on<LoadLocaleEvent>(_onLoadLocale);
    on<ChangeLocaleEvent>(_onChangeLocale);
  }

  Future<void> _onLoadLocale(
    LoadLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null && localeCode.isNotEmpty) {
      emit(LocaleState(locale: Locale(localeCode)));
    } else {
      emit(const LocaleState(locale: null)); // System default
    }
  }

  Future<void> _onChangeLocale(
    ChangeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (event.locale != null) {
      await prefs.setString(_localeKey, event.locale!.languageCode);
      emit(LocaleState(locale: event.locale));
    } else {
      await prefs.remove(_localeKey);
      emit(const LocaleState(locale: null)); // System default
    }
  }
}
