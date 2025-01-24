import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/constants.dart';

class AuthService {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    String url = '${Constants.baseUrl}/User/auth';

    try {

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": 0,
          "username": "string",
          "email": email,
          "passwordHash": password,
          "dateJoined": "2025-01-17T16:56:33.385Z",
          "profilePicture": "string",
          "progressLevel": 0
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _isLoggedIn = true;
        await _storeUserInfo(responseData); // Save user info
        return true;
      } else {
        throw Exception('Invalid credentials or server error.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    const String url = '${Constants.baseUrl}/User/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "email": email,
          "passwordHash": password,
          "dateJoined": DateTime.now().toIso8601String(),
          "profilePicture": "string",
          "progressLevel": 0
        }),
      );
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _isLoggedIn = true;
        await _storeUserInfo(responseData); // Save user info
        return true;
      } else {
        throw Exception('Signup failed. Please try again.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored user data
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('userInfo');
    if (userInfoJson != null) {
      return jsonDecode(userInfoJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> _storeUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(userInfo));
    await prefs.setBool('isLoggedIn', _isLoggedIn);
  }

  Future<bool> getLoginStatusFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userInfoJson = prefs.getString('userInfo');
    dynamic userInfo = jsonDecode(userInfoJson!);
    return userInfo['userId'];
  }

}
