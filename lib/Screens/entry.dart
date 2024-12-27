// import 'package:flutter/material.dart';
//
// import 'Caloriestracer.dart';
// import 'Home.dart';
// import 'Profile_edit.dart';
// import 'TutorialLists.dart';
// import 'feedback.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 2; // Home is the initial screen.
//
//   // List of pages corresponding to each tab.
//   final List<Widget> _pages = [
//     ProfilePage(),
//     CalorieTrackerPage(),
//     WorkoutPage(), // Home screen at index 2.
//     WorkoutListScreen(),
//     FeedbackPage(),
//   ];
//
//   // Update the current index when a tab is tapped.
//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex], // Display the selected page.
//       bottomNavigationBar: Stack(
//         clipBehavior: Clip.none, // Allow overflow for floating button.
//         children: [
//           CustomPaint(
//             size: Size(MediaQuery.of(context).size.width, 49),
//             painter: CurvedNavigationBarPainter(), // Custom curve painter.
//           ),
//           Positioned(
//             bottom: 15, // Adjust the position to align with the curve.
//             left: MediaQuery.of(context).size.width / 2 - 22, // Centered.
//             child: GestureDetector(
//               onTap: () => _onTabTapped(2), // Navigate to Home.
//               child: Container(
//                 width: 45,
//                 height: 45,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       spreadRadius: 5,
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.home,
//                   size: 20,
//                   color: Color(0xff89C0FF),
//                 ),
//               ),
//             ),
//           ),
//           // Bottom Navigation Bar Items
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: BottomNavigationBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0, // Transparent to show curve.
//               currentIndex: _currentIndex,
//               onTap: _onTabTapped,
//               type: BottomNavigationBarType.fixed,
//               selectedItemColor: Colors.green,
//               unselectedItemColor: Colors.white.withOpacity(0.6),
//               showSelectedLabels: true,
//               showUnselectedLabels: false,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person),
//                   label: 'Profile',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.track_changes),
//                   label: 'Tracker',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: SizedBox.shrink(), // Placeholder for floating button.
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.list),
//                   label: 'Tutorials',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.feedback),
//                   label: 'Feedback',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Custom Painter for Curved Navigation Bar Background
// class CurvedNavigationBarPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(0xff89C0FF) // Navigation bar background color.
//       ..style = PaintingStyle.fill;
//
//     final path = Path();
//
//     // Start from the bottom-left corner.
//     path.moveTo(0, 0);
//     path.lineTo(
//         size.width * 0.41, 0); // Straight line up to the left of the home icon.
//
//     // Create a circular arc over the home icon.
//     path.quadraticBezierTo(
//       size.width * 0.5, -30, // Control point directly above (circular shape).
//       size.width * 0.60, 0, // Back to the original height.
//     );
//
//     path.lineTo(size.width, 0); // Continue to the right edge.
//     path.lineTo(size.width, size.height); // Bottom-right corner.
//     path.lineTo(0, size.height); // Bottom-left corner.
//     path.close(); // Close the path.
//
//     // Draw the path on the canvas.
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
///
import 'package:flutter/material.dart';

import 'Caloriestracer.dart';
import 'Home.dart';
import 'Profile_edit.dart';
import 'TutorialLists.dart';
import 'feedback.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Initial index for Home.
  late AnimationController _animationController;
  late Animation<double> _curveAnimation;

  final List<Widget> _pages = [
    ProfilePage(),
    CalorieTrackerPage(),
    WorkoutPage(), // Home screen at index 2.
    WorkoutListScreen(),
    FeedbackPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _curveAnimation = Tween<double>(
            begin: _currentIndex.toDouble(), end: _currentIndex.toDouble())
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Animate curve movement.
    _curveAnimation =
        Tween<double>(begin: _currentIndex.toDouble(), end: index.toDouble())
            .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page.
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // Curve Painter for Animated Background
          AnimatedBuilder(
            animation: _curveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 60),
                painter: CurvedNavigationBarPainter(
                    _curveAnimation.value), // Pass the curve position here.
              );
            },
          ),
          // Bottom Navigation Bar Icons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.white.withOpacity(0.6),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: List.generate(5, (index) {
                return BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin:
                        EdgeInsets.only(bottom: index == _currentIndex ? 8 : 0),
                    child: Icon(
                      _getIcon(index),
                      size: index == _currentIndex
                          ? 35
                          : 25, // Elevate selected icon.
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                  label: _getLabel(index),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.track_changes;
      case 2:
        return Icons.home;
      case 3:
        return Icons.list;
      case 4:
        return Icons.feedback;
      default:
        return Icons.help;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Profile';
      case 1:
        return 'Tracker';
      case 2:
        return ''; // Home button.
      case 3:
        return 'Tutorials';
      case 4:
        return 'Feedback';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Custom Painter for Animated Curved Background
class CurvedNavigationBarPainter extends CustomPainter {
  final double curvePosition;

  CurvedNavigationBarPainter(this.curvePosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xff89C0FF)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start at the bottom-left corner.
    path.moveTo(0, 0);
    path.lineTo(size.width * (curvePosition / 5) - 0, 0);

    // Create the curve over the selected icon.
    path.quadraticBezierTo(
      size.width * (curvePosition / 5) + 30, -30, // Control point.
      size.width * (curvePosition / 5) + 60, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint if the curve position changes.
    return oldDelegate is CurvedNavigationBarPainter &&
        oldDelegate.curvePosition != curvePosition;
  }
}
