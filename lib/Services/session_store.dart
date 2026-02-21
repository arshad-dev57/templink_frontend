import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kToken = "token";
  static const _kUserId = "userId";
  static const _kEmail = "email";

  static Future<void> saveLogin({
    required String token,
    required String userId,
    required String email,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kUserId, userId);
    await sp.setString(_kEmail, email);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kUserId);
    await sp.remove(_kEmail);
  }
}
