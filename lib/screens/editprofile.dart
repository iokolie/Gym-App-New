import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/database.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? selectedItem;
  DateTime? selectedDate;

  // List of items in our drop-down menu
  List<String> items = ['Male', 'Female', 'Rather Not Say'];
  TextEditingController namecontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController heightcontroller = TextEditingController();
  TextEditingController weightcontroller = TextEditingController();
  TextEditingController goalcontroller = TextEditingController();
  DatabaseMethods db = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Method to fetch and display user information
  Future<void> _loadUserInfo() async {
    String? userId = await db.getUserId();
    if (userId != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          namecontroller.text = userData['name'] ?? '';
          agecontroller.text = userData['date_of_birth'] ?? '';
          weightcontroller.text = userData['weight'] ?? '';
          heightcontroller.text = userData['height'] ?? '';
          selectedItem = userData['gender'];
          goalcontroller.text = userData['goals'] ?? '';
        });
      }
    }
  }

  // Method to upload data to Firestore
  Future<void> uploadUserInfo() async {
    String? userId = await db.getUserId();
    if (userId != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      await users.doc(userId).set({
        'name': namecontroller.text,
        'date_of_birth': agecontroller.text,
        'weight': weightcontroller.text,
        'height': heightcontroller.text,
        'gender': selectedItem,
        'goals': goalcontroller.text,
      }, SetOptions(merge: true)).then((value) {
        Navigator.pushNamed(context, "/homepage");
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
                  'Info Updated Successfully',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
        print("User Info Updated");
      }).catchError((error) {
        print("Failed to update user info: $error");
      });
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // This will navigate to the previous page
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 35, color: Colors.black38,),
        ),
        title: Text('Edit your Info'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                        return value!.isEmpty
                            ? 'Please enter name'
                            : namecontroller.text = value;
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
                        return value!.isEmpty
                            ? 'Please select DOB'
                            : agecontroller.text = value;
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
                      validator: (value) {
                        return value!.isEmpty
                            ? 'Not Specified'
                            : weightcontroller.text = value;
                      },
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
                      validator: (value) {
                        return value!.isEmpty
                            ? 'Not Specified'
                            : heightcontroller.text = value;
                      },
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
                        onChanged: (value) => setState(() {
                          selectedItem = value;
                        }),
                        dropdownColor: Colors.white,
                        hint: Text('Select Gender'),
                        iconSize: 30,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        value: selectedItem,
                      ),
                    ),
                  ),
              
                  SizedBox(height: 10),
                  SizedBox(height: 25,),
                  Text('Gym Goals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 25,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color(0xFFececf8), 
                      borderRadius: BorderRadius.circular(20)),
                    child: TextFormField(
                      maxLines: 6,
                      controller: goalcontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'What are the goals you want to achieve by going to gym?',
                      ),
                      validator: (value) {
                        return value!.isEmpty
                            ? 'Please enter Goals'
                            : goalcontroller.text = value;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 30,),
                  GestureDetector(
                    onTap: uploadUserInfo,
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
                            )),
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
    );
  }
}
