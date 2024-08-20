import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/auth_page.dart';
import '/screens/editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Import for date formatting

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  String? profileImageUrl;

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  // Function to calculate age from date of birth
  int calculateAge(String dobString) {
    final dateFormat = DateFormat('yyyy-MM-dd'); // Adjust format if needed
    DateTime dob = dateFormat.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;

    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SingleChildScrollView(
        child: user == null
            ? Center(child: Text("User not logged in"))
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data;

                  // Initialize default values
                  String name = 'User';
                  String dateOfBirth = '';
                  String gender = '';
                  String height = '';
                  String weight = '';
                  String goals = '';
                  String? profileImageUrl;

                  try {
                    if (userData != null && userData.exists) {
                      final data = userData.data() as Map<String, dynamic>;
                      name = data['name'] ?? 'User';
                      dateOfBirth = data['date_of_birth'] ?? '';
                      gender = data['gender'] ?? '';
                      height = data['height'] ?? '';
                      weight = data['weight'] ?? '';
                      goals = data['goals'] ?? '';
                      profileImageUrl = data['profile_image'];
                    }
                  } catch (e) {
                    print('Error accessing fields: $e');
                  }

                  // Calculate age from date of birth
                  int age = dateOfBirth.isNotEmpty ? calculateAge(dateOfBirth) : 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 105),
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage: profileImageUrl == null
                                    ? AssetImage('assets/images/default_profile.png') as ImageProvider
                                    : NetworkImage(profileImageUrl),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: IconButton(
                                  icon: Icon(LineAwesomeIcons.camera_retro_solid, color: Colors.white),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Center(child: Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins',))),
                      SizedBox(height: 7),
                      Center(child: Text(age.toString(), style: TextStyle(fontSize: 20))),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 25),
                            Text('Gender', style: TextStyle(fontFamily: 'Poppins'),),
                            SizedBox(height: 5),
                            _buildInfoContainer(' $gender'),

                            SizedBox(height: 25),
                            Text('Height', style: TextStyle(fontFamily: 'Poppins'),),
                            SizedBox(height: 5),
                            _buildInfoContainer(' $height'),


                            SizedBox(height: 25),
                            Text('Weight', style: TextStyle(fontFamily: 'Poppins'),),
                            SizedBox(height: 5),
                            _buildInfoContainer(' $weight'),


                            SizedBox(height: 25),
                            Text('Goals', style: TextStyle(fontFamily: 'Poppins'),),
                            SizedBox(height: 5),
                            _buildInfoContainer(' $goals'),
                            SizedBox(height: 25),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(),
                                  ),
                                );
                              },
                              icon: Icon(LineAwesomeIcons.edit, color: Colors.white),
                              label: Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton.icon(
                              onPressed: signOut,
                              icon: Icon(LineAwesomeIcons.sign_out_alt_solid, color: Colors.white),
                              label: Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                            ),
                            SizedBox(height: 75),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (await Permission.storage.request().isGranted) {
      try {
        
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.indigo,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Cropper',
              ),
            ],
          );

          if (croppedFile != null) {
            File imageFile = File(croppedFile.path);
            setState(() {
              _imageFile = imageFile;
            });
            await _uploadImageToFirebase(imageFile);
          }
        }
      } catch (e) {
        print("Error picking image: $e");
      }
    } else {
      Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();
      print(statuses[Permission.storage]);
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
        
        UploadTask uploadTask = storageReference.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profile_image': downloadUrl,
        });

        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Widget _buildInfoContainer(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$value', style: TextStyle(fontSize: 17)),
      ),
    );
  }
}
