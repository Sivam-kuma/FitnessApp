import 'dart:async'; // Import Timer

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';
import 'entry.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // @override
  // void initState() {
  //   super.initState();
  //   _startSplashScreen();
  //
  //   // Initialize AnimationController
  //   _controller = AnimationController(
  //     duration: const Duration(milliseconds: 500), // Animation duration
  //     vsync: this,
  //   )..repeat(reverse: true); // Repeat animation in reverse
  //
  //   // Define animation for vertical position (jumping effect)
  //   _animation = Tween<double>(begin: 0.0, end: -100.0).animate(CurvedAnimation(
  //     parent: _controller,
  //     curve: Curves.bounceOut, // Use bounceOut for a fast start and slow end
  //   ));
  // }
  ///
  @override
  void initState() {
    super.initState();
    _startSplashScreen();

    // Initialize AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Faster animation
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse(); // Reverse the animation after going up
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward(); // Restart after hitting ground
        }
      });

    // Define animation with custom bounce curves
    _animation = Tween<double>(begin: 0.0, end: -100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, // Smooth upward movement//easeOut
        reverseCurve:
            Curves.easeOut, // Fast downward snap on reverse//elasticIn
      ),
    );

    _controller.forward(); // Start the animation
  }

  // @override
  // void dispose() {
  //   _controller.dispose(); // Dispose controller to prevent memory leaks
  //   super.dispose();
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: AnimatedBuilder(
  //         animation: _animation,
  //         builder: (context, child) {
  //           return Transform.translate(
  //             offset: Offset(0, _animation.value), // Apply the jump effect
  //             child: Image.asset(
  //               'assets/images/fitness_logo.png',
  //               height: 150, // Adjust as needed
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _startSplashScreen() {
    // Show the splash screen for 5 seconds
    Timer(Duration(seconds: 5), () {
      _checkTokenAndNavigate();
    });
  }

  Future<void> _checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null && !JwtDecoder.isExpired(token)) {
      // Token is valid, navigate to Home screen
      Get.offAll(() => HomeScreen());
    } else {
      // Token is missing or expired, navigate to Login screen
      if (token == null || token != null && JwtDecoder.isExpired(token)) {
        prefs.remove('jwtToken'); // Clear expired token
      }
      Get.offAll(() => LoginPage());
    }
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Push elements to top and bottom
        children: [
          // Centered logo with animation and welcome text
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0, _animation.value), // Apply the jumping effect
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/splash_screen.png', // Replace with your logo path
                      height: 150, // Set the height of the logo
                    ),
                  ),
                  SizedBox(height: 20), // Space between logo and text
                  Text(
                    'Welcome to keepFit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal, // Change to your theme color
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your journey to be healthier starts here.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom image with 200x200 size
          Text(
            'Developed By',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 20.0), // Optional padding from the bottom
            child: Image.asset(
              'assets/symro-1.png', // Replace with your logo path
              height: 50, // Set the desired height
              width: 50, // Set the desired width
            ),
          ),
        ],
      ),
    );
  }
}
