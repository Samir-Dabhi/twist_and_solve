import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Pages/reset_password_screen.dart';
import 'dart:convert';

import 'package:twist_and_solve/constants.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  VerifyOtpScreen({required this.email});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOtp() async {
    String url = '${Constants.baseUrl}/verifyotp';
    String otp = otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url), // API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "otp": otp}), // Match API structure
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("resetToken", responseData["token"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email)),
        );
        // Navigate to reset password or home page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("OTP sent to ${widget.email}",
                      style: const TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      floatingLabelStyle: TextStyle(color: Color(0xFF112D4E)),
                      labelText: "Enter OTP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA6E3E9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: verifyOtp,
                      child: const Text(
                        "Verify OTP",
                        style: TextStyle(color: Color(0xFF112D4E)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
