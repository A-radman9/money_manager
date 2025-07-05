import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial()) {
    _loadSettings();
  }

  static const String _languageKey = 'language_code';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      final locale = Locale(languageCode);
      emit(SettingsLoaded(locale: locale));
    } catch (e) {
      emit(const SettingsLoaded(locale: Locale('en')));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      final locale = Locale(languageCode);
      emit(SettingsLanguageChanged(locale: locale));
    } catch (e) {
      // Handle error if needed
    }
  }

  Locale get currentLocale {
    if (state is SettingsLoaded) {
      return (state as SettingsLoaded).locale;
    } else if (state is SettingsLanguageChanged) {
      return (state as SettingsLanguageChanged).locale;
    }
    return const Locale('en');
  }
}
