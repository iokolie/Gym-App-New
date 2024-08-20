
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods{
  Future<String?> getUserId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        // User is not logged in
        return null;
      }
    } catch (e) {
      print("Error fetching user ID: $e");
      return null;
    }
  }


  Future<String?> fetchUserEmail() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.email;
    } else {
      return null; // or throw an exception if preferred
    }
  } catch (e) {
    print('Error fetching user email: $e');
    return null;
  }
}



  



}