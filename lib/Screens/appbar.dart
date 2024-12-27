// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
//   @override
//   _CustomAppBarState createState() => _CustomAppBarState();
//
//   @override
//   Size get preferredSize => const Size.fromHeight(0.0);
// }
//
// class _CustomAppBarState extends State<CustomAppBar> {
//   bool isDarkMode = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       // leading: Builder(
//       //   builder: (context) {
//       //     // return IconButton(
//       //     //   icon: Icon(
//       //     //     Icons.menu,
//       //     //     color: Theme.of(context).colorScheme.primary,
//       //     //   ),
//       //     //   onPressed: () {
//       //     //     Scaffold.of(context).openDrawer(); // Open the navigation drawer
//       //     //   },
//       //     // );
//       //   },
//       // ),
//       actions: [
//         IconButton(
//           icon: Icon(
//             isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
//             color: isDarkMode ? Colors.white : Colors.orange,
//           ),
//           onPressed: () {
//             setState(() {
//               isDarkMode = !isDarkMode;
//               Get.changeTheme(
//                 isDarkMode ? ThemeData.dark() : ThemeData.light(),
//               );
//             });
//           },
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 11.0, left: 10.0),
//           child: Icon(Icons.person, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }
//
// class CustomAppBarScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(),
//       // drawer: _buildDrawer(context),
//       body: Center(
//         child: Text("Your Content Here"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(56.0); // Set a preferred height for the AppBar
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isDarkMode = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadUsername(); // Load the theme at the start
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = (prefs.getBool('isDarkMode') ?? false);
      Get.changeTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());
    });
  }

  Future<void> _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      Get.changeTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());
      prefs.setBool('isDarkMode', isDarkMode); // Save the theme preference
    });
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // Notifications Icon
        // IconButton(
        //   icon: Icon(
        //     Icons.notifications,
        //     color: Colors.grey,
        //   ),
        //   onPressed: () {
        //     // Handle notification click
        //   },
        // ),
        // Theme Switcher
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
            color: isDarkMode ? Colors.white : Colors.orange,
          ),
          onPressed: _toggleTheme,
        ),
        // Logout Icon
        // IconButton(
        //   icon: Icon(
        //     Icons.logout,
        //     color: Colors.red,
        //   ),
        //   onPressed: () async {
        //     // Clear saved token from SharedPreferences
        //     SharedPreferences prefs = await SharedPreferences.getInstance();
        //     await prefs.remove(
        //         'token'); // Assuming 'token' is the key for your saved token
        //
        //     // Navigate back to the login page (replace with your login page route)
        //     Get.offAllNamed('/login'); // Use GetX for navigation
        //   },
        // ),
        // User Profile Icon
        Padding(
          padding: const EdgeInsets.only(right: 11.0, left: 10.0),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.lightBlue,
            child: _username.isNotEmpty
                ? Text(
                    _username[0].toUpperCase(), // Display first letter
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  )
                : Icon(
                    Icons.person, // Profile icon
                    color: Colors.white,
                    size: 10, // Adjust size as needed
                  ),
          ),
          // SizedBox(width: 10),
          // // Display the username text
          // Text(
          //   _username,
          //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // ),
        ),
      ],
    );
  }
}

class CustomAppBarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text("Your Content Here"),
      ),
    );
  }
}
