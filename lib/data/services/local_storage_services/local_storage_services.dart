import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Initialize SharedPreferences lazily
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static final String kisLogin = 'kIsLogin';
  static final String kAID = 'kAID';
  static final String kAName = 'kAName';
  static final String kAdminData = 'kAdminData';

  // ================================================================
  //   SHARED PREFERENCES (Non-sensitive storage)
  // ================================================================

  //------------------ STRING ------------------
  Future<void> spWriteString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  Future<String?> spReadString(String key) async {
    return _prefs!.getString(key);
  }

  //------------------ INT ------------------
  Future<void> spWriteInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  Future<int?> spReadInt(String key) async {
    return _prefs!.getInt(key);
  }

  //------------------ DOUBLE ------------------
  Future<void> spWriteDouble(String key, double value) async {
    await _prefs!.setDouble(key, value);
  }

  Future<double?> spReadDouble(String key) async {
    return _prefs!.getDouble(key);
  }

  //------------------ BOOL ------------------
  Future<void> spWriteBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  Future<bool?> spReadBool(String key) async {
    return _prefs!.getBool(key);
  }

  //------------------ JSON MAP ------------------
  Future<void> spWriteJson(String key, Map<String, dynamic> value) async {
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> spReadJson(String key) async {
    final raw = _prefs!.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ================================================================
  //   FLUTTER SECURE STORAGE (Sensitive storage)
  // ================================================================

  //------------------ STRING ------------------
  Future<void> secureWriteString(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  Future<String?> secureReadString(String key) async {
    return await _secure.read(key: key);
  }

  //------------------ INT ------------------
  Future<void> secureWriteInt(String key, int value) async {
    await _secure.write(key: key, value: value.toString());
  }

  Future<int?> secureReadInt(String key) async {
    final raw = await _secure.read(key: key);
    return raw != null ? int.tryParse(raw) : null;
  }

  //------------------ DOUBLE ------------------
  Future<void> secureWriteDouble(String key, double value) async {
    await _secure.write(key: key, value: value.toString());
  }

  Future<double?> secureReadDouble(String key) async {
    final raw = await _secure.read(key: key);
    return raw != null ? double.tryParse(raw) : null;
  }

  //------------------ BOOL ------------------
  Future<void> secureWriteBool(String key, bool value) async {
    await _secure.write(key: key, value: value.toString());
  }

  Future<bool?> secureReadBool(String key) async {
    final raw = await _secure.read(key: key);
    if (raw == null) return null;
    return raw.toLowerCase() == "true";
  }

  //------------------ JSON MAP ------------------
  Future<void> secureWriteJson(String key, Map<String, dynamic> value) async {
    await _secure.write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> secureReadJson(String key) async {
    final raw = await _secure.read(key: key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ================================================================
  //   UTILITIES
  // ================================================================
  Future<void> spRemove(String key) async {
    await _prefs!.remove(key);
  }

  Future<void> secureRemove(String key) async {
    await _secure.delete(key: key);
  }

  Future<void> clearAllLocal() async {
    await init();
    await _prefs!.clear();
  }

  Future<void> clearAllSecure() async {
    await _secure.deleteAll();
  }
}
