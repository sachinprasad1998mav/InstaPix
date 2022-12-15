import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'followers.dart';
import 'following.dart';
import 'login.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
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
  int _followers = 0;
  int _following = 0;
  int _posts = 0;
  String _user = "";
  var fr, fl;

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = await prefs.getString("email");
    if (kDebugMode) {
      print('user is: $user}');
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      fr = await documentSnapshot.get(FieldPath(['followers']));
      fl = await documentSnapshot.get(FieldPath(['following']));

      setState(() {
        _followers = fr.length;
        _following = fl.length;
        _user = user!;
      });
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
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 50),
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                  icon: const Icon(Icons.person),
                  iconSize: 48.0,
                  onPressed: () {}),
            ),
            Row(
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Followers(
                                      followers: fr)),
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 50.0, top: 50.0),
                          child: Text('$_followers')),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Followers(
                                      followers: fr)),
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 50.0, top: 10.0),
                          child: Text('Followers')),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Following(
                                      following: fl)),
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 150.0, top: 50.0),
                          child: Text("$_following")),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Following(
                                      following: fl)),
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 150.0, top: 10.0),
                          child: Text('Following')),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 50.0, top: 50.0),
                    child: Text('EMAIL')),
                Container(
                    margin: const EdgeInsets.only(left: 50.0, top: 50.0),
                    child: Text(_user)),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                onPressed: () {
                  signOut();
                },
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
  }
}
