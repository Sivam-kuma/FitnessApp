import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0.0; // Rating value that updates dynamically
  TextEditingController _suggestionController = TextEditingController();
  bool _isLoading = false; // Show loading during API call

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard opens
      appBar: AppBar(
        backgroundColor: const Color(0xff89C0FF),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black45),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Feedback',
          style: TextStyle(fontSize: 24, color: Colors.black45),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Rate Your Experience",
                style: TextStyle(fontSize: 18, color: Colors.black45),
              ),
              const SizedBox(height: 10),
              _buildStarRating(),
              const SizedBox(height: 100),
              const Text(
                "Enter Your Suggestions",
                style: TextStyle(fontSize: 18, color: Colors.black45),
              ),
              const SizedBox(height: 10),
              _buildSuggestionInput(),
              const SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff89C0FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for star rating
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
          child: Icon(
            _rating >= index + 1
                ? Icons.star
                : _rating >= index + 0.5
                    ? Icons.star_half
                    : Icons.star_border,
            size: 50,
            color: Colors.amber,
          ),
        );
      }),
    );
  }

  // Widget for suggestion input with a 250-character limit
  Widget _buildSuggestionInput() {
    return TextField(
      controller: _suggestionController,
      maxLength: 250,
      maxLines: 4,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your suggestions',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: 'Poppins',
          fontSize: 16.0,
        ),
      ),
    );
  }

  // Function to submit feedback
  Future<void> _submitFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
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

      var url = Uri.parse(
          'https://fitnessproject-production.up.railway.app/api/feedback/save');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "star": _rating.toInt(),
          "userId": subject,
          "feedback": _suggestionController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
