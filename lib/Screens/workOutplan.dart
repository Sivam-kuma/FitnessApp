import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutPlanScreen extends StatefulWidget {
  WorkoutPlanScreen();

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  final List<String> exercises = [
    "Chest",
    "Shoulder",
    "Back",
    "Biceps",
    "Triceps",
    "Leg",
    "Rest"
  ];
  Map<String, String> selectedExercises = {};
  bool isLoading = true;
  bool isSaving = false;
  bool isUpdating = false;
  bool planExists = false;
  int? planId;
  Timer? midnightTimer;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlan(); // Fetch workout plan on initialization
    _scheduleMidnightTask(); // Schedule the task to update at midnight
  }

  @override
  void dispose() {
    midnightTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchWorkoutPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please login.')),
      );
      return;
    }

    final jwt = JWT.decode(token);
    final subject = jwt.payload['sub'];
    final url =
        'https://remainingsfitness-production.up.railway.app/api/days-exercises/user/$subject';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          planExists = true;
          planId = data[0]['id'];
          final exercisesData = data[0]['exercises'];
          for (var exercise in exercisesData) {
            selectedExercises[exercise['day']] = exercise['exerciseName'];
          }
          _saveTodayExercise(); // Save today's exercise in SharedPreferences
        } else {
          planExists = false;
        }
      } else {
        print('Failed to load workout plan');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveTodayExercise() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dayOfWeek = daysOfWeek[DateTime.now().weekday - 1];
    final todayExercise = selectedExercises[dayOfWeek];
    if (todayExercise != null) {
      await prefs.setString('todayExercise', todayExercise);
      print('Saved today\'s exercise: $todayExercise');
    }
  }

  Future<void> _clearSavedExercise() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('todayExercise');
    print('Cleared saved exercise for the day');
  }

  void _scheduleMidnightTask() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final timeUntilMidnight = midnight.difference(now);

    midnightTimer = Timer(timeUntilMidnight, () async {
      await _clearSavedExercise();
      await _saveTodayExercise();
      _scheduleMidnightTask(); // Reschedule for the next midnight
    });
  }

  Future<void> _saveWorkoutPlan() async {
    setState(() {
      isSaving = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please login.')),
      );
      setState(() {
        isSaving = false;
      });
      return;
    }

    final jwt = JWT.decode(token);
    final subject = jwt.payload['sub'];
    final url =
        'https://remainingsfitness-production.up.railway.app/api/days-exercises';
    final body = {
      "userId": subject,
      "exercises": selectedExercises.entries.map((entry) {
        return {"day": entry.key, "exerciseName": entry.value};
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Workout plan saved successfully');
        setState(() {
          planExists = true;
        });
      } else {
        print('Failed to save workout plan');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isSaving = false;
    });
  }

  Future<void> _updateWorkoutPlan() async {
    if (planId == null) return;

    setState(() {
      isUpdating = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please login.')),
      );
      setState(() {
        isUpdating = false;
      });
      return;
    }

    final jwt = JWT.decode(token);
    final subject = jwt.payload['sub'];
    final url =
        'https://remainingsfitness-production.up.railway.app/api/days-exercises/$planId';
    final body = {
      "userId": subject,
      "exercises": selectedExercises.entries.map((entry) {
        return {"day": entry.key, "exerciseName": entry.value};
      }).toList(),
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Workout plan updated successfully');
      } else {
        print('Failed to update workout plan');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black45),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Workout Plan',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                return ListTile(
                  title: Text(day),
                  trailing: DropdownButton<String>(
                    value: selectedExercises[day],
                    hint: Text("Select Exercise"),
                    items: exercises.map((exercise) {
                      return DropdownMenuItem(
                        value: exercise,
                        child: Text(exercise),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExercises[day] = value!;
                      });
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: planExists ? _updateWorkoutPlan : _saveWorkoutPlan,
          child: isSaving
              ? CircularProgressIndicator(color: Colors.white)
              : isUpdating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      planExists ? "Update Workout Plan" : "Save Workout Plan"),
        ),
      ),
    );
  }
}
