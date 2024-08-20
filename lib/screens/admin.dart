import 'package:flutter/material.dart';
import '/adminScreens/manageUsers.dart';
import '/adminScreens/plans-classes.dart';
import '/adminScreens/updates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/auth_page.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 55,),
            Text(
              'Admin Home',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageUsers(),
                      ),
                    );
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                                size: 45, color: Colors.white),
                            SizedBox(width: 20),
                            Text(
                              'Manage Users',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Updates(),
                      ),
                    );
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          children: [
                            Icon(Icons.add_box_rounded,
                                size: 45, color: Colors.white),
                            SizedBox(width: 20),
                            Text(
                              'Add Updates for Users',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageClasses(),
                      ),
                    );
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          children: [
                            Icon(Icons.add_box_rounded,
                                size: 45, color: Colors.white),
                            SizedBox(width: 20),
                            Text(
                              'Add Subscriptions',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: GestureDetector(
                  onTap: signOut,
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          children: [
                            Icon(Icons.add_box_rounded,
                                size: 45, color: Colors.white),
                            SizedBox(width: 20),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}