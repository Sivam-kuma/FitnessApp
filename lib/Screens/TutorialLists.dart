// import 'package:flutter/material.dart';
//
// class WorkoutListScreen extends StatefulWidget {
//   @override
//   _WorkoutListScreenState createState() => _WorkoutListScreenState();
// }
//
// class _WorkoutListScreenState extends State<WorkoutListScreen> {
//   // Sample list of workouts
//   List<String> workouts = [
//     "Chest press",
//     "Shoulder press",
//     "Leg press",
//     "Triceps",
//     "Biceps",
//     "Bicepss", // Adjust any typos if needed
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Curved background with a fixed height
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: CurvedBackground(),
//           ),
//           // AppBar placed on top of the curved background
//           Positioned(
//             top: 50, // Adjust this for proper vertical alignment
//             left: 16,
//             right: 16,
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               // leading: IconButton(
//               //   icon: Icon(Icons.arrow_back, color: Colors.black),
//               //   onPressed: () => Navigator.pop(context),
//               // ),
//               title: Text(
//                 'Exercises',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black45,
//                 ),
//               ),
//               centerTitle: true,
//             ),
//           ),
//           // Main content below the curved background and app bar
//           Padding(
//             padding: const EdgeInsets.only(top: 180.0), // Offset for content
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Recommended',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         'Equipment Advance',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: ListView.separated(
//                     itemCount: workouts.length,
//                     separatorBuilder: (context, index) => Divider(
//                       color: Colors.grey[300],
//                       thickness: 1,
//                     ),
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         leading: Icon(
//                           Icons.fitness_center,
//                           color: Colors.orange,
//                           size: 30,
//                         ),
//                         title: Text(
//                           workouts[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         trailing: Icon(
//                           Icons.arrow_forward_ios,
//                           size: 16,
//                           color: Colors.grey,
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WorkoutDetailScreen(
//                                 workout: workouts[index],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
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
// // Custom curved background widget
// class CurvedBackground extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: CustomBackgroundClipper(),
//       child: Container(
//         height: 180, // Fixed height for static background
//         color: Color(0xFF83BBFB),
//       ),
//     );
//   }
// }
//
// // Custom clipper for the curved background
// class CustomBackgroundClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height,
//       size.width,
//       size.height - 20,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
//
// // Placeholder for the workout detail screen
// class WorkoutDetailScreen extends StatelessWidget {
//   final String workout;
//
//   WorkoutDetailScreen({required this.workout});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(workout),
//       ),
//       body: Center(
//         child: Text(
//           '$workout Details',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class WorkoutListScreen extends StatefulWidget {
  @override
  _WorkoutListScreenState createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  List<String> workouts = [
    "Chest press",
    "Shoulder press",
    "Leg press",
    "Triceps",
    "Biceps",
    "Back",
    "Abs",
    // add more as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CurvedBackground(),
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
              ),
              centerTitle: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 180.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Equipment Advance',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: workouts.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.fitness_center,
                          color: Colors.orange,
                          size: 30,
                        ),
                        title: Text(
                          workouts[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailScreen(
                                workout: workouts[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom curved background widget
class CurvedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomBackgroundClipper(),
      child: Container(
        height: 180,
        color: Color(0xFF83BBFB),
      ),
    );
  }
}

// Custom clipper for the curved background
class CustomBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// WorkoutDetailScreen with video player
class WorkoutDetailScreen extends StatefulWidget {
  final String workout;

  WorkoutDetailScreen({required this.workout});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _exerciseDescription;
  String? _videoUrl;
  final String _defaultVideoUrl =
      "https://your-default-video-url.com/video.mp4";

  @override
  void initState() {
    super.initState();
    _fetchWorkoutDetails(widget.workout);
  }

  Future<void> _fetchWorkoutDetails(String workout) async {
    final url =
        'https://remainingsfitness-production.up.railway.app/api/app/getList/$workout';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _exerciseDescription = data.isNotEmpty
              ? data[0]['exerciseDescription']
              : "Wait, we will upload soon!";
          _videoUrl =
              data.isNotEmpty ? data[0]['equipmentType'] : _defaultVideoUrl;
          _controller = VideoPlayerController.network(_videoUrl!)
            ..initialize().then((_) {
              setState(() {
                _isLoading = false;
                _controller.play();
              });
            });
        });
      } else {
        _showErrorMessage('Failed to load workout details');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _exerciseDescription = message;
      _videoUrl = _defaultVideoUrl;
      _controller = VideoPlayerController.network(_videoUrl!)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _controller.play();
          });
        });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.workout),
      // ),
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black45),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.workout,
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_exerciseDescription != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _exerciseDescription!,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                if (_videoUrl != null && _controller.value.isInitialized)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
