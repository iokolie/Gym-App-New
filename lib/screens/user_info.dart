import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'subscribe_screen.dart';



class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  String? selectedItem;
  DateTime? selectedDate;

  List<String> items = ['Male', 'Female', 'Rather Not Say'];
  TextEditingController namecontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController heightcontroller = TextEditingController();
  TextEditingController weightcontroller = TextEditingController();
  TextEditingController goalcontroller = TextEditingController();
  DatabaseMethods db = DatabaseMethods();

  Future<void> uploadUserInfo() async {
    try {
      // Retrieve user ID from your database method
      String? userId = await db.getUserId();

      if (userId != null) {
        // Get reference to the Firestore collection and document
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        DocumentReference userDoc = users.doc(userId);

        // Prepare the data to be uploaded
        Map<String, dynamic> userData = {
          'name': namecontroller.text.isNotEmpty ? namecontroller.text : 'Not specified',
          'date_of_birth': agecontroller.text.isNotEmpty ? agecontroller.text : 'Not specified',
          'weight': weightcontroller.text.isNotEmpty ? weightcontroller.text : 'Not specified',
          'height': heightcontroller.text.isNotEmpty ? heightcontroller.text : 'Not specified',
          'gender': selectedItem ?? 'Not specified',
          'goals': goalcontroller.text.isNotEmpty ? goalcontroller.text : 'Not specified',
        };

        // Check if name and age are filled
        if (namecontroller.text.isEmpty || agecontroller.text.isEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                title: Center(
                  child: Text(
                    'Name and Age are required',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          );
          return;
        }

        // Check if the document exists
        DocumentSnapshot docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          // Document exists, update the document with new data
          await userDoc.set(userData);
        } else {
          // Document does not exist, create a new document
          await userDoc.set(userData);
        }

        // Show the success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 98, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              title: Center(
                child: Text(
                  'Info Added Successfully',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        ).then((_) async {
          // Wait for the dialog to be dismissed
          await Future.delayed(Duration(seconds: 1));

          // Explicitly dismiss the dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Navigate to the new page with animation
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                // Choose the page to navigate to based on whether the document exists
                Widget nextPage = docSnapshot.exists ? InfoScreen() : Subscribe();

                // Define the animation for the page transition
                const begin = Offset(0.0, 0.0); // Start from the right
                const end = Offset.zero; // End at the center
                const curve = Curves.easeInOut; // Smooth transition

                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

                return SlideTransition(position: offsetAnimation, child: nextPage);
              },
              transitionDuration: Duration(milliseconds: 300), // Adjust the duration as needed
            ),
          );
        });
      } else {
        print("User not logged in");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Form key for validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 45,),
              Text('Add your Info', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 35,),
                    Text('Name', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20,),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8), 
                        borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: namecontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Full Name',
                            ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                        ),
                    ),
                  
                    SizedBox(height: 25),
                    Text('Age', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: agecontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Date Of Birth',
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                              agecontroller.text = "${pickedDate.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select DOB';
                          }
                          return null;
                        },
                      ),
                    ),
                  
                    SizedBox(height: 25,),
                    Text('Weight (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8), 
                        borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: weightcontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Weight',
                            suffixText: 'kg'
                            ),
                          // No validation for optional fields
                        ),
                    ),
              
                    SizedBox(height: 25,),
                    Text('Height (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8), 
                        borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: heightcontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Height',
                            suffixText: 'cm'
                            ),
                          // No validation for optional fields
                        ),
                    ),
              
                    SizedBox(height: 25),
                    Text('Gender', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    SizedBox(height: 30),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: items.map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item, style: TextStyle(fontSize: 18, color: Colors.black)),
                          )).toList(),
                          value: selectedItem,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Select Gender',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedItem = value;
                            });
                          },
                        ),
                      ),
                    ),
              
                    SizedBox(height: 25),
                    Text('Goals (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8), 
                        borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          maxLines: 6,
                          controller: goalcontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your goals'
                            ),
                          // No validation for optional fields
                        ),
                    ),
                    
                    SizedBox(height: 30,),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          uploadUserInfo();
                        }
                      },
                      child: Center(
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.black, 
                              borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text('Done', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
