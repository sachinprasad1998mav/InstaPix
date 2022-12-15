import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

class Comments extends StatelessWidget {
  final comments;
  final int index;

  final posts;

  Comments(
      {Key? key,
      required this.comments,
      required this.index,
      required this.posts})
      : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: MyHomePage(comments: comments, index: index, posts: posts),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {Key? key,
      required this.comments,
      required this.index,
      required this.posts})
      : super(key: key);

  final posts;
  final comments;
  final int index;

  @override
  State<MyHomePage> createState() => _MyHomePageState(comments, index, posts);
}

class _MyHomePageState extends State<MyHomePage> {
  var _comments;
  var post;
  var posts;
  int index = 0;
  final _commentController = TextEditingController();

  _MyHomePageState(comments, index, posts) {
    post = comments;
    _comments = post['comments'];
    posts = posts;
    index = index;
  }


  void loadData() async {
    if (kDebugMode) {
      print('Comments are: $_comments');
      print('Post is: $post');
      print(posts);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  addComment() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = await prefs.getString("email");
    var comment = _commentController.text;

    setState(() {
      _comments.add({
        'comment': comment,
        'commenter': user,
      });
    });

    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // firestore.collection("posts").doc(posts[index]['email']).set({
    //   "posts": posts,
    // });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: _comments.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: [
                        Text(
                          _comments[index]['commenter'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _comments[index]['comment'],
                          style: const TextStyle(fontSize: 30),
                        )
                      ],
                    ));
              }),
          Spacer(),
          Row(children: [
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Add Comment',
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 0.5),
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    addComment();
                  }),
            ),
          ])
        ],
      ),
    );
  }
}
