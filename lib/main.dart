import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:sa/admin.dart';
import 'package:sa/attendance_detail.dart';
import 'dart:io';

import 'net_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AttendanceDetail(),
    );
  }
}

class AttendanceRecording extends StatefulWidget {
  const AttendanceRecording({Key? key}) : super(key: key);

  @override
  _AttendanceRecordingState createState() => _AttendanceRecordingState();
}

class _AttendanceRecordingState extends State<AttendanceRecording> {
  late double w, h;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  NetServices api = NetServices();
  String info = "Loading...";
  String today =
      "Today : " + DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());

  init() async {
    bool connection = await InternetConnectionChecker().hasConnection;
    if (connection) await api.sync();
    String i = await api.getTodayStatus();
    setState(() {
      info = i;
    });
    await initPlatformState();
    api.saveDeviceInfo(_deviceData);
    const oneSec = Duration(minutes: 1);
    Timer.periodic(oneSec, (Timer t) {
      setState(() {
        today =
            "Today : " + DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
      });
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: h * .04,
            ),
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.blue,
              child: Text(
                today,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: h * .03,
            ),
            Text(
              info,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: h * .05,
            ),
            Row(
              children: [
                Spacer(),
                FlatButton(
                  onPressed: () async {
                    await api.markAttendance(true, _deviceData['androidId']);
                    setState(() {
                      info = "Student is marked as present today!";
                    });
                  },
                  child: const Text(
                    "Present",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.green,
                ),
                SizedBox(width: w * .1),
                FlatButton(
                  onPressed: () async {
                    await api.markAttendance(false, _deviceData['androidId']);
                    setState(() {
                      info = "Student is marked as absent today!";
                    });
                  },
                  child: const Text(
                    "Absent",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.red,
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }
}
