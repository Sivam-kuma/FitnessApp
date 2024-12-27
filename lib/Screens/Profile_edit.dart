import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State variables for dropdowns and dark mode
  List<String> goals = ["Lose Weight", "Build Muscle", "Stay Fit"];
  List<String> equipments = ["None", "Basic", "Advanced"];
  List<String> genders = ["Male", "Female", "Other"];

  String? selectedGoal;
  String? selectedEquipment;
  String? selectedGender;
  bool isDarkMode = false;
  String _username = '';

  // Controllers for text fields
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String? errorMessage;
  int? userId; // To store the `id` from the GET API response

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadUsername();
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

    try {
      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub'];

      final response = await http.get(
        Uri.parse(
            'https://fitnessproject-production.up.railway.app/api/userdetails/getAll/$subject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        _populateFields(profileData);
        userId = profileData['id']; // Store the `id` from the response
      } else {
        Get.snackbar("Error", "Failed to fetch profile data.");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    setState(() {
      weightController.text = data['weight'].toString();
      heightController.text = data['height'].toString();
      ageController.text = data['age'].toString();
      selectedGender = data['gender'];
      selectedGoal = data['categories'];
      selectedEquipment = data['equipment'];
    });
  }

  Future<void> _updateProfile() async {
    if (userId == null) {
      Get.snackbar("Error", "User ID not available.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      Get.snackbar("Error", "Authentication token not found.");
      return;
    }

    final url =
        'https://fitnessproject-production.up.railway.app/api/userdetails/$userId';

    final body = jsonEncode({
      "categories": selectedGoal,
      "equipment": selectedEquipment,
      "gender": selectedGender,
      "age": double.tryParse(ageController.text) ?? 0,
      "weight": double.tryParse(weightController.text) ?? 0,
      "height": double.tryParse(heightController.text) ?? 0,
    });

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Profile updated successfully.");
      } else {
        Get.snackbar("Error", "Failed to update profile.");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username =
          prefs.getString('name') ?? 'User'; // Default to 'User' if not set
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black45),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),

              ///
              _buildDropdownField(
                "Your Goal",
                goals,
                selectedGoal,
                (value) {
                  setState(() {
                    selectedGoal = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildTextField(heightController, "Height (Feet)")),
                  SizedBox(width: 10),
                  // Expanded(
                  //   child: _buildDropdownField(
                  //       context, "Gender", genders, selectedGender),
                  // ),

                  Expanded(
                    child: _buildDropdownField(
                      "Gender",
                      genders,
                      selectedGender,
                      (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDropdownField(
                "Equipment",
                equipments,
                selectedEquipment,
                (value) {
                  setState(() {
                    selectedEquipment = value;
                  });
                },
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(weightController, "Weight (Kg)")),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField(ageController, "Age")),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Color(0xff89C0FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/profile1.png', // Replace with your logo path
                height: 100, // Set the desired height
                width: 100, // Set the desired width
              ),
              // Positioned(
              //   right: 0,
              //   bottom: 0,
              //   child: IconButton(
              //     icon: Icon(Icons.edit, color: Colors.blue),
              //     onPressed: () {
              //       // Action to edit profile picture
              //     },
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 10),
          _username.isNotEmpty
              ? Text(
                  _username.toUpperCase(), // Display first letter
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              : Text("user")
        ],
      ),
    );
  }

  Widget _buildDropdownField(String labelText, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              labelText,
              style: TextStyle(
                color: selectedValue == null ? Colors.black54 : Colors.black54,
                fontSize: 12,
                // Optional: You can change the font style when selected
              ),
            ),
          ),
          // Dropdown and selected value display
          GestureDetector(
            onTap: () async {
              String? value = await _showDropdownMenu(context, items);
              if (value != null) {
                onChanged(
                    value); // Call the provided function to update the state
              }
            },
            child: Container(
              height: 40, // Adjust height for the dropdown
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      // selectedValue ?? 'Select $labelText',
                      selectedValue ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedValue == null
                            ? Colors.black54
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
          // Floating label settings
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Control label behavior
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: Colors.transparent, width: 1.0), // Border when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: Colors.transparent, width: 2.0), // Border when focused
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }

  Future<String?> _showDropdownMenu(
      BuildContext context, List<String> items) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: items.map((String item) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(item),
            );
          }).toList(),
        );
      },
    );
  }
}

///
// import 'dart:convert';
//
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:fitness/Screens/Home.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   // State variables for dropdowns and dark mode
//   List<String> goals = ["Weight Loss", "Muscle Gain", "General Fitness"];
//   List<String> equipments = ["None", "Basic", "Advanced", "Dumbbells"];
//   List<String> genders = ["Male", "Female", "Other"];
//
//   String? selectedGoal;
//   String? selectedEquipment;
//   String? selectedGender;
//   bool isDarkMode = false;
//
//   // Controllers for text fields
//   TextEditingController heightController = TextEditingController();
//   TextEditingController weightController = TextEditingController();
//   TextEditingController ageController = TextEditingController();
//
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkProfileCompletion();
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
//     try {
//       final jwt = JWT.decode(token);
//       final subject = jwt.payload['sub'];
//       final response = await http.get(
//         Uri.parse(
//             'https://fitnessproject-production.up.railway.app/api/userdetails/getAll/$subject'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final profileData = jsonDecode(response.body);
//         _populateFields(profileData);
//       } else {
//         Get.snackbar("Error", "Failed to fetch profile data.");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "An error occurred: $e");
//     }
//   }
//
//   void _populateFields(Map<String, dynamic> data) {
//     setState(() {
//       weightController.text = data['weight'].toString();
//       heightController.text = data['height'].toString();
//       ageController.text = data['age'].toString();
//       selectedGender = data['gender'];
//       selectedGoal = data['categories'];
//       selectedEquipment = data['equipment'];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             IconButton(
//               icon: Icon(
//                 isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
//                 color: isDarkMode ? Colors.white : Colors.orange,
//               ),
//               onPressed: () {
//                 setState(() {
//                   isDarkMode = !isDarkMode;
//                   Get.changeTheme(
//                     isDarkMode ? ThemeData.dark() : ThemeData.light(),
//                   );
//                 });
//               },
//             ),
//             SizedBox(width: 10),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildProfileSection(),
//               SizedBox(height: 20),
//               Divider(),
//               SizedBox(height: 10),
//               _buildDropdownField(context, "Your Goal", goals, selectedGoal),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                       child:
//                           _buildTextField(heightController, "Height (Feet)")),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: _buildDropdownField(
//                         context, "Gender", genders, selectedGender),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               _buildDropdownField(
//                   context, "Equipment", equipments, selectedEquipment),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                       child: _buildTextField(weightController, "Weight (Kg)")),
//                   SizedBox(width: 10),
//                   Expanded(child: _buildTextField(ageController, "Age")),
//                 ],
//               ),
//               SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () {
//                   Get.to(WorkoutPage());
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(200, 50),
//                   backgroundColor: Colors.lightBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'SUBMIT',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileSection() {
//     return Center(
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.blue.shade100,
//                 child: Icon(Icons.person, size: 60),
//               ),
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: IconButton(
//                   icon: Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () {
//                     // Action to edit profile picture
//                   },
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Name",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdownField(
//       BuildContext context, String labelText, List<String> items,
//       [String? selectedValue]) {
//     return StatefulBuilder(
//       builder: (BuildContext context, StateSetter setState) {
//         return Container(
//           height: 60,
//           padding: EdgeInsets.symmetric(horizontal: 0.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 5,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     selectedValue ?? labelText,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: selectedValue == null
//                           ? Colors.black54
//                           : Colors.black.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () async {
//                   String? value = await _showDropdownMenu(context, items);
//                   if (value != null) {
//                     setState(() {
//                       selectedValue = value;
//                     });
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.lightBlue,
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(10.0),
//                       bottomRight: Radius.circular(10.0),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8.0, vertical: 18.0),
//                     child: Icon(Icons.arrow_drop_down, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String labelText) {
//     return Container(
//       height: 60,
//       padding: EdgeInsets.symmetric(horizontal: 0.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 5,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: labelText,
//           contentPadding:
//               EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
//           hintStyle: TextStyle(color: Colors.black54),
//         ),
//         style: TextStyle(
//           fontSize: 16,
//           color: Colors.black.withOpacity(0.8),
//         ),
//       ),
//     );
//   }
//
//   Future<String?> _showDropdownMenu(
//       BuildContext context, List<String> items) async {
//     return await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           children: items.map((String item) {
//             return SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, item),
//               child: Text(item),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
///
// import 'dart:convert';
//
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   // State variables for dropdowns and dark mode
//   List<String> goals = ["Weight Loss", "Muscle Gain", "General Fitness"];
//   List<String> equipments = ["None", "Basic", "Advanced", "Dumbbells"];
//   List<String> genders = ["Male", "Female", "Other"];
//
//   String? selectedGoal;
//   String? selectedEquipment;
//   String? selectedGender;
//   bool isDarkMode = false;
//
//   // Controllers for text fields
//   TextEditingController heightController = TextEditingController();
//   TextEditingController weightController = TextEditingController();
//   TextEditingController ageController = TextEditingController();
//   final GlobalKey<FormFieldState> _textFieldKey = GlobalKey<FormFieldState>();
//
//   String? errorMessage;
//   int? userId; // To store the `id` from the GET API response
//
//   @override
//   void initState() {
//     super.initState();
//     _checkProfileCompletion();
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
//     try {
//       final jwt = JWT.decode(token);
//       final subject = jwt.payload['sub'];
//
//       final response = await http.get(
//         Uri.parse(
//             'https://fitnessproject-production.up.railway.app/api/userdetails/getAll/$subject'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final profileData = jsonDecode(response.body);
//         _populateFields(profileData);
//         userId = profileData['id']; // Store the `id` from the response
//       } else {
//         Get.snackbar("Error", "Failed to fetch profile data.");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "An error occurred: $e");
//     }
//   }
//
//   void _populateFields(Map<String, dynamic> data) {
//     setState(() {
//       weightController.text = data['weight'].toString();
//       heightController.text = data['height'].toString();
//       ageController.text = data['age'].toString();
//       selectedGender = data['gender'];
//       selectedGoal = data['categories'];
//       selectedEquipment = data['equipment'];
//     });
//   }
//
//   Future<void> _updateProfile() async {
//     if (userId == null) {
//       Get.snackbar("Error", "User ID not available.");
//       return;
//     }
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('jwtToken');
//
//     if (token == null) {
//       Get.snackbar("Error", "Authentication token not found.");
//       return;
//     }
//
//     final url =
//         'https://fitnessproject-production.up.railway.app/api/userdetails/$userId';
//
//     final body = jsonEncode({
//       "categories": selectedGoal,
//       "equipment": selectedEquipment,
//       "gender": selectedGender,
//       "age": double.tryParse(ageController.text) ?? 0,
//       "weight": double.tryParse(weightController.text) ?? 0,
//       "height": double.tryParse(heightController.text) ?? 0,
//     });
//
//     try {
//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         Get.snackbar("Success", "Profile updated successfully.");
//       } else {
//         Get.snackbar("Error", "Failed to update profile.");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "An error occurred: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             IconButton(
//               icon: Icon(
//                 isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
//                 color: isDarkMode ? Colors.white : Colors.orange,
//               ),
//               onPressed: () {
//                 setState(() {
//                   isDarkMode = !isDarkMode;
//                   Get.changeTheme(
//                     isDarkMode ? ThemeData.dark() : ThemeData.light(),
//                   );
//                 });
//               },
//             ),
//             SizedBox(width: 10),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildProfileSection(),
//               SizedBox(height: 20),
//               Divider(),
//               SizedBox(height: 10),
//               _buildDropdownField(context, "Your Goal", goals, selectedGoal),
//               // _buildDropdownField(
//               //   "Your Goal",
//               //   goals,
//               //   selectedGoal,
//               //   (value) {
//               //     setState(() {
//               //       selectedGoal = value;
//               //     });
//               //   },
//               // ),
//
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                       child:
//                           _buildTextField(heightController, "Height (Feet)")),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: _buildDropdownField(
//                         context, "Gender", genders, selectedGender),
//                     // _buildDropdownField(
//                     //   "Gender",
//                     //   genders,
//                     //   selectedGender,
//                     //   (value) {
//                     //     setState(() {
//                     //       selectedGender = value;
//                     //     });
//                     //   },
//                     // ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               _buildDropdownField(
//                   context, "Equipment", equipments, selectedEquipment),
//               // _buildDropdownField(
//               //   "Equipment",
//               //   equipments,
//               //   selectedEquipment,
//               //   (value) {
//               //     setState(() {
//               //       selectedEquipment = value;
//               //     });
//               //   },
//               // ),
//
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                       child: _buildTextField(weightController, "Weight (Kg)")),
//                   SizedBox(width: 10),
//                   Expanded(child: _buildTextField(ageController, "Age")),
//                 ],
//               ),
//               SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: _updateProfile,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(200, 50),
//                   backgroundColor: Colors.lightBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'SUBMIT',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileSection() {
//     return Center(
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.blue.shade100,
//                 child: Icon(Icons.person, size: 60),
//               ),
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: IconButton(
//                   icon: Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () {
//                     // Action to edit profile picture
//                   },
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Name",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdownField(
//       BuildContext context, String labelText, List<String> items,
//       [String? selectedValue]) {
//     return StatefulBuilder(
//       builder: (BuildContext context, StateSetter setState) {
//         return Container(
//           height: 60,
//           padding: EdgeInsets.symmetric(horizontal: 0.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 5,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     selectedValue ?? labelText,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: selectedValue == null
//                           ? Colors.black54
//                           : Colors.black.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () async {
//                   String? value = await _showDropdownMenu(
//                     context,
//                     items,
//                   );
//                   if (value != null) {
//                     setState(() {
//                       selectedValue = value;
//                     });
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.lightBlue,
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(10.0),
//                       bottomRight: Radius.circular(10.0),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8.0, vertical: 18.0),
//                     child: Icon(Icons.arrow_drop_down, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Widget _buildDropdownField(
//   //   String labelText,
//   //   List<String> items,
//   //   String? selectedValue,
//   //   ValueChanged<String?> onChanged,
//   // ) {
//   //   return Container(
//   //     height: 60,
//   //     padding: EdgeInsets.symmetric(horizontal: 0.0),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(10.0),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.5),
//   //           blurRadius: 5,
//   //           offset: Offset(0, 5),
//   //         ),
//   //       ],
//   //     ),
//   //     child: DropdownButtonHideUnderline(
//   //       child: DropdownButton<String>(
//   //         isExpanded: true,
//   //         hint: Padding(
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Text(
//   //             labelText,
//   //             style: TextStyle(color: Colors.black54),
//   //           ),
//   //         ),
//   //         value: selectedValue, // This can be null
//   //         onChanged: onChanged,
//   //         items: items.map((String value) {
//   //           return DropdownMenuItem<String>(
//   //             value: value,
//   //             child: Padding(
//   //               padding: const EdgeInsets.all(8.0),
//   //               child: Text(value),
//   //             ),
//   //           );
//   //         }).toList(),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildTextField(TextEditingController controller, String labelText) {
//     return Container(
//       height: 60,
//       padding: EdgeInsets.symmetric(horizontal: 0.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 5,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TextField(
//         key: _textFieldKey,
//         controller: controller,
//         decoration: InputDecoration(
//           hintText: labelText,
//           hintStyle: TextStyle(color: Colors.black54),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.all(10),
//         ),
//       ),
//     );
//   }
//
//   // Future<String?> _showDropdownMenu(BuildContext context, List<String> items) {
//   //   return showMenu<String>(
//   //     context: context,
//   //     position: RelativeRect.fromLTRB(100.0, 150.0, 100.0, 100.0),
//   //     items: items
//   //         .map((String item) => PopupMenuItem<String>(
//   //               value: item,
//   //               child: Text(item),
//   //             ))
//   //         .toList(),
//   //   );
//   // }
//   Future<String?> _showDropdownMenu(
//       BuildContext context, List<String> items) async {
//     return await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           children: items.map((String item) {
//             return SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, item),
//               child: Text(item),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
