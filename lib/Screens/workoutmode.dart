import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Consider using flutter_secure_storage for enhanced security
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkoutTrackerPage extends StatefulWidget {
  @override
  _WorkoutTrackerPageState createState() => _WorkoutTrackerPageState();
}

// class _WorkoutTrackerPageState extends State<WorkoutTrackerPage>
class _WorkoutTrackerPageState extends State<WorkoutTrackerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController workoutController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool isEndurance = true;
  late AnimationController _controller;
  bool isTimerRunning = false;
  int elapsedTime = 0;
  double currentCaloriesBurned = 0;
  double totalCaloriesBurned = 0;
  Timer? _timer;

  List<dynamic> searchResults = [];
  double selectedCaloriesPerSecond = 0;
  bool isSearching = false;
  String? errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Fetch total calories when the widget is initialized
    _fetchTotalCalories();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1), // Set your desired duration here
    );

    // Listen to the AnimationController's value changes
    _controller.addListener(() {
      setState(() {
        elapsedTime =
            (_controller.duration!.inSeconds * (1 - _controller.value)).toInt();
      });
    });
  }

  @override
  void dispose() {
    workoutController.dispose();
    weightController.dispose();
    _controller.dispose();
    _timer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  // void _startTimer() {
  //   _controller.reverse(from: _controller.value == 0 ? 1.0 : _controller.value);
  //   setState(() {
  //     isTimerRunning = true;
  //   });
  // }
  //
  // void _stopTimer() {
  //   _controller.stop();
  //   setState(() {
  //     isTimerRunning = false;
  //   });
  // }

  String _formatElapsedTime(int seconds) {
    final duration = Duration(seconds: seconds);
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }

  // Fetch total calories from the API
  Future<void> _fetchTotalCalories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      if (token == null) {
        print('No token found!');
        setState(() {
          errorMessage = 'Authentication token not found. Please log in.';
        });
        return;
      }

      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub']; // Extract 'sub' from token

      final url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/workouts/$subject');
      print('Fetching total calories from: $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Calories response: ${response.body}');
        final decoded = json.decode(response.body);

        // Extract sessionCalories from the response
        double sessionCalories = decoded['sessionCalories'] != null
            ? (decoded['sessionCalories'] as num).toDouble()
            : 0.0;

        setState(() {
          totalCaloriesBurned = sessionCalories;
          errorMessage = null; // Clear any previous errors
        });
      } else {
        setState(() {
          errorMessage = 'Error fetching calories: ${response.statusCode}';
        });
        print('Error fetching calories: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
      });
      print('Error: Request timed out. $e');
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching calories.';
      });
      print('Error fetching calories: $e');
    }
  }

  // Post session calories to the API
  Future<void> _postSessionCalories(double sessionCalories) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      if (token == null) {
        print('No token found!');
        setState(() {
          errorMessage = 'Authentication token not found. Please log in.';
        });
        return;
      }

      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub'];

      final url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/workouts/save');
      print('Posting session calories to: $url');

      // Create a JSON object with the required key
      final Map<String, dynamic> requestBody = {
        "sessionCalories": sessionCalories,
        "userId": subject
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody), // Send as JSON object
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          errorMessage = null; // Clear any previous errors
        });
        print('Session calories posted successfully!');
        // Optionally, parse and use the response if needed
        final data = json.decode(response.body);
        print('Response data: $data');

        // Fetch the updated total calories
        _fetchTotalCalories();
      } else {
        setState(() {
          errorMessage =
              'Error posting session calories: ${response.statusCode}';
        });
        print('Error posting session calories: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
      });
      print('Error: Request timed out. $e');
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred.';
      });
      print('Error posting session calories: $e');
    }
  }

  Future<void> _searchExercise(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      if (token == null) {
        print('No token found!');
        setState(() {
          errorMessage = 'Authentication token not found. Please log in.';
        });
        return;
      }

      final url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/search/exercise?exerciseName=$query');
      print('Sending request to: $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
        final data = json.decode(response.body);

        // Assuming the response is a list of exercises
        setState(() {
          searchResults = data; // Ensure data is a list
          errorMessage = null; // Clear any previous errors
        });
      } else {
        setState(() {
          errorMessage = 'Error fetching exercises: ${response.statusCode}';
        });
        print('Error: Received status code ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
      });
      print('Error: Request timed out. $e');
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching exercises.';
      });
      print('Error fetching exercises: $e');
    }
  }

  // Debounce function for search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchExercise(query);
    });
  }

  void _startTimer() {
    if (!isEndurance && weightController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a valid weight before starting the timer.';
      });
      print('Please enter a valid weight before starting the timer.');
      return;
    }

    _timer?.cancel();
    setState(() {
      isTimerRunning = true;
      elapsedTime = 0;
      currentCaloriesBurned = 0;
      errorMessage = null; // Clear any previous errors
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime += 1;
        _calculateCaloriesBurned();
      });
    });
  }
  //
  // void _stopTimer() {
  //   _timer?.cancel();
  //   setState(() {
  //     isTimerRunning = false;
  //   });
  //
  //   // Post the session calories to the backend
  //   _postSessionCalories(currentCaloriesBurned);
  // }
  ///
  // void _startTimer() {
  //   if (!isEndurance && weightController.text.isEmpty) {
  //     setState(() {
  //       errorMessage = 'Please enter a valid weight before starting the timer.';
  //     });
  //     print('Please enter a valid weight before starting the timer.');
  //     return;
  //   }
  //
  //   // Reset the animation controller and elapsed time
  //   _controller.reverse(from: _controller.value == 0 ? 1.0 : _controller.value);
  //   setState(() {
  //     isTimerRunning = true;
  //     elapsedTime = 0; // Reset elapsed time
  //     currentCaloriesBurned = 0; // Reset burned calories
  //     errorMessage = null; // Clear any previous errors
  //   });
  //
  //   // Start a periodic update for calories burned
  //   _controller.addStatusListener((status) {
  //     if (status == AnimationStatus.forward) {
  //       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //         setState(() {
  //           elapsedTime += 1;
  //           _calculateCaloriesBurned(); // Call to your existing calculation method
  //         });
  //       });
  //     }
  //   });
  // }

  void _stopTimer() {
    _controller.stop();
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
    });

    // Post the session calories to the backend
    _postSessionCalories(currentCaloriesBurned);
  }

  void _calculateCaloriesBurned() {
    double weight = 0.0;

    if (!isEndurance) {
      if (weightController.text.isEmpty) {
        print('Please enter weight for lifting exercises.');
        setState(() {
          errorMessage = 'Please enter weight for lifting exercises.';
        });
        return;
      }

      try {
        weight = double.parse(weightController.text);
      } catch (e) {
        print('Invalid weight entered: $e');
        setState(() {
          errorMessage = 'Invalid weight entered.';
        });
        return;
      }
    }

    if (isEndurance) {
      weight = 1.0;
    }

    currentCaloriesBurned = elapsedTime * selectedCaloriesPerSecond * weight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black45),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Workout Mode',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // To prevent overflow when keyboard appears
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: workoutController,
                    decoration: InputDecoration(
                      labelText: 'Workout Type',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: !isEndurance,
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mode: ${isEndurance ? "Endurance" : "Lifting"}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Switch(
                        value: isEndurance,
                        onChanged: (value) {
                          setState(() {
                            isEndurance = value;
                            errorMessage =
                                null; // Clear errors when switching mode
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // ElevatedButton(
                  //   onPressed: isTimerRunning ? _stopTimer : _startTimer,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //         isTimerRunning ? Colors.red : Colors.green,
                  //   ),
                  //   child: Text(isTimerRunning ? 'Stop' : 'Start'),
                  // ),

                  // AnimatedBuilder(
                  //   animation: _controller,
                  //   builder: (context, child) {
                  //     return Container(
                  //       width: 200,
                  //       height: 200,
                  //       child: CustomPaint(
                  //         painter: TimerPainter(
                  //           animation: _controller,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  SizedBox(height: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_formatElapsedTime(elapsedTime)}',
                        style: TextStyle(
                            fontSize: 100.0,
                            color: Colors.black12,
                            fontFamily: 'poppins'),
                      ),
                      // Text(
                      //   'Elapsed Timer: ${_formatElapsedTime(elapsedTime)}',
                      //   style: TextStyle(fontSize: 24.0),
                      // ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: isTimerRunning ? _stopTimer : _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isTimerRunning ? Colors.red : Colors.green,
                    ),
                    child: Text(isTimerRunning ? 'Stop' : 'Start'),
                  ),

                  // SizedBox(height: 16),
                  // Center(
                  //   child: Text(
                  //     'Elapsed Time: ${elapsedTime}s',
                  //     style:
                  //         TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  SizedBox(height: 16),
                  _buildCaloriesCard(),
                ],
              ),
            ),
          ),
          if (searchResults.isNotEmpty) _buildSearchResultsPopup(),
          // Display error message overlay if any
          if (errorMessage != null) _buildErrorMessage(),
        ],
      ),
    );
  }

  Widget _buildSearchResultsPopup() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        height: 200, // Increased height for better visibility
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // Ensure corners are rounded
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final exercise = searchResults[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    workoutController.text = exercise['exerciseName'];
                    selectedCaloriesPerSecond =
                        (exercise['calories'] as num) / 60.0;
                    searchResults.clear();
                    errorMessage = null; // Clear any previous errors
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        // Wrap this with Expanded to allow text wrapping
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['exerciseName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2, // Allow up to 2 lines
                              overflow:
                                  TextOverflow.ellipsis, // Handle overflow
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${exercise['calories']} calories per minute',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade600), // Icon for indication
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/calories.png', // Replace with your logo path
                  height: 75, // Set the desired height
                  width: 75, // Set the desired width
                ),
                Text(
                  '${currentCaloriesBurned.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 40),
                ),
              ],
            ),
            // SizedBox(height: 10),
            // Text(
            //   'Total Calories Burned: ${totalCaloriesBurned.toStringAsFixed(2)}',
            //   style: TextStyle(fontSize: 18),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;

  TimerPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final double progress = animation.value;
    final double startAngle = -90 * (3.14159265 / 180); // Start at the top
    final double sweepAngle = 2 * 3.14159265 * progress;

    // Draw the circular arc
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return true;
  }
}

///
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WorkoutTrackerPage extends StatefulWidget {
//   @override
//   _WorkoutTrackerPageState createState() => _WorkoutTrackerPageState();
// }
//
// class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
//   final TextEditingController workoutController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   bool isEndurance = true;
//   bool isTimerRunning = false;
//   int elapsedTime = 0; // in seconds
//   double currentCaloriesBurned = 0;
//   double totalCaloriesBurned = 0;
//   Timer? _timer;
//
//   List<dynamic> searchResults = [];
//   double selectedCaloriesPerSecond = 0;
//   bool isSearching = false;
//   String? errorMessage;
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchTotalCalories(); // Fetch total calories when the widget is initialized
//   }
//
//   @override
//   void dispose() {
//     workoutController.dispose();
//     weightController.dispose();
//     _timer?.cancel();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   // Fetch total calories from the API
//   Future<void> _fetchTotalCalories() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('jwtToken');
//
//       if (token == null) {
//         print('No token found!');
//         setState(() {
//           errorMessage = 'Authentication token not found. Please log in.';
//         });
//         return;
//       }
//
//       final jwt = JWT.decode(token);
//       final subject = jwt.payload['sub']; // Extract 'sub' from token
//
//       final url = Uri.parse(
//           'https://fitnessproject-production.up.railway.app/api/workouts/$subject');
//       print('Fetching total calories from: $url');
//
//       final response = await http.get(url, headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       }).timeout(const Duration(seconds: 30));
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         print('Calories response: ${response.body}');
//         final decoded = json.decode(response.body);
//
//         // Extract sessionCalories from the response
//         double sessionCalories = decoded['sessionCalories'] != null
//             ? (decoded['sessionCalories'] as num).toDouble()
//             : 0.0;
//
//         setState(() {
//           totalCaloriesBurned = sessionCalories;
//           errorMessage = null; // Clear any previous errors
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error fetching calories: ${response.statusCode}';
//         });
//         print('Error fetching calories: ${response.statusCode}');
//         print('Error body: ${response.body}');
//       }
//     } on TimeoutException catch (e) {
//       setState(() {
//         errorMessage = 'Request timed out. Please try again.';
//       });
//       print('Error: Request timed out. $e');
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching calories.';
//       });
//       print('Error fetching calories: $e');
//     }
//   }
//
//   // Post session calories to the API
//   Future<void> _postSessionCalories(double sessionCalories) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('jwtToken');
//
//       if (token == null) {
//         print('No token found!');
//         setState(() {
//           errorMessage = 'Authentication token not found. Please log in.';
//         });
//         return;
//       }
//
//       final jwt = JWT.decode(token);
//       final subject = jwt.payload['sub'];
//
//       final url = Uri.parse(
//           'https://fitnessproject-production.up.railway.app/api/workouts/save');
//       print('Posting session calories to: $url');
//
//       // Create a JSON object with the required key
//       final Map<String, dynamic> requestBody = {
//         "sessionCalories": sessionCalories,
//         "userId": subject
//       };
//
//       final response = await http
//           .post(
//             url,
//             headers: {
//               'Authorization': 'Bearer $token',
//               'Content-Type': 'application/json',
//             },
//             body: json.encode(requestBody), // Send as JSON object
//           )
//           .timeout(const Duration(seconds: 30));
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           errorMessage = null; // Clear any previous errors
//         });
//         print('Session calories posted successfully!');
//         // Optionally, parse and use the response if needed
//         final data = json.decode(response.body);
//         print('Response data: $data');
//
//         // Fetch the updated total calories
//         _fetchTotalCalories();
//       } else {
//         setState(() {
//           errorMessage =
//               'Error posting session calories: ${response.statusCode}';
//         });
//         print('Error posting session calories: ${response.statusCode}');
//         print('Error body: ${response.body}');
//       }
//     } on TimeoutException catch (e) {
//       setState(() {
//         errorMessage = 'Request timed out. Please try again.';
//       });
//       print('Error: Request timed out. $e');
//     } catch (e) {
//       setState(() {
//         errorMessage = 'An unexpected error occurred.';
//       });
//       print('Error posting session calories: $e');
//     }
//   }
//
//   Future<void> _searchExercise(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults.clear();
//       });
//       return;
//     }
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('jwtToken');
//
//       if (token == null) {
//         print('No token found!');
//         setState(() {
//           errorMessage = 'Authentication token not found. Please log in.';
//         });
//         return;
//       }
//
//       final url = Uri.parse(
//           'https://fitnessproject-production.up.railway.app/api/search/exercise?exerciseName=$query');
//       print('Sending request to: $url');
//
//       final response = await http.get(url, headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       }).timeout(const Duration(seconds: 30));
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         print('Response data: ${response.body}');
//         final data = json.decode(response.body);
//
//         // Assuming the response is a list of exercises
//         setState(() {
//           searchResults = data; // Ensure data is a list
//           errorMessage = null; // Clear any previous errors
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error fetching exercises: ${response.statusCode}';
//         });
//         print('Error: Received status code ${response.statusCode}');
//         print('Error body: ${response.body}');
//       }
//     } on TimeoutException catch (e) {
//       setState(() {
//         errorMessage = 'Request timed out. Please try again.';
//       });
//       print('Error: Request timed out. $e');
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching exercises.';
//       });
//       print('Error fetching exercises: $e');
//     }
//   }
//
//   // Debounce function for search
//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _searchExercise(query);
//     });
//   }
//
//   void _startTimer() {
//     if (!isEndurance && weightController.text.isEmpty) {
//       setState(() {
//         errorMessage = 'Please enter a valid weight before starting the timer.';
//       });
//       print('Please enter a valid weight before starting the timer.');
//       return;
//     }
//
//     _timer?.cancel();
//     setState(() {
//       isTimerRunning = true;
//       elapsedTime = 0;
//       currentCaloriesBurned = 0;
//       errorMessage = null; // Clear any previous errors
//     });
//
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         elapsedTime += 1;
//         _calculateCaloriesBurned();
//       });
//     });
//   }
//
//   void _stopTimer() {
//     _timer?.cancel();
//     setState(() {
//       isTimerRunning = false;
//     });
//
//     // Post the session calories to the backend
//     _postSessionCalories(currentCaloriesBurned);
//   }
//
//   void _calculateCaloriesBurned() {
//     double weight = 0.0;
//
//     if (!isEndurance) {
//       if (weightController.text.isEmpty) {
//         print('Please enter weight for lifting exercises.');
//         setState(() {
//           errorMessage = 'Please enter weight for lifting exercises.';
//         });
//         return;
//       }
//
//       try {
//         weight = double.parse(weightController.text);
//       } catch (e) {
//         print('Invalid weight entered: $e');
//         setState(() {
//           errorMessage = 'Invalid weight entered.';
//         });
//         return;
//       }
//
//       // For lifting, the formula is (METs * weight in kg * duration in hours)
//       // Assume METs for weight lifting is 3.0
//       currentCaloriesBurned += (3.0 * weight * (1 / 3600));
//     } else {
//       // For endurance, the formula is (METs * weight in kg * duration in hours)
//       // Assume METs for running is 7.0
//       currentCaloriesBurned += (7.0 * weight * (1 / 3600));
//     }
//   }
//
//   // Toggle between endurance and weightlifting
//   void _toggleExerciseType() {
//     setState(() {
//       isEndurance = !isEndurance;
//       workoutController.clear(); // Clear the workout name when toggling
//       weightController.clear(); // Clear the weight input when toggling
//       elapsedTime = 0; // Reset elapsed time when toggling
//       currentCaloriesBurned = 0; // Reset calories burned
//       isTimerRunning = false; // Stop the timer
//       _timer?.cancel();
//     });
//   }
//
//   // Build the UI for the WorkoutTrackerPage
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Workout Tracker'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: workoutController,
//               decoration: InputDecoration(
//                 labelText: 'Workout Name',
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   errorMessage = null; // Clear error message on input
//                 });
//               },
//             ),
//             SizedBox(height: 8.0),
//             TextField(
//               controller: weightController,
//               decoration: InputDecoration(
//                 labelText: 'Weight (kg)',
//               ),
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   errorMessage = null; // Clear error message on input
//                 });
//               },
//             ),
//             SizedBox(height: 8.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: _toggleExerciseType,
//                   child: Text(isEndurance
//                       ? 'Switch to Weightlifting'
//                       : 'Switch to Endurance'),
//                 ),
//                 ElevatedButton(
//                   onPressed: isTimerRunning ? _stopTimer : _startTimer,
//                   child: Text(isTimerRunning ? 'Stop Timer' : 'Start Timer'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Elapsed Time: ${_formatElapsedTime(elapsedTime)}',
//               style: TextStyle(fontSize: 24.0),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Calories Burned: ${currentCaloriesBurned.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 24.0),
//             ),
//             SizedBox(height: 16.0),
//             if (errorMessage != null) ...[
//               Text(
//                 errorMessage!,
//                 style: TextStyle(color: Colors.red),
//               ),
//             ],
//             SizedBox(height: 16.0),
//             TextField(
//               onChanged: _onSearchChanged,
//               decoration: InputDecoration(
//                 labelText: 'Search Exercise',
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: searchResults.length,
//                 itemBuilder: (context, index) {
//                   final exercise = searchResults[index];
//                   return ListTile(
//                     title: Text(exercise['name'] ?? 'Unknown'),
//                     onTap: () {
//                       setState(() {
//                         selectedCaloriesPerSecond =
//                             exercise['caloriesPerSecond']?.toDouble() ?? 0;
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatElapsedTime(int seconds) {
//     final duration = Duration(seconds: seconds);
//     return '${duration.inHours.remainder(60).toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
//   }
// }
