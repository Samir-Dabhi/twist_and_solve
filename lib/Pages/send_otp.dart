import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:twist_and_solve/Pages/verify_otp_screen.dart';
import 'package:twist_and_solve/constants.dart';

class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  _SendOtpScreenState createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOtp() async {
    String url = '${Constants.baseUrl}/sendotp';
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter an email")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url), // API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}), // Match .NET API structure
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(email: email),
          ),
        );
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
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      floatingLabelStyle: const TextStyle(
                          color: Color(0xFF112D4E)
                      ),
                      labelText: "Enter your email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(8,0,8,8),
                      child: SizedBox(
                                        width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(// Updated theme color
                          backgroundColor: const Color(0xFFA6E3E9),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: sendOtp,
                        child: const Text("Send OTP",style: TextStyle(
                          color: Color(0xFF112D4E)
                        ),),
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
