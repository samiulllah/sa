import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetServices {
  Future<void> saveDeviceInfo(Map<String, dynamic> data) async {
    try {
      writeToDb("deviceInfo/${data['androidId'].toString()}", data);
    } catch (e) {
      print("error saving d.info $e");
    }
  }

  Future<void> markAttendance(bool present, String personId) async {
    try {
      DateTime today = DateTime.now();
      final f = DateFormat('yyyy-MM-dd');
      String path = "attendance/" + f.format(today).toString();

      writeToDb(path, {
        "present": present,
        "personId": personId,
        "dat": f.format(today).toString(),
        "dateTime": DateTime.now().toIso8601String()
      });
    } catch (e) {
      print("Error while noting attendance : " + e.toString());
    }
  }

  Future<void> writeToDb(String path, Map<String, dynamic> data) async {
    bool isOnline = await hasNetwork();
    if (isOnline) {
      print("<<<<<<<<<<Yes online>>>>>>>>>");
      bool written = await writeToFb(path, data);
      if (!written) {
        await writeToLocal(path, data);
      }
    } else {
      print("<<<<<<<<<<Yes offline>>>>>>>>>");
      await writeToLocal(path, data);
    }
  }

  writeToLocal(String path, Map<String, dynamic> data) async {
    try {
      print("<<<<<<<<<<<<<<<<Saving loally >>>>>>>>>>>>>>>");
      data['sync'] = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // key update
      List<String> olderKeys = [];
      if (prefs.containsKey('keys')) {
        olderKeys = prefs.getStringList("keys")!;
      }
      if (!olderKeys.contains(path)) {
        // check for duplicates
        olderKeys.add(path);
        prefs.setStringList("keys", olderKeys);
      }
      // data update
      prefs.setString(path, jsonEncode(data));
    } catch (e) {
      print("Fail to save to prefs : " + e.toString());
    }
  }

  Future<bool> writeToFb(String path, Map<String, dynamic> data) async {
    print("<<<<<<<<<<<<<<<<Saving globally >>>>>>>>>>>>>>>");
    List<String> paths = path.split('/');
    try {
      FirebaseFirestore.instance
          .collection(paths[0])
          .doc(paths[1])
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = [];
    DateTime today = DateTime.now();
    final f = DateFormat('yyyy-MM-dd');
    String tdy = f.format(today).toString();
    if (prefs.containsKey('keys')) {
      keys = prefs.getStringList("keys")!;
    }
    if (keys.isNotEmpty) {
      // update firestore
      List<String> removedKeys = [];
      for (String path in keys) {
        if (prefs.containsKey(path)) {
          Map<String, dynamic> data = jsonDecode(prefs.getString(path)!);
          if (!data['sync']) {
            bool written = await writeToFb(path, data);
            if (written) {
              if (data.containsKey('dat')) {
                if (data['dat'] == tdy) {
                  data['sync'] = true;
                } else {
                  data['sync'] = true;
                  prefs.remove(path);
                  removedKeys.add(path);
                }
              } else {
                prefs.remove(path);
                removedKeys.add(path);
              }
            }
          }
        } else {
          removedKeys.add(path);
        }
      }
      // update keys
      removedKeys.forEach((element) {
        keys.remove(element);
      });
      if (keys.isNotEmpty) {
        prefs.setStringList("keys", keys);
      } else {
        prefs.remove('keys');
      }
    }
  }

  Future<bool> hasNetwork() async {
    bool result = await InternetConnectionChecker().hasConnection;
    return result;
  }

  Future<String> getTodayStatus() async {
    String status = "";
    bool isOnline = await hasNetwork();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();
    final f = DateFormat('yyyy-MM-dd');
    String path = "attendance/" + f.format(today).toString();
    print("User Online status : >>>>>>>>>>>> " +
        (!isOnline).toString() +
        " path : " +
        prefs.containsKey(path).toString());
    // local check
    if (!isOnline) {
      print("<<<<<<<<<<<<<<<<<<  Getting status locally >>>>>>>>>>>>>>>>>>>");
      if (prefs.containsKey(path)) {
        Map<String, dynamic> data = jsonDecode(prefs.getString(path)!);
        if (data['present']) {
          status = "Student is marked as present today!";
        } else {
          status = "Student is marked as absent today!";
        }
      } else {
        status = "Please record attendance below";
      }
    } else {
      print("<<<<<<<<<<<<<<<<<<  Getting status globaly >>>>>>>>>>>>>>>>>>>");
      // global check
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .doc(f.format(today).toString())
            .get();
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data['present']) {
            status = "Student is marked as present today!";
          } else {
            status = "Student is marked as absent today!";
          }
        } else {
          // not recorded yet
          status = "Please record attendance below";
        }
      } catch (e) {
        status = "Unable to fetch user status";
      }
    }
    return status;
  }
}
