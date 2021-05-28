import 'dart:convert';

import 'package:chat_lb/model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  final String _KEY_SAVE_TOKEN = "save.token";
  final String _KEY_SAVE_PUSH_TOKEN = "save.push.token";
  final String _KEY_SAVE_USER = "save.user";

  static final AppPrefs _instance = AppPrefs._internal();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  factory AppPrefs.share() {
    return _instance;
  }

  AppPrefs._internal();

  Future<String> getPushToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_SAVE_PUSH_TOKEN);
  }

  savePushToken(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_SAVE_PUSH_TOKEN, value);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_SAVE_TOKEN);
  }

  saveToken(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_SAVE_TOKEN, value);
  }

  Future<UserModel> getCurrentUser() async {
    final SharedPreferences prefs = await _prefs;
    String userString = prefs.getString(_KEY_SAVE_USER);
    if (userString != null) {
      Map userMap = jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  saveUser(UserModel userModel) async {
    final SharedPreferences prefs = await _prefs;
    String value = jsonEncode(userModel);
    prefs.setString(_KEY_SAVE_USER, value);
  }

  Future<bool> isLogin() async {
    String token = await getToken();
    return token != null && token.isNotEmpty;
  }

  logout() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(_KEY_SAVE_USER);
    prefs.remove(_KEY_SAVE_TOKEN);
  }
}
