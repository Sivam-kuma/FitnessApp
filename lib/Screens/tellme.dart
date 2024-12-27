import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';

class GettingFamiliarScreen extends StatefulWidget {
  @override
  _GettingFamiliarScreenState createState() => _GettingFamiliarScreenState();
}

class _GettingFamiliarScreenState extends State<GettingFamiliarScreen> {
  String? selectedGoal;
  String? selectedGender;
  String? selectedEquipment;
  int count = 0;
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            Text(
              "Getting Familiar with You",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/tellme.png',
              height: 200,
            ),
            SizedBox(height: 20),
            _buildDropdownField(
                "Your Goal",
                ["Lose Weight", "Build Muscle", "Stay Fit"],
                selectedGoal, (value) {
              setState(() {
                selectedGoal = value;
              });
            }),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildTextField("Height (Feet)", heightController)),
                SizedBox(width: 10),
                Expanded(
                    child: _buildDropdownField(
                        "Gender", ["Male", "Female", "Other"], selectedGender,
                        (value) {
                  setState(() {
                    selectedGender = value;
                  });
                })),
              ],
            ),
            SizedBox(height: 20),
            _buildDropdownField(
                "Equipment", ["None", "Basic", "Advanced"], selectedEquipment,
                (value) {
              setState(() {
                selectedEquipment = value;
              });
            }),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildTextField("Weight (Kg)", weightController)),
                SizedBox(width: 10),
                Expanded(child: _buildTextField("Age", ageController)),
              ],
            ),
            SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    _submitDetails, // Call the API when the button is pressed
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String labelText, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              labelText,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: labelText,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }

  Future<void> _submitDetails() async {
    String? token = await _getToken();

    print("Fetched token: $token"); // Debugging token fetch

    if (token != null) {
      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub'];
      Map<String, dynamic> requestBody = {
        "categories": selectedGoal,
        "gender": selectedGender,
        "equipment": selectedEquipment,
        "age": int.tryParse(ageController.text) ?? 0,
        "weight": int.tryParse(weightController.text) ?? 0,
        "height": int.tryParse(heightController.text) ?? 0,
        "userId": subject,
      };

      try {
        print("Request body: $requestBody"); // Debugging request body

        final response = await http.post(
          Uri.parse(
            'https://fitnessproject-production.up.railway.app/api/userdetails/create',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );

        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          // Increment and store 'count' in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          int count = prefs.getInt('count') ?? 0;
          count++;
          await prefs.setInt('count', count);

          // Navigate to WorkoutPage
          Get.to(() => HomeScreen());
        } else if (response.statusCode == 401) {
          print('Error: Unauthorized. Please log in again.');
        } else {
          print('Failed to submit details: ${response.body}');
        }
      } catch (error) {
        print('Error occurred: $error');
      }
    } else {
      print('No token found! You need to log in first.');
    }
  }

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      // Debugging: Check if token is null or not
      if (token == null) {
        print("Token not found in SharedPreferences.");
      }

      return token;
    } catch (error) {
      // Handle any errors related to SharedPreferences
      print("Error fetching token from SharedPreferences: $error");
      return null;
    }
  }
}
