// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:flutter_fast/src/model/repository/fast_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fast/src/model/preferences/fast_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FastPreferenceManager {
  late String _fileName;
  late bool _logEverything;
  final _sharedPref = SharedPreferencesAsync();
  final Map<String, FastPreference<dynamic>> _preferences = {};
  final Map<String, Timer> _timers = {};

  void setup({required String fileName, required bool logEverything}) {
    _fileName = fileName;
    _logEverything = logEverything;
  }

  FastPreference<T> register<T>(FastPreference<T> p, {int saveDelayMillis = 0}) {
    String key = p.key;
    _log("Registering preference $key");
    if (_preferences.containsKey(key)) {
      throw ArgumentError("'$_fileName' already contains prefence '$key'");
    }
    _preferences[key] = p;
    p.addListener(() async {
      if (saveDelayMillis == 0) {
        _save(p.value, key);
        p.streamController.sink.add(p.value);
      } else {
        Timer? timer = _timers[key];
        if (timer == null) {
          timer = Timer(Duration(milliseconds: saveDelayMillis), () {
            _save(p.value, key);
            p.streamController.sink.add(p.value);
          });
          _timers[key] = timer;
        }
      }
    });
    return p;
  }

  Future<T> get<T>(T defValue, String key) async {
    T value;
    switch (defValue) {
      case const (String):
        value = await _sharedPref.getString(key) as T? ?? defValue;
        break;
      default:
        String? v = await _sharedPref.getString(key);
        if (v == null) {
          value = defValue;
        } else {
          FastPreference<T>? p = _preferences[key] as FastPreference<T>?;
          if (p == null) {
            _log("Prefence with key $key is null.");
            return defValue;
          }
          T? decoded = p.decode?.call(v);
          if (decoded == null) {
            _log("Unable to decode prefence with key $key. Returning default value.");
            value = defValue;
          } else {
            value = decoded;
          }
        }
    }
    _log("Getting preference $key: $value (${defValue.runtimeType})", logAlways: true);
    return value;
  }

  _save<T>(T value, String key) {
    _log("Saving preference $key with $value", logAlways: true);
    switch (value) {
      case const (String):
        _sharedPref.setString(key, value as String);
        break;
      default:
        FastPreference<T>? p = _preferences[key] as FastPreference<T>?;
        if (p == null) {
          _log("Prefence with key $key is null.");
          return;
        }
        if (p.encode != null) {
          _sharedPref.setString(key, p.encode?.call(value) ?? "");
          return;
        }
        _log("Prefence with key $key is a json.");
        _sharedPref.setString(key, jsonEncode(value));
        break;
    }
  }

  void _log(String msg, {bool logAlways = false}) {
    if (kDebugMode && (_logEverything || logAlways)) {
      debugPrint("Preferences ($_fileName): $msg");
    }
  }
}

class FastPreferencesRepository extends FastRepository {}
