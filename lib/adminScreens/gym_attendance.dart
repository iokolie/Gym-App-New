import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 35),
            Text('Search', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search User',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _selectDate(context, isStartDate: true),
                  child: Text(startDate == null ? 'Start Date' : "${startDate!.toLocal()}".split(' ')[0]),
                ),
                TextButton(
                  onPressed: () => _selectDate(context, isStartDate: false),
                  child: Text(endDate == null ? 'End Date' : "${endDate!.toLocal()}".split(' ')[0]),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchAttendanceRecords(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No attendance records found.'));
                  }

                  List<Map<String, dynamic>> users = [];

                  for (var doc in snapshot.data!.docs) {
                    final docData = doc.data() as Map<String, dynamic>;

                    docData.forEach((key, value) {
                      if (value is Map<String, dynamic>) {
                        if (value['name'] != null && value['date'] != null) {
                          if (searchQuery.isEmpty ||
                              value['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())) {
                            users.add(value);
                          }
                        }
                      }
                    });
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      var name = user['name'] ?? 'No Name';
                      var date = user['date'] ?? 'No Date';

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Date: $date'),
                        onTap: () {
                          // Action on user tap, if needed
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Stream<QuerySnapshot> _fetchAttendanceRecords() {
    Query query = FirebaseFirestore.instance.collection('gym attendance records');

    if (startDate != null) {
      query = query.where(FieldPath.documentId, isGreaterThanOrEqualTo: _formatDate(startDate!));
    }
    if (endDate != null) {
      query = query.where(FieldPath.documentId, isLessThanOrEqualTo: _formatDate(endDate!));
    }

    return query.snapshots();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }
}
