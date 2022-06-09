import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'admin_service.dart';
import 'calendar_view.dart';

class AttendanceDetail extends StatefulWidget {
  //String id;
  const AttendanceDetail({Key? key}) : super(key: key);

  @override
  _AttendanceDetailState createState() => _AttendanceDetailState();
}

class _AttendanceDetailState extends State<AttendanceDetail> {
  late double w, h;
  List<Map<String, dynamic>> attendance = [];
  bool loading = true;
  AdminService adminService = AdminService();
  bool calendarView = false;

  void fetchAttendance() async {
    List<Map<String, dynamic>> attendance =
        await adminService.getAttendanceByUser();
    setState(() {
      loading = false;
      this.attendance = attendance;
    });
  }

  @override
  void initState() {
    fetchAttendance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  calendarView = !calendarView;
                });
              },
              child: Icon(
                  !calendarView ? Icons.calendar_today_outlined : Icons.list),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: !loading
                  ? calendarView
                      ? CalendarView(
                          attendance: attendance,
                        )
                      : getAttendance()
                  : const Center(
                      child: CircularProgressIndicator(),
                    ))
        ],
      ),
    );
  }

  Widget getAttendance() {
    return attendance.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: attendance.length,
            itemBuilder: (context, index) {
              return userItemView(attendance[index]);
            })
        : const Center(
            child: Text("No attendance found!"),
          );
  }

  Widget userItemView(Map<String, dynamic> attendance) {
    final f = DateFormat('yyyy-MM-dd hh:mm a');
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.6),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    attendance['present'] == true ? "Present" : "Absent",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Text(
                    attendance['dat'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exact Date Time : " +
                        f.format(
                            DateTime.parse(attendance['dateTime'].toString())),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Reporter Id : " + attendance['personId'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
