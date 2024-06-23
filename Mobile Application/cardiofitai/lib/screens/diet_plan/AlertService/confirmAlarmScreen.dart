import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user.dart';
import 'notificationHomePage.dart';

class ConfirmAlarm extends StatefulWidget {
  const ConfirmAlarm(this.user, this._lastSubmitRecordNo, {super.key});

  final User user;
  final int _lastSubmitRecordNo;

  @override
  State<ConfirmAlarm> createState() => _ConfirmAlarmState();
}

class _ConfirmAlarmState extends State<ConfirmAlarm> {
  List<Map<String, dynamic>> _medicinesWithAlarms = [];
  int _currentMedicineIndex = 0;
  bool _isAlarmEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadMedicineAlarms();
  }

  Future<void> _loadMedicineAlarms() async {
    final QuerySnapshot alarmSnapshot = await FirebaseFirestore.instance
        .collection('alarms')
        .where('userEmail', isEqualTo: widget.user.email)
        .where('reminderNo', isEqualTo: widget._lastSubmitRecordNo)
        .get();

    final List<Map<String, dynamic>> medicines = [];

    for (var doc in alarmSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Store the document ID for later updates

      final existingMedicineIndex = medicines.indexWhere(
              (medicine) => medicine['medicineName'] == data['medicineName']);

      if (existingMedicineIndex >= 0) {
        medicines[existingMedicineIndex]['alarms'].add(data);
      } else {
        medicines.add({
          'medicineName': data['medicineName'],
          'alarms': [data],
        });
      }
    }

    for (var medicine in medicines) {
      medicine['alarms'].sort((a, b) =>
          DateTime.parse(a['scheduledAlarmDateTime'])
              .compareTo(DateTime.parse(b['scheduledAlarmDateTime'])));
    }

    setState(() {
      _medicinesWithAlarms = medicines;
    });
  }

  void _editAlarm(Map<String, dynamic> alarm) async {
    final DateTime initialDateTime =
    DateTime.parse(alarm['scheduledAlarmDateTime']);

    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDate != null) {
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.red,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (newTime != null) {
        final DateTime newDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        setState(() {
          alarm['scheduledAlarmDateTime'] = newDateTime.toIso8601String();
        });
      }
    }
  }

  void _deleteAlarm(Map<String, dynamic> alarm) async {
    setState(() {
      _medicinesWithAlarms[_currentMedicineIndex]['alarms'].remove(alarm);
    });

    await FirebaseFirestore.instance
        .collection('alarms')
        .doc(alarm['id'])
        .delete();
  }

  void _confirmAlarms() async {
    for (var medicine in _medicinesWithAlarms) {
      for (var alarm in medicine['alarms']) {
        await FirebaseFirestore.instance
            .collection('alarms')
            .doc(alarm['id'])
            .update({
          'scheduledAlarmDateTime': alarm['scheduledAlarmDateTime'],
        });
      }
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Alarms updated successfully')));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (buildContext) => NotificationHomePage(widget.user)));
  }

  void _toggleAlarm(bool value) {
    setState(() {
      _isAlarmEnabled = value;
    });
    // Add your logic here to enable or disable the alarm
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Confirm medicine alarms',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: _medicinesWithAlarms.isEmpty,
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_medicinesWithAlarms.isEmpty)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              )
            else ...[
              Text(
                'Medicine: ${_medicinesWithAlarms[_currentMedicineIndex]['medicineName']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _medicinesWithAlarms[_currentMedicineIndex]
                  ['alarms']
                      .length,
                  itemBuilder: (context, index) {
                    final alarm = _medicinesWithAlarms[_currentMedicineIndex]
                    ['alarms'][index];
                    final alarmTime =
                    DateTime.parse(alarm['scheduledAlarmDateTime']);

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      child: ListTile(
                        title: Text(
                          'Alarm Time: ${DateFormat.yMd().add_jm().format(alarmTime)}',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosage: ${alarm['dosage']}',
                                style: TextStyle(color: Colors.black54)),
                            Text(
                                'Additional Notes: ${alarm['additionalNotes'] ?? 'None'}',
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _editAlarm(alarm),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAlarm(alarm),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentMedicineIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentMedicineIndex--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Previous'),
                    ),
                  if (_currentMedicineIndex < _medicinesWithAlarms.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentMedicineIndex++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Next'),
                    ),
                  if (_currentMedicineIndex == _medicinesWithAlarms.length - 1)
                    ElevatedButton(
                      onPressed: _confirmAlarms,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Confirm'),
                    ),
                ],
              ),
              SwitchListTile(
                title: Text("Enable Alarm"),
                value: _isAlarmEnabled,
                onChanged: _toggleAlarm,
                activeColor: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
