import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}
class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  bool isSaving = false;

  Future<void> _savePost() async {
    setState(() {
      isSaving = true;
    });

    final Map<String, dynamic> newPost = {
      'title': titleController.text,
      'body': bodyController.text,
      'userId': 1,
    };

    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPost),
    );

    setState(() {
      isSaving = false;
    });

    if (response.statusCode == 201) {

      Navigator.pop(context);
    } else {

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save the post. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
                ),
              ),
            ),
            SizedBox(height: 25),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Body',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: isSaving ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyanAccent,
                  onPrimary: Colors.black,
                ),
                child: isSaving
                    ? CircularProgressIndicator()
                    : Text('Save'),
              ),
            ),


          ],
        ),
      ),
    );
  }
}