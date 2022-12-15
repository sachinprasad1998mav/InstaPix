import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

class OProfile extends StatelessWidget {
  final String user;

  const OProfile({Key? key, required this.user}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$user Profile'),
      ),
      body: MyHomePage(user: user),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.user}) : super(key: key);

  final String user;

  @override
  State<MyHomePage> createState() => _MyHomePageState(user);
}

class _MyHomePageState extends State<MyHomePage> {
  int _followers = 0;
  int _following = 0;
  String _user = "";
  var other_followers = [];
  var other_following = [];
  var alreadyFollowing = false;
  bool _af = false;

  _MyHomePageState(String user) {
    _user = user;
  }

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_user)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      var fr = await documentSnapshot.get(FieldPath(['followers']));
      var fl = await documentSnapshot.get(FieldPath(['following']));
      other_followers = fr;
      other_following = fl;

      setState(() {
        _followers = fr.length;
        _following = fl.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  followUser() async {
    print('Other followers: $other_followers');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userLoggedIn = prefs.getString("email");

    if (other_followers.contains(userLoggedIn)) {
        if (kDebugMode) {
          print('Already following this user');
        }
        alreadyFollowing = true;
        setState(() {
          _af = alreadyFollowing;
        });
    } else {
      alreadyFollowing = false;
      setState(() {
        _af = alreadyFollowing;
      });
      if (kDebugMode) {
        print('Not following');
      }
      var your_following;
      // Get details of user who logged in i.e. the user who's using this app in order to change his following data
      // along with the user who's being followed as well

      // i.e: Change current user's following list and the other profile's user's follower list.

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userLoggedIn)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {

        your_following = await documentSnapshot.get(FieldPath(['following']));
        var your_followers = await documentSnapshot.get(FieldPath(['followers']));
        print('Your following: $your_following');

        your_following.add(_user);
        other_followers.add(userLoggedIn);

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        firestore.collection("users").doc(_user).set({
          "followers":other_followers,
          "following": other_following,
          "email": _user,
        });

        firestore.collection("users").doc(userLoggedIn).set({
          "following":your_following,
          "followers": your_followers,
          "email": userLoggedIn,
        });

        setState(() {
          _followers = other_followers.length;
          _following = other_following.length;
        });
      });
    }
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
                    Container(
                        margin: const EdgeInsets.only(left: 50.0, top: 50.0),
                        child: Text('$_followers')),
                    Container(
                        margin: const EdgeInsets.only(left: 50.0, top: 10.0),
                        child: Text('Followers')),
                  ],
                ),
                Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 150.0, top: 50.0),
                        child: Text("$_following")),
                    Container(
                        margin: const EdgeInsets.only(left: 150.0, top: 10.0),
                        child: Text('Following')),
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
                onPressed: () async {
                  await followUser();
                  var snackBar = const SnackBar(content: Text('Already following this user'));

                  if(_af) {
                    // Step 3
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text('Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
