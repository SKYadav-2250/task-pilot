import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mang/core/constants/api_constants.dart';

class StorageService {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  StorageService({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  // Token Management (Secure Storage)
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: ApiConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: ApiConstants.tokenKey);
  }

  // User Info Management
  Future<void> saveUserName(String name) async {
    await sharedPreferences.setString(ApiConstants.userNameKey, name);
  }

  String? getUserName() {
    return sharedPreferences.getString(ApiConstants.userNameKey);
  }

  Future<void> saveUserEmail(String email) async {
    await sharedPreferences.setString(ApiConstants.userEmailKey, email);
  }

  String? getUserEmail() {
    return sharedPreferences.getString(ApiConstants.userEmailKey);
  }

  Future<void> clearUserData() async {
    await secureStorage.delete(key: ApiConstants.tokenKey);
    await sharedPreferences.remove(ApiConstants.userNameKey);
    await sharedPreferences.remove(ApiConstants.userEmailKey);
  }

  // Theme Management (Shared Preferences)
  Future<void> saveThemeMode(bool isDark) async {
    await sharedPreferences.setBool(ApiConstants.themeKey, isDark);
  }

  bool getThemeMode() {
    return sharedPreferences.getBool(ApiConstants.themeKey) ?? false;
  }
}
