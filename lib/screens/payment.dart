import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/home.dart';
import '/screens/profile.dart';
import '/services/database.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';

class Paystack extends StatefulWidget {
  const Paystack({super.key});

  @override
  State<Paystack> createState() => _PaystackState();
}

class _PaystackState extends State<Paystack> {
  String? email;
  String? username;
  DatabaseMethods db = DatabaseMethods();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getEmail();
    fetchUsername();
  }

  Future<void> _getEmail() async {
    // Fetch the email and set the state
    String? fetchedEmail = await db.fetchUserEmail();
    setState(() {
      email = fetchedEmail;
      emailcontroller.text = fetchedEmail ?? ''; // Update the controller text
    });
  }

  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = userDoc.get('name') ?? "User"; // Fallback if 'name' doesn't exist
        namecontroller.text = username ?? '';
      });
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
            }, 
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 28, color: Colors.black,)),
        title: Text('Make your payment', style: TextStyle(fontFamily: 'Poppins',)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              
              children: [
                SizedBox(height: 20),
                Image.asset('assets/images/Asset 2.png', width: 120, height: 120),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Achieve your Gym goals with us by Subscribing Now',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 23,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
                  child: TextFormField(
                    controller: namecontroller,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFececf8),
                      labelText: 'Full Name',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String value) {},
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter your name' : null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: TextFormField(
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFececf8),
                      labelText: 'Email Address',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String value) {},
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter email' : null;
                    },
                  ),
                ),
                SizedBox(height: 25),
                
                GestureDetector(
                  onTap: () async {
                    PayWithPayStack().now(
                      context: context,
                      secretKey: "sk_test_9c4892b3a8fbb766a9e3b911b8e8a4d396f2d716",
                      callbackUrl: "https://www.sportybet.com/ng/",
                      customerEmail: emailcontroller.text,
                      reference: DateTime.now().microsecondsSinceEpoch.toString(),
                      currency: "NGN",
                      amount: 100.00,
                      transactionCompleted: () {
                        print("Transaction Successful");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      transactionNotCompleted: () {
                        print("Transaction Not Successful!");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
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
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Center(
                          child: Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontFamily: 'Catamaran',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
