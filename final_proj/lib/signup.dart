import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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

  SharedPreferences? prefs;
  var signupSuccess = true;
  var message = "";


  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    prefs = await SharedPreferences.getInstance();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('User is signed in!');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Method to store the user in firebase Firestore
  Future<void> createUserInDatabase() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("users").doc(emailController.text).set({
      'email': emailController.text,
      "followers": [],
      "following": [],
      "posts": 0,
      "profilePic": "",
    });
  }

  Future<void> signup() async {

    await prefs!.setString("email", emailController.text);

    // Code to create new user in Firebase authentication
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          signupSuccess = false;
          message = "The password provided is too weak.";
          print('The password provided is too weak.');
          return;
        }
      } else if (e.code == 'email-already-in-use') {
        signupSuccess = false;
        message = "The account already exists for that email.";
        if (kDebugMode) {
          print('The account already exists for that email.');
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
        signupSuccess = false;
        message = "Error: $e";
        return;
      }
    }
    createUserInDatabase();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Sign Up",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 35,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  color: Colors.white,
                  child: Center(
                      child: Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/cins467-final.appspot.com/o/InstaPix-logos.jpeg?alt=media&token=ea2ba7c9-0297-44bd-860c-db60f0d5988e",
                    height: 150,
                    width: 150,
                  )),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.mail),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.key),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Already Registered? Login here'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('SIGN UP'),
                      onPressed: () async {
                        await signup();
                        var snackBar = SnackBar(content: Text(message));

                        if(!signupSuccess) {
                          // Step 3
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
