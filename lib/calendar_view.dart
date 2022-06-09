import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class CalendarView extends StatefulWidget {
  List<Map<String, dynamic>> attendance;
  CalendarView({Key? key, required this.attendance}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime today = DateTime.now();
  late DateTime _currentDate;
  DateTime _currentDate2 = DateTime(2019, 2, 3);
  String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
  DateTime _targetDateTime = DateTime(2019, 2, 3);
  bool loading = true;
  int tp = 0;
  int ta = 0;
  calculateAttendance() {
    for (Map m in widget.attendance) {
      if (m['present']) {
        tp++;
      } else {
        ta++;
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    calculateAttendance();
    _currentDate = DateTime(today.year, today.month, today.day);
    _currentDate2 = DateTime(today.year, today.month, today.day + 1);
    _currentMonth =
        DateFormat.yMMM().format(DateTime(today.year, today.month, today.day));
    _targetDateTime = DateTime(today.year, today.month, today.day);

    super.initState();
  }

  int isEventDay(DateTime dt) {
    int contain = 0;
    for (Map m in widget.attendance) {
      DateTime dateTime = DateTime.parse(m['dateTime'].toString());
      if (dateTime.year == dt.year &&
          dateTime.month == dt.month &&
          dateTime.day == dt.day) {
        if (m['present']) {
          contain = 1;
        } else {
          contain = 2;
        }
        break;
      }
    }
    return contain;
  }

  @override
  Widget build(BuildContext context) {
    final _calendarCarouselNoHeader = CalendarCarousel<Event>(
      todayBorderColor: Colors.grey,
      onDayPressed: (date, events) {
        setState(() => _currentDate2 = date);
        events.forEach((event) => print(event.title));
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: const TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      selectedDayBorderColor: Colors.grey,
      height: 420.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: const NeverScrollableScrollPhysics(),
      markedDateCustomTextStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      showHeader: false,
      todayTextStyle: const TextStyle(
        color: Colors.blue,
      ),
      todayButtonColor: Colors.transparent,
      selectedDayTextStyle: const TextStyle(
        color: Colors.yellow,
      ),
      selectedDayButtonColor: Colors.transparent,
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: const TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      markedDateWidget: Container(),
      onCalendarChanged: (DateTime date) {
        setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
      customDayBuilder: (isSelectable, index, isSelectedDay, isToday,
          isPrevMonthDay, textStyle, isNextMonthDay, isThisMonthDay, day) {
        int status = isEventDay(day);
        return GestureDetector(
          onTap: () {},
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == 1
                    ? Colors.green
                    : status == 2
                        ? Colors.red
                        : Colors.transparent,
              ),
              child: Center(
                  child: Text(
                day.day.toString(),
                style: TextStyle(
                    color: status == 1 || status == 2
                        ? Colors.white
                        : Colors.black),
              ))),
        );
      },
    );

    return !loading
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 30.0,
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        _currentMonth,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      )),
                      FlatButton(
                        child: const Text('PREV'),
                        onPressed: () {
                          setState(() {
                            _targetDateTime = DateTime(_targetDateTime.year,
                                _targetDateTime.month - 1);
                            _currentMonth =
                                DateFormat.yMMM().format(_targetDateTime);
                          });
                        },
                      ),
                      FlatButton(
                        child: const Text('NEXT'),
                        onPressed: () {
                          setState(() {
                            _targetDateTime = DateTime(_targetDateTime.year,
                                _targetDateTime.month + 1);
                            _currentMonth =
                                DateFormat.yMMM().format(_targetDateTime);
                          });
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _calendarCarouselNoHeader,
                ), //
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                getTotal()
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget getTotal() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            "Total Present in this month : " + tp.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Total Absent in this month : " + ta.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}
