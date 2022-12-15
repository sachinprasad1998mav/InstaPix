import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_proj/other_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'locationPosts.dart';

class Search extends StatelessWidget {
  final String searchQuery;

  const Search({Key? key, required this.searchQuery}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: MyHomePage(searchQuery: searchQuery),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.searchQuery}) : super(key: key);

  final String searchQuery;

  @override
  State<MyHomePage> createState() => _MyHomePageState(searchQuery);
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> postSet = {};
  var posts = [];
  var _searchQuery = "";

  _MyHomePageState(String searchQuery) {
    _searchQuery = searchQuery;
  }

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await _collectionRef.get();

    var allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var indiData = [];
    var allPosts = [];

    for (var item in allData) {
      indiData.add(item);
    }

    for (var item in indiData) {
      allPosts.add(item);
    }

    setState(() {
      for (var item in allPosts) {
        if(item!['email'].toString().toLowerCase().contains(_searchQuery)) {
          posts.add(item);
        }
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
                          builder: (context) => OProfile(user: posts[index]['email']),
                        ));
                  },
                  child: Column(
                    children: [
                      Text(posts[index]['email'],
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ));
          }),
    );
  }
}
