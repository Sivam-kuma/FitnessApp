import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fitness/Screens/workOutplan.dart';
import 'package:fitness/Screens/workoutmode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';
import 'appbar.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool isBurnedSelected = true;
  final AudioPlayer audioPlayer = AudioPlayer();
  double totalCaloriesBurned = 0;
  double CaloriesConsumeds = 0;
  double proteinConsumed = 0;
  double carbohydrateConsumed = 0;
  String? errorMessage;
  double? fat = 0;
  double? age;
  double? weight;
  double? height;
  double? bmi;
  bool isLoading = true;
  String bmiCategory = "Loading...";
  String todayExercise = "Loading...";
  double totalCaloriesConsumed = 1.0;
  String userCategory = "Loading...";
  double proteinIntake = 1.0;
  double carbohydrateIntake = 1.0;
  double fatIntake = 0.0;
  double caloriesBurned = 1.0;
  double caloriesConsumed = 1.0;
  final FocusNode _focusNode = FocusNode();
  Future<void> _fetchUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');
      if (token == null) {
        print('No token found!');
        setState(() {
          bmiCategory = 'Authentication token not found. Please log in.';
        });
        return;
      }
      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub'];
      final url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/userdetails/getAll/$subject');
      print('Fetching user details from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        setState(() {
          // Extract user data
          age = (decoded['age'] as num?)?.toDouble() ?? 0.0;
          weight = (decoded['weight'] as num?)?.toDouble() ?? 0.0;
          height = (decoded['height'] as num?)?.toDouble() ?? 0.0;
          userCategory = decoded['categories'] ?? 'Stay Fit';
          isLoading = false; // Default to "Stay Fit"
        });

        // Calculate BMI and suggest plan based on user data
        _calculateBMIAndDecidePlan(userCategory);
      } else {
        print('Error: ${response.body}');
        setState(() {
          bmiCategory = 'Error fetching user details: ${response.statusCode}';
          isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      setState(() {
        bmiCategory = 'Request timed out. Please try again.';
      });
      print('Error: Request timed out. $e');
    } catch (e) {
      setState(() {
        bmiCategory = 'Error fetching user details.';
      });
      print('Error: $e');
    }
  }

  /// loading the exercise name of today
  Future<void> _loadTodayExercise() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? exercise = prefs.getString('todayExercise');
    setState(() {
      todayExercise = exercise ?? "No Exercise"; // Default if not found
    });
  }

  // Function to calculate BMI and suggest a plan
  void _calculateBMIAndDecidePlan(String userCategory) {
    if (weight != null && height != null && userCategory.isNotEmpty) {
      double feet = height!.floorToDouble();
      double inches = (height! - feet) * 10;
      double heightInMeters = (feet * 0.3048) + (inches * 0.0254);

      if (heightInMeters > 0) {
        bmi = weight! / (heightInMeters * heightInMeters);
        print('BMI: $bmi');

        // Determine BMI category
        if (bmi! < 18.5) {
          bmiCategory = 'Underweight';
        } else if (bmi! >= 18.5 && bmi! < 24.9) {
          bmiCategory = 'Normal weight';
        } else if (bmi! >= 25 && bmi! < 29.9) {
          bmiCategory = 'Overweight';
        } else {
          bmiCategory = 'Obesity';
        }

        print('BMI Category: $bmiCategory');

        // Suggest consumption and burn plan
        _suggestConsumptionAndBurnPlan(bmiCategory, userCategory);
      } else {
        print('Invalid height value.');
      }
    } else {
      print('Invalid weight, height, or user category.');
    }
  }

  // Function to suggest consumption and burn plan
  void _suggestConsumptionAndBurnPlan(String bmiCategory, String userCategory) {
    caloriesConsumed = 2000;
    proteinIntake = 0.8 * weight!;
    carbohydrateIntake = 3.0 * weight!;
    caloriesBurned = 2000;

    // Adjust plans based on user’s goal and BMI

    if (userCategory == "Lose Weight") {
      caloriesConsumed -= 500;
      proteinIntake = 1.2 * weight!;
      carbohydrateIntake = 2.0 * weight!;
      caloriesBurned += 500;
    } else if (userCategory == "Build Muscle") {
      caloriesConsumed += 300;
      proteinIntake = 1.6 * weight!;
      carbohydrateIntake = 4.0 * weight!;
      caloriesBurned += 400;
    } else if (userCategory == "Stay Fit") {
      caloriesConsumed = caloriesConsumed;
      proteinIntake = 1.0 * weight!;
      carbohydrateIntake = 3.0 * weight!;
      caloriesBurned = caloriesBurned;
    }

    if (bmiCategory == 'Underweight') {
      caloriesConsumed += 500;
      proteinIntake = 1.5 * weight!;
      carbohydrateIntake = 2.0 * weight!;
      caloriesBurned += 100;
    } else if (bmiCategory == 'Obesity') {
      caloriesConsumed -= 500;
      carbohydrateIntake = 1.5 * weight!;
      proteinIntake = 2.0 * weight!;
      caloriesBurned += 300;
    } else if (bmiCategory == 'Normal weight') {
      caloriesConsumed -= 0;
      carbohydrateIntake = 1.5 * weight!;
      proteinIntake = 2.0 * weight!;
      caloriesBurned += 0;
    } else {
      caloriesConsumed = 2000;
      proteinIntake = 0.8 * weight!;
      carbohydrateIntake = 3.0 * weight!;
      caloriesBurned = 2000;
    }
    print(
        'Calories to Consume: $caloriesConsumed, Protein: ${proteinIntake.toStringAsFixed(1)}g, Carbohydrates: ${carbohydrateIntake.toStringAsFixed(1)}g, Calories to Burn: $caloriesBurned');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     _refreshData(); // Call refresh when the screen gains focus
    //   }
    // });
    _fetchFoodDetails();
    _fetchUserDetails();
    _fetchTotalCalories();
    _loadTodayExercise();
    WidgetsBinding.instance.addObserver(this); // Initial fetch
  }

  @override
  void dispose() {
    _tabController.dispose();
    audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // Refresh data when returning to the page
  //     _refreshData();
  //   }
  // }

  late String? token;
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwtToken');
  }

  void _refreshData() async {
    await _loadToken();
    if (token != null) {
      _fetchFoodDetails();
      // _fetchTotalCalories();
      //
      // _fetchUserDetails();
    } else {
      setState(() {
        errorMessage = 'Authentication token not found. Please log in.';
      });
    }
  }

  Future<void> _fetchFoodDetails() async {
    try {
      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      if (token == null) {
        print('No token found!');
        setState(() {
          errorMessage = 'Authentication token not found. Please log in.';
        });
        return;
      }

      // Decode the JWT token and extract the subject (user ID)
      final jwt = JWT.decode(token);
      final subject = jwt.payload['sub']; // Extract 'sub' from token

      final url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/Food/get/$subject');
      print('Fetching food details from: $url');

      // Make the API request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Extract carbohydrate, fat, and protein values
        double carbohydrates = decoded['carbohydrates'] != null
            ? (decoded['carbohydrates'] as num).toDouble()
            : 0.0;
        double fats =
            decoded['fat'] != null ? (decoded['fat'] as num).toDouble() : 0.0;
        double proteins = decoded['protein'] != null
            ? (decoded['protein'] as num).toDouble()
            : 0.0;

        setState(() {
          carbohydrateConsumed = carbohydrates;
          fat = fats;
          proteinConsumed = proteins;
          CaloriesConsumeds = (4 * carbohydrates) + (4 * proteins) + (6 * fats);
          errorMessage = null; // Clear any previous errors
        });

        print('Carbohydrates: $carbohydrates, Fat: $fats, Protein: $proteins');
      } else {
        setState(() {
          errorMessage = 'Error fetching food details: ${response.statusCode}';
        });
        print('Error fetching food details: ${response.body}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
      });
      print('Error: Request timed out. $e');
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching food details.';
      });
      print('Error: $e');
    }
  }

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

  ///

  void playSound() async {
    await audioPlayer.play(UrlSource('https://example.com/my-audio.wav'));
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          WorkoutTrackerPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var opacityTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut));
        var blurTween = Tween<double>(begin: 0.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeInOut));

        return Stack(
          children: [
            FadeTransition(
              opacity: animation.drive(opacityTween),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: animation.drive(blurTween).value,
                    sigmaY: animation.drive(blurTween).value),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            FadeTransition(
              opacity: animation.drive(opacityTween),
              child: Image.asset(
                'assets/smoke (2).png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            FadeTransition(
              opacity: animation.drive(opacityTween),
              child: child,
            ),
          ],
        );
      },
      transitionDuration: Duration(seconds: 3),
    );
  }

  Future<void> onWorkoutModePressed() async {
    playSound();
    await Navigator.of(context).push(_createRoute());
    _fetchTotalCalories(); // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).size.height * 0.1;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight), // Dynamic height
        child: Container(
          color: Color(0xff89C0FF), // Set the background color
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Let the column take minimum height needed
            children: [
              CustomAppBar(), // Existing CustomAppBar
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/BMI.png',
                          height: 30,
                          width: 30,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isLoading ? "Loading..." : bmiCategory,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/goal.png',
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(width: 2),
                        TextButton(
                          onPressed: () {},
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isLoading ? "Loading..." : userCategory,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// position of card
              buildCard(context),

              ///
              Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isBurnedSelected = true;
                              });
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: isBurnedSelected
                                    ? Color(0xff89C0FF)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8)),
                              ),
                              child: Center(
                                child: Text(
                                  "Burned",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: isBurnedSelected
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isBurnedSelected = false;
                              });
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: !isBurnedSelected
                                    ? Color(0xff89C0FF)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8)),
                              ),
                              child: Center(
                                child: Text(
                                  "Consume",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: !isBurnedSelected
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    if (isBurnedSelected)
                      ElevatedButton(
                        onPressed: onWorkoutModePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('WorkOut Mode',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    SizedBox(height: 40),
                    if (isBurnedSelected)
                      CircularProgressIndicatorWithText2(
                        title: 'Calories Burned',
                        currentValue: totalCaloriesBurned,
                        maxValue: caloriesBurned,
                        progressColor: Colors.greenAccent,
                      ),
                    if (!isBurnedSelected) ...[
                      Focus(
                        focusNode: _focusNode,
                        child: CircularProgressIndicatorWithText2(
                          title: 'Calories',
                          currentValue: CaloriesConsumeds,
                          maxValue: caloriesConsumed,
                          progressColor: Colors.greenAccent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircularProgressIndicatorWithText(
                              title: 'Protein',
                              currentValue: proteinConsumed,
                              maxValue: proteinIntake,
                              progressColor: Colors.greenAccent,
                            ),
                            CircularProgressIndicatorWithText(
                              title: 'Carbohydrates',
                              currentValue: carbohydrateConsumed,
                              maxValue: carbohydrateIntake,
                              progressColor: Colors.greenAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(2, 6),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(WorkoutPlanScreen());
                  },
                  label: Text(
                    'WorkOut Plan',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// exercise card widget
  Widget buildCard(BuildContext context) {
    // Use MediaQuery for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04; // 4% padding based on screen width
    final margin = screenWidth * 0.05; // 5% margin based on screen width

    return Stack(
      alignment: Alignment.topCenter, // Center align the outer container
      children: [
        // Outer white card container
        // Container(
        //   padding: EdgeInsets.all(padding),
        //   margin: EdgeInsets.all(margin),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.2),
        //         blurRadius: 10,
        //         offset: Offset(0, 5),
        //       ),
        //     ],
        //   ),
        // ),
        // Positioned image overlapping the outer container
        // Positioned(
        //   right: 30, // Shift the image to the left
        //   bottom: 50, // Shift the image upwards
        //   child: Container(
        //     width: 100, // Adjust the image width as needed
        //     child: Image.asset(
        //       'assets/card.png', // Replace with your asset path
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        // Text Section
        Container(
          padding: EdgeInsets.all(padding), // Keep text padding
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use FittedBox for responsive text
              Center(
                child: FittedBox(
                  child: Text(
                    'Be Prepared for',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        todayExercise,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      child: Text(
                        'Workout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  "Don't count the days, make the days count",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -10, // Shift the image to the left
          bottom: 30, // Shift the image upwards
          child: Container(
            width: 101, // Adjust the image width as needed
            child: Image.asset(
              'assets/card.png', // Replace with your asset path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  ///

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff89C0FF),
            ),
            child: Row(
              children: [
                Icon(Icons.login, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'Navigation Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              // Remove saved token and other user-related data
              await prefs.remove('jwtToken'); // Remove JWT token
              await prefs.remove('isLoggedIn'); // Remove login status
              await prefs.remove('username'); // Remove username (if needed)

              Navigator.pop(context); // Close the drawer
              Get.offAll(() => LoginPage()); // Navigate to login page
            },
          ),
          ListTile(
            leading:
                Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Get.to(); // Replace with your Settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications,
                color: Theme.of(context).iconTheme.color),
            title: Text(
              'Notifications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Get.to(NotificationsPage()); // Replace with your Notifications page
            },
          ),
          // ListTile(
          //   leading:
          //       Icon(Icons.feedback, color: Theme.of(context).iconTheme.color),
          //   title: Text(
          //     'FeedBack',
          //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //           color: Theme.of(context)
          //               .textTheme
          //               .bodyLarge
          //               ?.color
          //               ?.withOpacity(0.7),
          //         ),
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Get.to(FeedbackPage());
          //   },
          // ),
        ],
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

class CircularProgressIndicatorWithText2 extends StatefulWidget {
  final String title;
  final double currentValue;
  final double maxValue;

  CircularProgressIndicatorWithText2({
    required this.title,
    required this.currentValue,
    required this.maxValue,
    required MaterialAccentColor progressColor,
  });

  @override
  _CircularProgressIndicatorWithText2State createState() =>
      _CircularProgressIndicatorWithText2State();
}

class _CircularProgressIndicatorWithText2State
    extends State<CircularProgressIndicatorWithText2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.5) {
      return Colors.red;
    } else if (percentage < 0.75) {
      return Colors.yellow;
    } else {
      return Colors.green; // Default color for values above 75%
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.currentValue / widget.maxValue),
          duration: Duration(seconds: 2),
          builder: (context, value, child) {
            final percentage = value;
            final progressColor = _getProgressColor(percentage);
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 6,
                    color: progressColor,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(color: Color(0xFF0CF95B), fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${(percentage * widget.maxValue).toInt()} kJ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        SizedBox(height: 10),
        Text(
          '${widget.maxValue.toInt()} kJ',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class CircularProgressIndicatorWithText extends StatefulWidget {
  final String title;
  final double currentValue;
  final double maxValue;

  CircularProgressIndicatorWithText({
    required this.title,
    required this.currentValue,
    required this.maxValue,
    required MaterialAccentColor progressColor,
  });

  @override
  _CircularProgressIndicatorWithTextState createState() =>
      _CircularProgressIndicatorWithTextState();
}

class _CircularProgressIndicatorWithTextState
    extends State<CircularProgressIndicatorWithText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.5) {
      return Colors.red;
    } else if (percentage < 0.75) {
      return Colors.yellow;
    } else {
      return Colors.green; // Default color for values above 75%
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.currentValue / widget.maxValue),
          duration: Duration(seconds: 4),
          builder: (context, value, child) {
            final percentage = value;
            final progressColor = _getProgressColor(percentage);
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 5,
                    color: progressColor,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(color: Color(0xFF0CF95B), fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${(percentage * widget.maxValue).toInt()} gram',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        SizedBox(height: 10),
        Text(
          '${widget.maxValue.toInt()} kJ',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
