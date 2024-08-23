
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/auth_page.dart';

class MainFeed extends StatefulWidget {
  const MainFeed({super.key});

  @override
  State<MainFeed> createState() => _MainFeedState();
}

class _MainFeedState extends State<MainFeed> {
  String username = "User"; // Default username

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = userDoc.get('name') ?? "User"; // Fallback if 'name' doesn't exist
      });
    }
  }

  

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 237, 92, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.person, size: 50),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Welcome $username,',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 13),
                Text('Latest Updates', style: TextStyle(color: Colors.black, fontSize: 22)),
              ],
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.star_rate_rounded),
              title: Text('We have just added brand new equipment to the Gym!!'),
            ),
            GridButtons(),
            SizedBox(height: 40),
            Center(
              child: MaterialButton(
                color: Colors.red,
                child: Text('Sign out'),
                onPressed: signOut,
              ),
            ),
            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class GridButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blueGrey
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_rounded),
                      Text('Null'),
                    ],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blueGrey
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_rounded),
                      Text('Null'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blueGrey
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_rounded),
                      Text('Null'),
                    ],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blueGrey
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center
                    ,
                    children: [
                      Icon(Icons.home_work_rounded),
                      Text('Null'),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
