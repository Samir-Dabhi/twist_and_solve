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
          "email": email,
          "passwordHash": password,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['user']);
        _isLoggedIn = true;
        print(responseData["token"]);
        await storeToken(responseData["token"]["accessToken"]);
        await storeRefreshToken(responseData["token"]["refreshToken"]);
        await _storeUserInfo(responseData['user']);
        return true;
      } else {
        throw Exception('Invalid credentials or server error.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> storeRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return await refreshToken() ?? "";
    }

    return token;
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final String url = '${Constants.baseUrl}/User/refresh';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String newAccessToken = responseData["accessToken"];
        await storeToken(newAccessToken);
        return newAccessToken;
      } else {
        await logout(); // If refresh token fails, force logout
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return null;
    }
  }

  Future<bool> signup(String username, String email, String password, String token) async {
    final String url = '${Constants.baseUrl}/User/';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "UserId": "0",
          "Username": username,
          "Email": email,
          "PasswordHash": password,
          "DateJoined": DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData['token']);
        _isLoggedIn = true;
        await storeToken(responseData["token"]);
        await _storeUserInfo(responseData['user']);
        return true;
      } else {
        print('Signup failed. Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
