import 'dart:io';

import 'package:final_proj/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  var isLoginSuccess = true;
  var message = "";

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    prefs = await SharedPreferences.getInstance();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('User is signed in!');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
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

  Future<void> login() async {
    await prefs!.setString("email", emailController.text);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        message = "No user found for that email";
        isLoginSuccess = false;
        if (kDebugMode) {
          print('No user found for that email.');
        }
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          message = "Wrong password provided for that user";
          isLoginSuccess = false;
          print('Wrong password provided for that user.');
        }
      }
    }
    isLoginSuccess = true;
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
                const Text("Login",
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
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
                      child: const Text('LOGIN'),
                      onPressed: () async {
                        await login();
                        var snackBar = SnackBar(content: Text(message));

                        if(!isLoginSuccess) {
                          // Step 3
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('SIGN UP'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Signup()),
                        );
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
