///
import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CalorieTrackerPage extends StatefulWidget {
  @override
  _CalorieTrackerPageState createState() => _CalorieTrackerPageState();
}

class _CalorieTrackerPageState extends State<CalorieTrackerPage> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  List<Map<String, dynamic>> _addedItems = [];
  bool _isLoading = false;
  bool _isConsumptionMode = true;
  bool _isPrefsLoaded = false; // Track loading of SharedPreferences
  String _selectedUnit = 'Bowl';
  final List<String> _units = ['Bowl', 'Number'];

  @override
  void initState() {
    super.initState();
    _loadSavedItems(); // Load saved items on init
    _scheduleRegularDeletion(); // Schedule deletion every 2 minutes for testing
  }

  /// Load saved food items from SharedPreferences
  Future<void> _loadSavedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedItems = prefs.getString('addedItems');
    if (savedItems != null) {
      setState(() {
        _addedItems = List<Map<String, dynamic>>.from(jsonDecode(savedItems));
      });
    }
    setState(() {
      _isPrefsLoaded = true; // Indicate that prefs are loaded
    });
  }

  /// Save the current list of added items to SharedPreferences
  Future<void> _saveItemsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('addedItems', jsonEncode(_addedItems));
  }

  /// Schedule a function to delete saved items every 2 minutes

  void _scheduleRegularDeletion() async {
    // Get the current UTC time
    DateTime nowUtc = DateTime.now().toUtc();

    // Convert to Indian Standard Time (IST)
    DateTime nowIst = nowUtc.add(Duration(hours: 5, minutes: 30));

    // Calculate the next midnight in IST
    DateTime nextMidnightIst = DateTime(
        nowIst.year, nowIst.month, nowIst.day + 1); // Next day at 00:00:00 IST

    // Calculate the duration until the next midnight
    Duration durationUntilMidnight = nextMidnightIst.difference(nowIst);

    // Schedule the deletion
    Timer(durationUntilMidnight, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('addedItems'); // Delete saved items

      // Clear the UI list
      setState(() {
        _addedItems.clear(); // Clear the list
      });

      // Optionally, you can call _loadSavedItems() to refresh the data
      // _loadSavedItems();

      // Reschedule for the next day at midnight IST
      _scheduleRegularDeletion();
    });
  }

  Future<void> _searchFood(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');
      if (token == null) return;

      final response = await http.get(
        // Uri.parse('https://fitness-tag1.onrender.com/api/search?name=$query'),
        Uri.parse(
            'https://fitnessproject-production.up.railway.app/api/search?name=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postNutritionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token == null) return; // Exit if token is missing.
    final jwt = JWT.decode(token);
    final subject = jwt.payload['sub'];
    // Prepare API body.
    Map<String, dynamic> requestBody = {
      "carbohydrates": carbohydrateValue ?? 0.0,
      "fat": fatValue ?? 0.0,
      "protein": proteinValue ?? 0.0,
      "userId": subject, // Replace with dynamic user ID if needed.
    };

    try {
      // Make the POST request.
      final response = await http.post(
        // Uri.parse('https://fitness-tag1.onrender.com/api/Food/save'),
        Uri.parse(
            'https://fitnessproject-production.up.railway.app/api/Food/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Nutrition data saved successfully');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Nutrition data saved successfully!')),
        // );
      } else {
        print('Failed to save data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving data.')),
      );
    }
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _foodController.text = food['name'];
      _searchResults = [];
      print(
          "Selected food: $_selectedFood"); // Debug line to check selected food data
    });
  }

  void _addItem() {
    if (_selectedFood == null || _quantityController.text.isEmpty) return;

    Map<String, dynamic> newItem = {
      'name': _selectedFood!['name'],
      'quantity': _quantityController.text,
      'unit': _selectedUnit,
    };

    setState(() {
      _addedItems.add(newItem);
      _selectedFood = null;
      _foodController.clear();
      _quantityController.clear();
    });

    _saveItemsToPrefs(); // Save to SharedPreferences
  }

  ///
  double? proteinValue;
  double? fatValue;
  double? carbohydrateValue;
  double? caloriesValue;
  void _calculateNutritionalValues() {
    if (_selectedFood != null && _quantityController.text.isNotEmpty) {
      double quantity = double.tryParse(_quantityController.text) ?? 1.0;

      proteinValue = (_selectedFood!['protein'] != null
              ? (_selectedFood!['protein'] as num).toDouble()
              : 0) *
          quantity;

      fatValue = (_selectedFood!['fat'] != null
              ? (_selectedFood!['fat'] as num).toDouble()
              : 0) *
          quantity;

      carbohydrateValue = (_selectedFood!['carbohydrate'] != null
              ? (_selectedFood!['carbohydrate'] as num).toDouble()
              : 0) *
          quantity;

      caloriesValue =
          (carbohydrateValue! * 4 + proteinValue! * 4 + fatValue! * 9);
    }
  }

  bool _isSearchVisible = false;
  void _toggleSearchVisibility(bool isVisible) {
    setState(() {
      _isSearchVisible = isVisible;
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
          'Calories Tracker',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Hide search results if visible and user taps outside
          if (_isSearchVisible) _toggleSearchVisibility(false);
          FocusScope.of(context).unfocus(); // Close keyboard if open
        },
        child: SingleChildScrollView(
          child: _isPrefsLoaded // Wait for SharedPreferences to load
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mode: ${_isConsumptionMode ? "Consumption" : "Search Only"}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            value: _isConsumptionMode,
                            onChanged: (value) {
                              setState(() {
                                _isConsumptionMode = value;
                                _foodController.clear();
                                _quantityController.clear();
                                _selectedFood = null;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _foodController,
                        onTap: () => _toggleSearchVisibility(true),
                        decoration: InputDecoration(
                          labelText: 'Food Item',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: Color(0xff89C0FF)),
                            onPressed: () {
                              _searchFood(_foodController.text);
                              _toggleSearchVisibility(
                                  true); // Show search results
                            },
                          ),
                        ),
                        onChanged: (value) => _searchFood(value),
                      ),
                      if (_isSearchVisible && _searchResults.isNotEmpty)
                        SizedBox(
                          height: 200, // Fix the height
                          child: Scrollbar(
                            thumbVisibility:
                                true, // Optional: Keep the thumb visible for modern UI
                            radius: Radius.circular(
                                8.0), // Rounded scrollbar for a modern look
                            thickness: 6.0, // Thickness of the scrollbar thumb
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                return ListTile(
                                  title: Text(
                                    item['name'],
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onTap: () {
                                    _selectFood(item); // Select item
                                    _toggleSearchVisibility(
                                        false); // Hide search results
                                  },
                                  leading: Icon(Icons.local_dining,
                                      color: Color(
                                          0xff89C0FF)), // Modern touch with icon
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      size: 16.0, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),

                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedUnit,
                            onChanged: (String? newValue) {
                              setState(() => _selectedUnit = newValue!);
                            },
                            items: _units
                                .map<DropdownMenuItem<String>>((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),
                      if (_selectedFood != null)
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nutrition Information',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff89C0FF),
                                          ),
                                    ),
                                    SizedBox(height: 8),
                                    if (proteinValue !=
                                        null) // Only display if calculated
                                      Text(
                                          'Protein: ${proteinValue!.toStringAsFixed(2)} g'),
                                    if (fatValue !=
                                        null) // Only display if calculated
                                      Text(
                                          'Fat: ${fatValue!.toStringAsFixed(2)} g'),
                                    if (carbohydrateValue !=
                                        null) // Only display if calculated
                                      Text(
                                          'Carbohydrate: ${carbohydrateValue!.toStringAsFixed(2)} g'),
                                    if (caloriesValue !=
                                        null) // Only display if calculated
                                      Text(
                                          'Calories: ${caloriesValue!.toStringAsFixed(2)} kcal'),
                                    SizedBox(
                                        height:
                                            16), // Add space before the button
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    _calculateNutritionalValues();
                                    setState(() {});
                                    // await _postNutritionData(); // Call API on button press
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30.0), // Rounded corners
                                    ),
                                    backgroundColor: Color(0xff89C0FF),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical:
                                            12.0), // Button background color
                                  ),
                                  child: Text(
                                    'Go',
                                    style: TextStyle(
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ///

                      SizedBox(height: 16),
                      if (_isConsumptionMode)
                        ElevatedButton(
                          // onPressed: _addItem,
                          onPressed: () async {
                            _addItem();
                            setState(() {});
                            await _postNutritionData(); // Call API on button press
                          },
                          child: Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'poppins',
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff89C0FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: _addedItems.map((item) {
                          return Chip(
                            label: Text(
                                '${item['name']} (${item['quantity']} ${item['unit']})'),
                            onDeleted: () {
                              setState(() => _addedItems.remove(item));
                              _saveItemsToPrefs(); // Save changes
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
