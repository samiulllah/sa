import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  Future<List<Map<String, dynamic>>> getUsers() async {
    List<Map<String, dynamic>> users = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('deviceInfo').get();
      if (snapshot.docs.isNotEmpty) {
        for (DocumentSnapshot ds in snapshot.docs) {
          users.add(ds.data() as Map<String, dynamic>);
        }
      }
      return users;
    } catch (e) {
      print("Error getting users : " + e.toString());
      return users;
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceByUser() async {
    List<Map<String, dynamic>> attendance = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('attendance').get();
      if (snapshot.docs.isNotEmpty) {
        for (DocumentSnapshot ds in snapshot.docs) {
          attendance.add(ds.data() as Map<String, dynamic>);
        }
      }
      return attendance;
    } catch (e) {
      print("Error getting users : " + e.toString());
      return attendance;
    }
  }
}
