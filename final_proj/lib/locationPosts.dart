import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'comments.dart';
import 'firebase_options.dart';
import 'other_profile.dart';

class LocationPosts extends StatelessWidget {
  final String location;

  const LocationPosts({Key? key, required this.location}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$location'),
      ),
      body: MyHomePage(location: location),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.location}) : super(key: key);

  final String location;

  @override
  State<MyHomePage> createState() => _MyHomePageState(location);
}

class _MyHomePageState extends State<MyHomePage> {
  var posts = [];
  String _location = "";

  _MyHomePageState(String user) {
    _location = user;
  }

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  _getPosts() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('posts');

    QuerySnapshot querySnapshot = await _collectionRef.get();

    var allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var indiData = [];
    var allPosts = [];
    for (var item in allData) {
      indiData.add(item);
    }

    for (var item in indiData) {
      for (var i in item['posts']) {
        allPosts.add(i);
      }
    }

    for (var i in allPosts) {
      if (i['location'] == _location) {
        posts.add(i);
      }
      if (kDebugMode) {
        print(posts);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(children: [
                FutureBuilder(
                    future: _getPosts(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (posts.length == 0) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Container(
                            child: ListView.builder(
                                padding: const EdgeInsets.only(top: 20),
                                itemCount: posts.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0, right: 10.0),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue,
                                                  width: 0.5),
                                              color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                icon: const Icon(Icons.person),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OProfile(
                                                                user: posts[
                                                                        index]
                                                                    ['email'])),
                                                  );
                                                }),
                                          ),
                                          Column(
                                            children: [
                                              Text(posts[index]['email'],
                                                  style: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(posts[index]['location'],
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 15.0),
                                        alignment: Alignment.center,
                                        child: Image.network(
                                            posts[index]['image'],
                                            height: 400,
                                            fit: BoxFit.cover),
                                      ),
                                    ],
                                  );
                                }));
                      }
                    }),
              ]),
            )));
  }
}
