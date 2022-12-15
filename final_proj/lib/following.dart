import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Following extends StatelessWidget {
  final following;
  const Following({Key? key, required this.following}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: MyHomePage(following: following),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.following}) : super(key: key);

  final following;

  @override
  State<MyHomePage> createState() => _MyHomePageState(following);
}

class _MyHomePageState extends State<MyHomePage> {
  var _following;

  _MyHomePageState(var following) {
    _following = following;
  }

  void loadData() async {
    if (kDebugMode) {
      print(_following);
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
      body: ListView.builder(
          padding: const EdgeInsets.only(top: 20),
          itemCount: _following.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  Text(_following[index],
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
    );
  }
}
