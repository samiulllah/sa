import 'package:flutter/material.dart';
import 'package:sa/admin_service.dart';
import 'package:sa/attendance_detail.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late double w, h;
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  AdminService adminService = AdminService();

  void getAllUsers() async {
    List<Map<String, dynamic>> users = await adminService.getUsers();
    setState(() {
      loading = false;
      this.users = users;
    });
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: Column(
        children: [
          Expanded(
              child: !loading
                  ? getUsers()
                  : Center(
                      child: Container(
                        child: CircularProgressIndicator(),
                      ),
                    ))
        ],
      ),
    );
  }

  Widget getUsers() {
    return users.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return userItemView(users[index]);
            })
        : const Center(
            child: Text("No users found!"),
          );
  }

  Widget userItemView(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => AttendanceDetail(id: user['androidId'])));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.6),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Text(
              user['brand'] + " : " + user['model'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
