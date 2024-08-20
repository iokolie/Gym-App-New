
import 'package:flutter/material.dart';


class YourWorkout extends StatefulWidget {
  const YourWorkout({super.key});

  @override
  State<YourWorkout> createState() => _YourWorkoutState();
}

class _YourWorkoutState extends State<YourWorkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Updates', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true, 
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20,),
            ListTile(
              leading: Icon(Icons.star_rate_rounded),
              title: Text('We have just added brand new equipment to the Gym!!', style: TextStyle(fontFamily: 'Poppins',)),
              trailing: Icon(Icons.circle, color: Colors.lightBlue, size: 10,),
            ),

            SizedBox(height: 20,),
            ListTile(
              leading: Icon(Icons.star_rate_rounded),
              title: Text('We have just added brand new equipment to the Gym!!', style: TextStyle(fontFamily: 'Poppins',)),
              trailing: Icon(Icons.circle, color: Colors.lightBlue, size: 10,),
            ),

            SizedBox(height: 20,),
            ListTile(
              leading: Icon(Icons.star_rate_rounded),
              title: Text('We have just added brand new equipment to the Gym!!', style: TextStyle(fontFamily: 'Poppins',)) ,
              trailing: Icon(Icons.circle, color: Colors.lightBlue, size: 10,),
            ),
          ],
        ),
      ),
    );
  }
}