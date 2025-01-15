import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    const String url = 'http://localhost:5167/User/auth';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {
              "userId": 0,
              "username": "string",
              "email": email,
              "passwordHash": password,
              "dateJoined": "2024-12-29T09:46:47.648Z",
              "profilePicture": "string",
              "progressLevel": 0
            }
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
          _isLoggedIn = true; // Mark the user as authenticated
          setEmailInPrefs(email);
          setPasswordInPrefs(password);
          setLoginStatusInPrefs(_isLoggedIn);
          return true; // Indicate success
      } else {
        setLoginStatusInPrefs(_isLoggedIn);
        throw Exception('Server error. Please try again later.');
      }
    } catch (e) {
      setLoginStatusInPrefs(_isLoggedIn);
      throw Exception('Error: $e');
    }
  }

  Future<bool> signup(String UserName,String email, String password) async {
    const String url = 'http://localhost:5167/User/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {
              "userId": 0,
              "username": UserName,
              "email": email,
              "passwordHash": password,
              "dateJoined": DateTime.now().toString(),
              "profilePicture": "string",
              "progressLevel": 0
            }
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _isLoggedIn = true; // Mark the user as authenticated
        setEmailInPrefs(email);
        setPasswordInPrefs(password);
        setLoginStatusInPrefs(_isLoggedIn);
        return true; // Indicate success
      } else {
        setLoginStatusInPrefs(_isLoggedIn);
        throw Exception('Server error. Please try again later.');
      }
    } catch (e) {
      setLoginStatusInPrefs(_isLoggedIn);
      throw Exception('Error: $e');
    }
  }

  void logout() {
    _isLoggedIn = false;
  }

  Future<String?> getEmailFromPrefs() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
  Future<String?> getPasswordFromPrefs() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }
  Future<bool?> getLoginStatusFromPrefs() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('LoginStatus');
  }
  void setEmailInPrefs(String email) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }
  void setPasswordInPrefs(String password) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }
  void setLoginStatusInPrefs(bool LoginStatus) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('LoginStatus', LoginStatus);
  }
  //todo make procedure saves user in shared preference
  // void setUserInPrefs(Map) async{
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('email', email);
  // }
}