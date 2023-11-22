import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/blogmodel.dart';
import '../utils/DialogUtiils.dart';
import '../utils/color.dart';
import 'Addpost.dart';
import 'Postdetsils.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> users = [];
  List<Post> posts = [];
  String selectedUser = '';
  int selectedUserId = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<dynamic> usersData = json.decode(response.body);
      setState(() {
        users = usersData.map((user) => user['name'].toString()).toList();
      });
      if (users.isNotEmpty) {
        _fetchPosts(users[0]);
      }
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchPosts(String userName) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?userId=$selectedUserId'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List<dynamic> postsData = json.decode(response.body);
      setState(() {
        posts = postsData.map((post) => Post.fromJson(post)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirmed = await DialogUtils.showConfirmationDialog(
      context,
      'Are you sure you want to delete this post?',
    );

    if (confirmed != null && confirmed) {
      setState(() {
        isLoading = true;
      });

      final response = await http.delete(
          Uri.parse('https://jsonplaceholder.typicode.com/posts/$postId'));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          posts.removeWhere((post) => post.id == postId);
        });
      } else {
        throw Exception('Failed to delete post');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BlogFlow'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton(
                    value: selectedUser.isNotEmpty ? selectedUser : null,
                    items: users.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          user,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUser = value.toString();
                        selectedUserId = users.indexOf(selectedUser) + 1;
                      });
                      _fetchPosts(selectedUser);
                    },
                    hint: Text(
                      'Select User',
                      style: TextStyle(color: Colors.black54),
                    ),
                    underline: SizedBox(),
                  ),
                ),
                SizedBox(width: 20), // Add some spacing between the dropdown and the button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPostScreen(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.cyanAccent),
                  ),
                  child: Text(
                    'Add Post',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Text(
              'Posts for $selectedUser:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: AppColors.cardBackground,
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                          posts[index].title, style: TextStyle(color: Colors.black87)),
                      subtitle: Text(
                          posts[index].body, style: TextStyle(color: Colors.black54)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: AppColors.deleteButton),
                        onPressed: () {
                          _deletePost(posts[index].id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetailsScreen(post: posts[index]),
                          ),
                        );
                      },
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