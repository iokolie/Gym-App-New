import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/payment.dart';
import '/screens/classes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: user == null
          ? Center(child: Text("User not logged in", style: TextStyle(color: Colors.white)))
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

                // Initialize default values
                String name = 'User';
                String? profileImageUrl;

                try {
                  if (userData != null && userData.exists) {
                    // Check and retrieve fields safely
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
                      automaticallyImplyLeading: false, // This will hide the back butto
                      flexibleSpace: FlexibleSpaceBar(
                        background: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 35, left: 10, right: 15),
                              child: CircleAvatar(
                                radius: 42,
                                backgroundImage: profileImageUrl == null
                                    ? AssetImage('assets/images/default_profile.png') as ImageProvider
                                    : NetworkImage(profileImageUrl),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text(
                                '$name',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Poppins',),
                              ),
                            ),
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
                                  Icon(Icons.info_rounded, color: Colors.red, size: 40,),
                                  SizedBox(height: 5,),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Text('Subscribe and Start Your Gym Journey Today!', 
                                    textAlign: TextAlign.center, 
                                    style: TextStyle(
                                      color: Colors.black, 
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400))),
                                  SizedBox(height: 10,),
                                  GestureDetector(
                                    onTap: (){
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
                                        child:const Padding(
                                          padding:  EdgeInsets.only(
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
              style: TextStyle(color: Colors.grey.shade800, fontSize: 25, fontFamily: 'Poppins',),
            ),
          ],
        ),
      ),
    );
  }
}
