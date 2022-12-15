import 'dart:io';

import 'package:flutter/material.dart';
import 'login.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  // fireBaseInit();
  runApp(const Login());
}

Future<void> fireBaseInit() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}