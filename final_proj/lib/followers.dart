import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Followers extends StatelessWidget {
  final followers;

  const Followers({Key? key, required this.followers}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: MyHomePage(followers: followers),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.followers}) : super(key: key);

  final followers;

  @override
  State<MyHomePage> createState() => _MyHomePageState(followers);
}

class _MyHomePageState extends State<MyHomePage> {
  var _followers;

  _MyHomePageState(var followers) {
    _followers = followers;
  }

  void loadData() async {}

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
          itemCount: _followers.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  Text(_followers[index],
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
    );
  }
}
