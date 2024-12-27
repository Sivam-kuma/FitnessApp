// import 'dart:convert'; // For JSON encoding
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
//
// import 'Login.dart';
// import 'appbar.dart';
//
// class RegistrationPage extends StatefulWidget {
//   @override
//   _RegistrationPageState createState() => _RegistrationPageState();
// }
//
// class _RegistrationPageState extends State<RegistrationPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   // Function to handle registration API call
//   Future<void> _registerUser() async {
//     final String apiUrl = "https://fitness-tag1.onrender.com/api/auth/register";
//
//     final Map<String, dynamic> body = {
//       "username": _emailController.text.trim(),
//       "password": _passwordController.text.trim(),
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         // Save the name in SharedPreferences after successful registration
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         String savedName = _nameController.text.trim();
//
//         await prefs.setString('name', savedName); // Save the entered name
//
//         Get.snackbar('Success', 'Registration successful, $savedName ',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white);
//         Get.to(LoginPage());
//       } else {
//         Get.snackbar('Error', 'Registration failed: ${response.body}',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'An error occurred. Please try again later.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(),
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Blue header section
//                 Container(
//                   color: Colors.lightBlue,
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(
//                     child: Text(
//                       'Registration Page',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Image section
//                 Image.asset(
//                   'assets/Contacting support specialist via online call.png',
//                   height: 150,
//                 ),
//                 SizedBox(height: 20),
//
//                 // Name TextField
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Your Name',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.only(right: 11.0, left: 10.0),
//                       child: Icon(Icons.person, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Email TextField (not used in the API, but kept for UI consistency)
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Your Email Id',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Password TextField
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Password',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//
//                 // Register button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _registerUser, // Call the registration function
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                       backgroundColor: Colors.lightBlue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       'Register',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
///
// import 'dart:convert'; // For JSON encoding
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// import 'Login.dart';
// import 'appbar.dart';
//
// class RegistrationPage extends StatefulWidget {
//   @override
//   _RegistrationPageState createState() => _RegistrationPageState();
// }
//
// class _RegistrationPageState extends State<RegistrationPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   // Function to handle registration API call
//   Future<void> _registerUser() async {
//     final String apiUrl = "https://fitness-tag1.onrender.com/api/auth/register";
//
//     final Map<String, dynamic> body = {
//       "username": _emailController.text.trim(),
//       "password": _passwordController.text.trim(),
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           // You can add other headers if needed
//         },
//         body: jsonEncode(body),
//       );
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Registration successful!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white);
//         Get.to(LoginPage());
//       } else {
//         Get.snackbar('Error', 'Registration failed: ${response.body}',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'An error occurred. Please try again later.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(),
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: SingleChildScrollView(
//             // To prevent overflow in small screens
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Blue header section
//                 Container(
//                   color: Colors.lightBlue,
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(
//                     child: Text(
//                       'Registration Page',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Image section
//                 Image.asset(
//                   'assets/Contacting support specialist via online call.png',
//                   height: 150,
//                 ),
//                 SizedBox(height: 20),
//
//                 // Name TextField
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Your Name',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Email TextField (not used in the API, but kept for UI consistency)
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Your Email Id',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Password TextField
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Password',
//                     filled: true,
//                     fillColor: Colors.lightBlue[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//
//                 // Register button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _registerUser, // Call the registration function
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                       backgroundColor: Colors.lightBlue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       'Register',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controllers for each OTP box
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  String? _generatedCode; // To store the generated code

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  // Function to send the verification email
  Future<void> _sendVerificationEmail(String email) async {
    // Generate the numeric code based on the first 4 characters of the email
    String code = email
        .substring(0, 4)
        .codeUnits
        .map((e) =>
            e.toString().substring(0, 1)) // Convert to single digit strings
        .take(4) // Ensure it only takes 4 digits
        .join();
    setState(() {
      _generatedCode = code; // Save the generated code for later verification
    });

    // Configure the SMTP server (use your email credentials)
    final smtpServer =
        gmail('shivam1jan.pandey@gmail.com', 'jcby xhxn judi jgcd');

    // Create the email
    final message = Message()
      ..from = Address('shivam1jan.pandey@gmail.com', 'KeepFit')
      ..recipients.add(email)
      ..subject = 'Email Verification Code'
      ..text = 'Your verification code is: $code';

    try {
      await send(message, smtpServer);
      Get.snackbar('Success', 'Verification email sent to $email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send email. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Function to handle registration API call
  Future<void> _registerUser() async {
    final String apiUrl =
        "https://fitnessproject-production.up.railway.app/api/auth/register";

    // Combine the OTP values from each box
    String enteredCode = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;

    if (enteredCode != _generatedCode) {
      Get.snackbar('Error', 'Invalid verification code.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final Map<String, dynamic> body = {
      "username": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', _nameController.text.trim());
        Get.snackbar('Success', 'Registration successful.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.to(LoginPage());
      } else {
        Get.snackbar('Error', 'Registration failed: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        title: const Text(
          'Registration Page',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'assets/Contacting support specialist via online call.png',
                  height: 150,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Name',
                    filled: true,
                    fillColor: Colors.lightBlue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Email Id',
                    filled: true,
                    fillColor: Colors.lightBlue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    filled: true,
                    fillColor: Colors.lightBlue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _otpBox(_otpController1, _focusNode1, 0),
                    _otpBox(_otpController2, _focusNode2, 1),
                    _otpBox(_otpController3, _focusNode3, 2),
                    _otpBox(_otpController4, _focusNode4, 3),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      _sendVerificationEmail(_emailController.text.trim()),
                  child: Text('Send Verification Code'),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerUser, // Call the registration function
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
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

  // OTP box widget for individual boxes
  Widget _otpBox(
      TextEditingController controller, FocusNode focusNode, int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < 3) {
              FocusScope.of(context).requestFocus([
                _focusNode1,
                _focusNode2,
                _focusNode3,
                _focusNode4
              ][index + 1]);
            }
          }
        },
      ),
    );
  }
}
