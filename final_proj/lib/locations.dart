import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'locationPosts.dart';

class Locations extends StatelessWidget {
  const Locations({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
      ),
      body: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> postSet = {};
  var posts = [];

  void loadData() async {
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
      postSet.add(i['location']);
    }

    setState(() {
      for(var i in postSet){
        posts.add(i);
      }
    });

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
      body: ListView.builder(
          padding: const EdgeInsets.only(top: 20),
          itemCount: posts.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Card(
                margin: const EdgeInsets.only(top: 15.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LocationPosts(
                                  location: posts[index])),
                    );
                  },
                child: Column(
                  children: [
                    Text(posts[index], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ],
                ),
            ));
          }),
    );
  }
}
