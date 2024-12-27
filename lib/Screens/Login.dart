// import 'dart:convert';
//
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:fitness/Screens/tellme.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Screens/Registration.dart';
// import 'entry.dart';
//
// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String? errorMessage;
//   bool _isLoading = false;
//
//   Future<void> _handleLogin() async {
//     final username = _usernameController.text;
//     final password = _passwordController.text;
//     setState(() {
//       _isLoading = true; // Set loading to true when API call starts
//     });
//
//     if (username.isEmpty || password.isEmpty) {
//       Get.snackbar("Error", "Username and Password cannot be empty.");
//       return;
//     }
//
//     final response = await http.post(
//       Uri.parse('https://fitness-tag1.onrender.com/api/auth/authenticate'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8'
//       },
//       body: jsonEncode(
//           <String, String>{'username': username, 'password': password}),
//     );
//
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       final jwtToken = responseData['token'];
//       final username = responseData['username'];
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
//       await prefs.setString('username', username);
//       await prefs.setString('jwtToken', jwtToken);
//
//       _checkProfileCompletion();
//     } else {
//       Get.snackbar("Login Failed", "Invalid username or password.");
//       setState(() {
//         _isLoading = false; // Set loading to false when API call completes
//       });
//     }
//   }
//
//   Future<void> _checkProfileCompletion() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('jwtToken');
//
//     if (token == null) {
//       setState(() {
//         errorMessage = 'Authentication token not found. Please log in.';
//       });
//       return;
//     }
//
//     final jwt = JWT.decode(token);
//     final subject = jwt.payload['sub'];
//     final response = await http.get(
//       Uri.parse(
//           'https://fitness-tag1.onrender.com/api/userdetails/getAll/$subject'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json'
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final profileData = jsonDecode(response.body);
//
//       if (profileData != null && profileData['age'] != null) {
//         setState(() {
//           _isLoading = false; // Set loading to false when API call completes
//         });
//         Get.off(() => HomeScreen());
//       } else {
//         setState(() {
//           _isLoading = false; // Set loading to false when API call completes
//         });
//         Get.off(() => GettingFamiliarScreen());
//       }
//     } else {
//       Get.snackbar("Error", "Failed to fetch profile data.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             children: <Widget>[
//               SizedBox(height: screenSize.height * 0.1),
//               CircleAvatar(
//                 radius: screenSize.width * 0.2,
//                 backgroundColor: Colors.grey[200],
//                 child: ClipOval(
//                   child: Image.asset(
//                     'assets/profile2.png',
//                     fit: BoxFit.cover,
//                     width: screenSize.width * 0.4,
//                     height: screenSize.width * 0.4,
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.03),
//               Text(
//                 'Login Page',
//                 style: TextStyle(
//                   fontSize: screenSize.width * 0.07,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.03),
//               _buildTextField(_usernameController, 'Enter Email Id'),
//               SizedBox(height: screenSize.height * 0.02),
//               _buildTextField(_passwordController, 'Enter Password',
//                   obscureText: true),
//               SizedBox(height: screenSize.height * 0.01),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Get.to(RegistrationPage()),
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           'Create new Account',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: MediaQuery.of(context).size.width *
//                                 0.04, // Dynamic font size
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () {
//                         // Navigate to Forgot Password
//                       },
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           'Forgot Password?',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: MediaQuery.of(context).size.width *
//                                 0.04, // Dynamic font size
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: screenSize.height * 0.03),
//               _buildLoginButton(screenSize),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String hint,
//       {bool obscureText = false}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.blue[50],
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.lightBlue, width: 4.0),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.blue, width: 2.0),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoginButton(Size screenSize) {
//     return Container(
//       width: screenSize.width * 0.6,
//       child: ElevatedButton(
//         onPressed:
//             _isLoading ? null : _handleLogin, // Disable button when loading
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xff83BBFB),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         child: _isLoading
//             ? SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   strokeWidth: 2,
//                 ),
//               )
//             : const Text('Login',
//                 style: TextStyle(fontSize: 20, color: Colors.white)),
//       ),
//     );
//   }
// }
///
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fitness/Screens/tellme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Registration.dart';
import 'entry.dart';

class LoginPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _generatedCode; // Variable to hold the generated code
  String? errorMessage;
  bool _isLoading = false;
  bool isForgotPasswordVisible = false;
  bool isLoginVisible = true;

  // Function to send verification code email
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
      setState(() {
        isForgotPasswordVisible = false; // Hide forgot password widget
        isLoginVisible = false; // Hide login widget if we are in password reset
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to send email. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Function to reset password
  Future<void> _resetPassword() async {
    final verificationCode = _verificationCodeController.text;
    final newPassword = _passwordController.text;
    final username = _usernameController.text; // Captures the username

    // Check if the verification code is valid
    if (verificationCode != _generatedCode) {
      Get.snackbar("Error", "Invalid verification code.");
      return;
    }

    // Check if the new password is not empty
    if (newPassword.isEmpty) {
      Get.snackbar("Error", "Please enter a new password.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Send API request to reset password
      final response = await http.put(
        Uri.parse(
            'https://fitnessproject-production.up.railway.app/api/auth/update-password'),
        body: {
          'username': username,
          'password':
              newPassword, // Using "password" as per updated service logic
        },
      );

      if (response.statusCode == 200) {
        // Successful response from the server
        final responseBody = jsonDecode(response.body);
        String message = responseBody['message'] ?? 'Password reset successful';
        Get.snackbar("Success", message);

        // Reset flags to show login screen again
        setState(() {
          isForgotPasswordVisible = false;
          isLoginVisible = true;
        });
      } else {
        // Handle failure response from the server
        final responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['error'] ?? 'An error occurred';
        Get.snackbar("Error", errorMessage);
      }
    } catch (e) {
      // Handle network errors or unexpected exceptions
      Get.snackbar(
        "Error",
        "Failed to reset password. Please try again later.",
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner after request
      });
    }
  }

  // Function to simulate login API call
  Future<void> _handleLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    setState(() {
      _isLoading = true; // Set loading to true when API call starts
    });

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Username and Password cannot be empty.");
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/auth/authenticate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
          <String, String>{'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final jwtToken = responseData['token'];
      final username = responseData['username'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('jwtToken', jwtToken);

      _checkProfileCompletion();
    } else {
      Get.snackbar("Login Failed", "Invalid username or password.");
      setState(() {
        _isLoading = false; // Set loading to false when API call completes
      });
    }
  }

  Future<void> _checkProfileCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      setState(() {
        errorMessage = 'Authentication token not found. Please log in.';
      });
      return;
    }

    final jwt = JWT.decode(token);
    final subject = jwt.payload['sub'];
    final response = await http.get(
      Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/userdetails/getAll/$subject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);

      if (profileData != null && profileData['age'] != null) {
        setState(() {
          _isLoading = false; // Set loading to false when API call completes
        });
        Get.off(() => HomeScreen());
      } else {
        setState(() {
          _isLoading = false; // Set loading to false when API call completes
        });
        Get.off(() => GettingFamiliarScreen());
      }
    } else {
      Get.snackbar("Error", "Failed to fetch profile data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: screenSize.height * 0.1),
              CircleAvatar(
                radius: screenSize.width * 0.2,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.asset(
                    'assets/profile2.png',
                    fit: BoxFit.cover,
                    width: screenSize.width * 0.4,
                    height: screenSize.width * 0.4,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              if (isForgotPasswordVisible)
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              SizedBox(height: screenSize.height * 0.03),

              // Forgot Password Widget
              if (isForgotPasswordVisible) ...[
                _buildTextField(_usernameController, 'Enter Email Address'),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: () =>
                      _sendVerificationEmail(_usernameController.text),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Send Verification Code'),
                ),
              ],

              // Verification and New Password Widget
              if (!isForgotPasswordVisible && !isLoginVisible) ...[
                _buildTextField(
                    _verificationCodeController, 'Enter Verification Code'),
                SizedBox(height: screenSize.height * 0.02),
                _buildTextField(_passwordController, 'Enter New Password',
                    obscureText: true),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Set New Password'),
                ),
              ],

              // Login Form (visible after successful password reset)
              if (isLoginVisible) ...[
                //               SizedBox(height: screenSize.height * 0.03),
                Text(
                  'Login Page',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                _buildTextField(_usernameController, 'Enter Email Id'),
                SizedBox(height: screenSize.height * 0.02),
                _buildTextField(_passwordController, 'Enter Password',
                    obscureText: true),
                SizedBox(height: screenSize.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.to(RegistrationPage()),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Create new Account',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: MediaQuery.of(context).size.width *
                                  0.04, // Dynamic font size
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isForgotPasswordVisible = true;
                            isLoginVisible = false;
                          });
                          // Navigate to Forgot Password
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: MediaQuery.of(context).size.width *
                                  0.04, // Dynamic font size
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isLoginVisible) ...[
                SizedBox(height: screenSize.height * 0.03),
                _buildLoginButton(screenSize),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size screenSize) {
    return Container(
      width: screenSize.width * 0.6,
      child: ElevatedButton(
        onPressed:
            _isLoading ? null : _handleLogin, // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff83BBFB),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text('Login',
                style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
