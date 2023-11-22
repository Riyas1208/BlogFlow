import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/blogmodel.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;

  PostDetailsScreen({required this.post});

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  List<Comment> comments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchComments(widget.post.id);
  }

  Future<void> _fetchComments(int postId) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/$postId/comments'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<dynamic> commentsData = json.decode(response.body);
      setState(() {
        comments = commentsData.map((comment) => Comment.fromJson(comment)).toList();
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.post.body,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Text('Comments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Text(comments[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comments[index].email),
                          SizedBox(height: 5),
                          Text(comments[index].body),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
