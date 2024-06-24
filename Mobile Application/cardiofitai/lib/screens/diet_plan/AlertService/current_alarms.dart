import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class CurrentAlarms extends StatefulWidget {
  const CurrentAlarms({super.key});

  @override
  State<CurrentAlarms> createState() => _CurrentAlarmsState();
}

class _CurrentAlarmsState extends State<CurrentAlarms> {
  late List<AlarmSettings> alarms;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAlarms();
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: alarms.isNotEmpty
          ? ListView.separated(
              itemCount: alarms.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  key: Key(alarms[index].id.toString()),
                  title: Text(TimeOfDay(
                        hour: alarms[index].dateTime.hour,
                        minute: alarms[index].dateTime.minute,
                      ).format(context) +
                      " " +
                      alarms[index].dateTime.day.toString()),
                  onTap: () {
                    // navigateToAlarmScreen(alarms[index])
                  },
                  onLongPress: () {
                    Alarm.stop(alarms[index].id).then((_) => loadAlarms());
                  },
                );
              },
            )
          : Center(
              child: Text(
                'No alarms set',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
