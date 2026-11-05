import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple app-wide locale value (fr / en), persisted with shared_preferences.
///
/// Changes apply immediately to any widget listening to [AppLocale.notifier]
/// (e.g. `ValueListenableBuilder`). To localize the whole app, bind
/// `MaterialApp.locale` to [AppLocale.notifier].
class AppLocale {
  AppLocale._();

  static const String _key = 'app_locale';
  static const Locale fr = Locale('fr');
  static const Locale en = Locale('en');

  static final ValueNotifier<Locale> notifier = ValueNotifier<Locale>(fr);
  static bool _loaded = false;

  static bool get isEnglish => notifier.value.languageCode == 'en';

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'en') notifier.value = en;
  }

  static Future<void> set(Locale locale) async {
    notifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  /// Picks the French or English string based on the current locale.
  static String t(String fr, String en) => isEnglish ? en : fr;
}

/// Simple data-saver preferences (Wi-Fi only uploads, no autoplay).
class DataSaverPrefs {
  DataSaverPrefs._();

  static const _kSaver = 'data_saver';
  static const _kAutoplay = 'autoplay_mode'; // 0 wifi, 1 always, 2 never
  static const _kQuality = 'video_quality'; // 0 auto, 1 360p, 2 720p
  static const _kWifiUploads = 'wifi_only_uploads';

  static Future<Map<String, Object>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _kSaver: prefs.getBool(_kSaver) ?? true,
      _kAutoplay: prefs.getInt(_kAutoplay) ?? 0,
      _kQuality: prefs.getInt(_kQuality) ?? 0,
      _kWifiUploads: prefs.getBool(_kWifiUploads) ?? true,
    };
  }

  static Future<void> save({
    required bool saver,
    required int autoplay,
    required int quality,
    required bool wifiUploads,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSaver, saver);
    await prefs.setInt(_kAutoplay, autoplay);
    await prefs.setInt(_kQuality, quality);
    await prefs.setBool(_kWifiUploads, wifiUploads);
  }

  static const keySaver = _kSaver;
  static const keyAutoplay = _kAutoplay;
  static const keyQuality = _kQuality;
  static const keyWifiUploads = _kWifiUploads;
}
