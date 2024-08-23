import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/payment.dart';
import '/screens/classes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String qrResult = 'Scanned Data';

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
      });

      if (qrResult == '2eazy Yes') {
        _updateAttendance();
      }
    } on PlatformException {
      qrResult = 'FAILED TO SCAN';
    }
  }

  Future<void> _updateAttendance() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final attendanceDoc = userDoc.collection('attendance').doc('weeklyAttendance');
  final today = DateTime.now();
  final todayStr = "${today.year}-${today.month}-${today.day}";

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(attendanceDoc);

    if (!snapshot.exists) {
      // No attendance entry exists, create a new one for week 1 and today
      transaction.set(attendanceDoc, {
        'week 1': {
          'count': 1,
          'lastUpdated': todayStr,
        }
      });
      _recordAdminAttendance(user, todayStr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance for week 1 updated successfully!')),
      );
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      String currentWeekKey = 'week 1';
      int currentWeekNumber = 1;

      // Find the latest week
      for (int i = 1; i <= data.length; i++) {
        final weekKey = 'week $i';
        if (data.containsKey(weekKey)) {
          currentWeekKey = weekKey;
          currentWeekNumber = i;
        }
      }

      final lastUpdated = data[currentWeekKey]['lastUpdated'] ?? "";
      int currentCount = data[currentWeekKey]['count'] ?? 0;

      if (lastUpdated == todayStr) {
        // Attendance has already been recorded for today
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your attendance has already been recorded for today!')),
        );
      } else {
        if (currentCount >= 7) {
          // Start a new week if current week's attendance count is 7 or more
          currentWeekNumber++;
          currentWeekKey = 'week $currentWeekNumber';
          transaction.set(attendanceDoc, {
            currentWeekKey: {
              'count': 1,
              'lastUpdated': todayStr,
            }
          }, SetOptions(merge: true));  // Merge to preserve existing weeks
          _recordAdminAttendance(user, todayStr);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance for $currentWeekKey started!')),
          );
        } else {
          // Update the current week's attendance count
          transaction.update(attendanceDoc, {
            '$currentWeekKey.count': currentCount + 1,
            '$currentWeekKey.lastUpdated': todayStr,
          });
          _recordAdminAttendance(user, todayStr);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance for $currentWeekKey updated successfully!')),
          );
        }
      }
    }
  });
}

/// Function to record attendance for the admin
Future<void> _recordAdminAttendance(User user, String date) async {
  final adminDoc = FirebaseFirestore.instance.collection('gym attendance records').doc(date);
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final userData = await userDoc.get();
  final userName = userData.data()?['name'] ?? 'Unknown User';

  await adminDoc.set({
    user.uid: {
      'name': userName,
      'date': date,
    },
  }, SetOptions(merge: true));
}




  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: user == null
          ? Center(
              child: Text("User not logged in",
                  style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var userData = snapshot.data;

                String name = 'User';
                String? profileImageUrl;

                try {
                  if (userData != null && userData.exists) {
                    if (userData.data() != null) {
                      final data = userData.data() as Map<String, dynamic>;
                      name = data['name'] ?? 'User';
                      profileImageUrl = data['profile_image'];
                    }
                  }
                } catch (e) {
                  print('Error accessing fields: $e');
                }

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Color.fromARGB(255, 237, 92, 1),
                      expandedHeight: 130,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 35, left: 10, right: 15),
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundImage: profileImageUrl == null
                                        ? AssetImage('assets/images/default_profile.png')
                                            as ImageProvider
                                        : NetworkImage(profileImageUrl),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: Text(
                                    '$name',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10, top: 28,),
                              child: IconButton(
                                onPressed: scanQR,
                                icon: Icon(Icons.photo_camera_rounded),
                                color: Colors.white,
                                iconSize: 30,
                              ),
                            )
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(0.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            width: double.infinity,
                            color: Colors.black12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_rounded,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  SizedBox(height: 5),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Text('Subscribe and Start Your Gym Journey Today!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400)),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Paystack(),
                                        ),
                                      );
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width: 175,
                                        child: const Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 5, top: 5),
                                          child: Center(
                                              child: Text(
                                            'Subscribe',
                                            style: TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                fontFamily: 'Catamaran'),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20,)
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(0.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        delegate: SliverChildListDelegate([
                          _buildGridItem(context, Icons.fitness_center, "Classes", Classes()),
                          _buildGridItem(context, Icons.access_time, "Slots", Classes()),
                          _buildGridItem(context, Icons.credit_card_sharp, "Plans", Classes()),
                          _buildGridItem(context, Icons.checklist_rounded, "Attendance", Classes()),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.grey[400],
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 25, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
