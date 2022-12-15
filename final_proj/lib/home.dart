import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_proj/search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'comments.dart';
import 'profile.dart';
import 'other_profile.dart';
import 'locations.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
  var posts = [];
  var lat, lng;
  late ImagePicker _picker;
  late var storageRef;
  var commentPosts = [];
  String userLoggedIn = "";
  TextEditingController _searchController = TextEditingController();

  void loadData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _picker = ImagePicker();

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    lat = _locationData.latitude;
    lng = _locationData.longitude;
    if (kDebugMode) {
      print('latlon is $lat and $lng');
    }
  }

  _getPosts() async {
    posts = [];
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString("email");
    userLoggedIn = user!;
    var fl;

    if (kDebugMode) {
      print('user is: $user}');
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      fl = await documentSnapshot.get(FieldPath(['following']));
    });

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
      if (fl.contains(i['email'])) {
        posts.add(i);
      }
    }
    commentPosts = posts;
  }

  Future<void> addImage() async {
    // First, we use Google Places API to convert the latitude and longitude into city names
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyAXbKiZ3Cf7PKGf1dVF_iDNkd9YOXdooec'));
    var body = jsonDecode(response.body);
    var b = body['plus_code'];
    var location = b['compound_code'];
    location = location.split(',');
    location = location[0].split(' ');
    int count = 0;
    var finalLocation = "";
    for (var i in location) {
      if (count != 0) {
        finalLocation = '$finalLocation ' + i;
      }
      count += 1;
    }

    if (kDebugMode) {
      print('PLACES result is $finalLocation');
    }

    // Next, we store this image in firebase storage and obtain the URL.
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    var imageFile = File(image!.path);
    var url;
    url = await uploadImage(imageFile);
    if (kDebugMode) {
      print(url);
    }

    // Next, we upload this into Firebase Firestore database.
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(userLoggedIn)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      var val = await documentSnapshot.get(FieldPath(['posts']));
      if (kDebugMode) {
        print(val);
      }
      DateTime now = new DateTime.now();
      var datestamp = DateFormat("yyyyMMdd'T'HHmmss");
      String currentdate = datestamp.format(now);

      val.add({
        "comments": [],
        "date": currentdate,
        "email": userLoggedIn,
        "image": url,
        "likes": 0,
        "location": finalLocation
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore.collection("posts").doc(userLoggedIn).set({
        "posts": val,
      });
    });
  }

  uploadImage(var imageFile) async {
    DateTime now = new DateTime.now();
    var datestamp = DateFormat("yyyyMMdd'T'HHmmss");
    String currentdate = datestamp.format(now);

    var ref = firebase_storage.FirebaseStorage.instance
        .refFromURL("gs://cins467-final.appspot.com")
        .child("$currentdate.jpg");

    UploadTask uploadTask = ref.putFile(imageFile);
    var url = (await uploadTask).ref.getDownloadURL();
    return url;
  }

  @override
  void initState() {
    super.initState();
    posts = [];
    loadData();
  }

  void incrementLikes(post, int index) {
    if (kDebugMode) {
      print(posts);
      print(posts[index]['email']);
    }

    posts[index]['likes'] = posts[index]['likes'] + 1;
    setState(() {});

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("posts").doc(posts[index]['email']).set({
      "posts": posts,
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addImage();
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search users',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 0.5),
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Search(
                                      searchQuery: _searchController.text)),
                            );
                          }),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 50.0),
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 0.5),
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Locations()),
                            );
                          }),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 50.0),
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 0.5),
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Profile()),
                            );
                          }),
                    ),
                  ],
                ),
                FutureBuilder(
                    future: _getPosts(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (posts.isEmpty) {
                        return Center(
                            child: Column(
                              children: const [
                                CircularProgressIndicator(),
                                Text('No Posts Found!!')
                              ],
                            ));
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
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: StadiumBorder(),
                                                primary: Colors.red),
                                            onPressed: () {
                                              incrementLikes(posts, index);
                                            },
                                            child: Text(
                                                '${posts[index]['likes']} Likes'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              if (posts[index]['comments']
                                                      .length >
                                                  0) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Comments(
                                                              comments:
                                                                  posts[index],
                                                              index: index,
                                                              posts:
                                                                  commentPosts)),
                                                );
                                              }
                                            },
                                            child: Text(
                                                '${posts[index]['comments'].length} Comments'),
                                          ),
                                        ],
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
