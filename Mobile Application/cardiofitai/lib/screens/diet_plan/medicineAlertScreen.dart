import 'dart:convert';
import 'dart:io';
import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/medicineReminderService.dart';
import '../../services/prescription_reading_api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MedicineAlertPage extends StatefulWidget {

  const MedicineAlertPage(this.user,{super.key}); // Initialize user email

  final User user;

  @override
  State<MedicineAlertPage> createState() => _MedicineAlertPageState();
}

class _MedicineAlertPageState extends State<MedicineAlertPage> {
  final apiService = ApiService();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _pillIntakeController = TextEditingController();
  final TextEditingController _additionalInstructions = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final List<Map<String, dynamic>> _medicines = [];
  bool precautionLoading = false;
  String diseasePrecautions = '';
  File? pickedImage;
  XFile? image;
  String prescriptionInfo = '';
  bool detecting = false;
  String _selectedFrequency = 'once';
  final List<String> _frequencyOptions = [
    'once',
    'twice',
    'thrice',
    'four times'
  ];
  final List<String> _selectedDays = [];
  final Map<int, String> _daysOfWeek = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun'
  };
  late QuerySnapshot<Object?> _lastSubmittedRecordInfo;
  int _lastSubmitRecordNo=0;

  @override
  void initState() {
    super.initState();
    _generateReminderNo();

    // _startTimeController.text = TimeOfDay.now().format(context); // Initialize _startTimeController here
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
        source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  detectDisease() async {
    setState(() {
      detecting = true;
    });
    try {
      prescriptionInfo =
      await apiService.sendImageToGPT4Vision(image: pickedImage!);
      _addMedicinesFromPrescriptionInfo();
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        detecting = false;
      });
    }
  }

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }

  String normalizeFrequency(String frequency) {
    frequency = frequency.toLowerCase();
    if (frequency.contains('once')) return 'once';
    if (frequency.contains('twice')) return 'twice';
    if (frequency.contains('thrice') || frequency.contains('three times'))
      return 'thrice';
    if (frequency.contains('four times')) return 'four times';
    if (frequency.contains('q.d') || frequency.contains('qd') ||
        frequency.contains('daily') || frequency.contains('once daily'))
      return 'once';
    if (frequency.contains('b.i.d') || frequency.contains('bid') ||
        frequency.contains('twice daily')) return 'twice';
    if (frequency.contains('t.i.d') || frequency.contains('tid') ||
        frequency.contains('three times daily')) return 'thrice';
    if (frequency.contains('q.i.d') || frequency.contains('qid') ||
        frequency.contains('four times daily')) return 'four times';
    return 'once';
  }

  int normalizeDuration(String duration) {
    duration = duration.toLowerCase();
    if (duration.contains('one week') || duration.contains('1/52')) return 7;
    if (duration.contains('two weeks') || duration.contains('2/52')) return 14;
    if (duration.contains('three weeks') || duration.contains('3/52'))
      return 21;
    if (duration.contains('four weeks') || duration.contains('4/52') ||
        duration.contains('a month')) return 28;
    final match = RegExp(r'(\d+) day').firstMatch(duration);
    if (match != null) return int.parse(match.group(1)!);
    return 0; // Default to 0 if unable to parse
  }

  int _generateUniqueReminderNo() {
    return DateTime
        .now()
        .millisecondsSinceEpoch; // Generate a unique number based on the current time
  }

  void _addMedicinesFromPrescriptionInfo() {
    try {
      final jsonStartIndex = prescriptionInfo.indexOf('[');
      final jsonEndIndex = prescriptionInfo.lastIndexOf(']') + 1;

      if (jsonStartIndex != -1 && jsonEndIndex != -1) {
        final jsonString = prescriptionInfo.substring(
            jsonStartIndex, jsonEndIndex);

        final List<dynamic> parsedInfo = jsonDecode(jsonString);
        for (var medicineInfo in parsedInfo) {
          final int days = normalizeDuration(medicineInfo['Duration'] ?? '');
          final DateTime startDate = DateTime.now();
          final DateTime endDate = startDate.add(Duration(days: days));

          final Map<String, dynamic> medicine = {
            'reminderNo': _generateUniqueReminderNo(),
            'userEmail': widget.user.email,
            'name': medicineInfo['Medicine Name'] ?? '',
            'dosage': medicineInfo['Dosage'] ?? '',
            'pillintake': medicineInfo['Pill Intake'] ?? '',
            'interval': normalizeFrequency(medicineInfo['Frequency'] ?? ''),
            'days': days,
            'startDate': DateFormat('yyyy-MM-dd').format(startDate),
            'startTime': TimeOfDay.now().format(context),
            'additionalInstructions': medicineInfo['Additional Instructions'] ??
                '',
            'selectedDays': _selectedDays,
          };
          setState(() {
            _medicines.add(medicine);
          });
        }
        print("done");
      } else {
        _showErrorSnackBar('Failed to find JSON data in the prescription info');
      }
    } catch (error) {
      _showErrorSnackBar('Failed to parse prescription info');
    }
  }

  void _populateFieldsForEditing(Map<String, dynamic> medicine) {
    _medicineNameController.text = medicine['name'] ?? '';
    _dosageController.text = medicine['dosage'] ?? '';
    _selectedFrequency = medicine['interval'] ?? 'once';
    _daysController.text = medicine['days'].toString();
    _pillIntakeController.text = medicine['pillintake'] ?? '';
    _additionalInstructions.text = medicine['additionalInstructions'] ?? '';
    _startDateController.text = medicine['startDate'] ?? '';
    _startTimeController.text = medicine['startTime'] ?? '';
    _selectedDays.clear();
    _selectedDays.addAll(medicine['selectedDays'] ?? []);
  }

  void _showSuccessDialog(String title, String content) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: title,
      desc: content,
      btnOkText: 'Got it',
      btnOkColor: Colors.blueGrey,
      btnOkOnPress: () {},
    ).show();
  }

  void _toggleDaySelection(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _autoSelectDays(DateTime startDate, int days) {
    _selectedDays.clear();
    for (int i = 0; i < days; i++) {
      final dayOfWeek = (startDate
          .add(Duration(days: i))
          .weekday) % 7 + 1;
      _selectedDays.add(_daysOfWeek[dayOfWeek]!);
    }
  }

  Future<void> _generateReminderNo() async {
    try {
      _lastSubmittedRecordInfo = await MedicineReminderService.findLastReminderSubmitted(widget.user.email);
      if (_lastSubmittedRecordInfo.docs.isNotEmpty) {
        _lastSubmitRecordNo = _lastSubmittedRecordInfo.docs[0]["reminderNo"] ?? 0;
      } else {
        _lastSubmitRecordNo = 0; // Initialize to 0 if no previous record found
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching last reminder: $e');
      _lastSubmitRecordNo = 0; // Default to 0 in case of an error
    }
  }


  void _setReminder() {
    for (var medicine in _medicines) {
      if (medicine['interval'].isEmpty || medicine['days'] == 0) {
        _showErrorSnackBar(
            'Please edit the entry for ${medicine['name']} to include both frequency and duration.');
        return;
      }
      // Set the reminder using the provided frequency and duration
      // This part can be implemented using a local notification package, such as flutter_local_notifications
    }

    _showSuccessDialog('Reminders set successfully', '');
  }

  Future<void> _onTapSubmitBtn(BuildContext context) async {
    for (var extractedMedicine in _medicines) {
      _lastSubmitRecordNo += 1;
      await MedicineReminderService.medicineReminder(
        _lastSubmitRecordNo,
        extractedMedicine["userEmail"] ?? widget.user.email,
        extractedMedicine["name"] ?? '',
        extractedMedicine["dosage"] ?? '',
        extractedMedicine["pillintake"] ?? '',
        extractedMedicine["interval"] ?? '',
        extractedMedicine["days"] ?? 0,
        extractedMedicine["startDate"] ?? '',
        extractedMedicine["additionalInstructions"] ?? '',
        List<String>.from(extractedMedicine["selectedDays"] ?? []),
        extractedMedicine["startTime"] ?? '',
      );
    }
    _showSuccessDialog('Reminders set successfully', '');
  }


  @override
  Widget build(BuildContext context) {
    if (_startTimeController.text.isEmpty) {
      _startTimeController.text = TimeOfDay.now().format(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Prescription',
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'OPEN GALLERY',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.image,
                      color: Colors.blueGrey,
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white60,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('START CAMERA',
                        style: TextStyle(color: Colors.blueGrey)),
                    const SizedBox(width: 10),
                    Icon(Icons.camera_alt, color: Colors.blueGrey)
                  ],
                ),
              ),
              pickedImage == null
                  ? Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.5,
                child: Image.asset('assets/pick1.png'),
              )
                  : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    pickedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (pickedImage != null)
                detecting
                    ? SpinKitWave(
                  color: Colors.blueGrey,
                  size: 30,
                )
                    : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      detectDisease();
                    },
                    child: const Text(
                      'DETECT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (prescriptionInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      prescriptionInfo,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Center(
                child: Text(
                  'OR',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Text(
                'Set Reminder Manually',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              _setRemindersManuallyForm(),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final medicine = _medicines[index];
                  return ListTile(
                    title: Text(
                        'Medicine Name: ${medicine['name']}  Dosage: ${medicine['dosage']}'),
                    subtitle: Text(
                        'Frequency: ${medicine['interval']} \t Duration: ${medicine['days']}  \t Pill Intake: ${medicine['pillintake']} \n Start Date: ${medicine['startDate']} \t End Date: ${medicine['endDate']} \n Additional Information: ${medicine['additionalInstructions']} \n Start Time: ${medicine['startTime']} \n Days of Week: ${medicine['selectedDays']
                            .join(', ')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _populateFieldsForEditing(medicine);
                            setState(() {
                              _medicines.removeAt(index);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _medicines.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => _onTapSubmitBtn(context),

                child: Text('Set Alarm'),
              )
            ],
          ),
        ),
      ),
    );
  }

  _setRemindersManuallyForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _medicineNameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage in mg',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pillIntakeController,
                decoration: InputDecoration(
                  labelText: 'Pill Intake per Time',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _additionalInstructions,
                decoration: InputDecoration(
                  labelText: 'Additional Information',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                keyboardType: TextInputType.text,
              ),
            )
          ],
        ),
        SizedBox(height: 16),
        Text('Reminder setup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFrequency,
                items: _frequencyOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFrequency = newValue!;
                  });
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _daysController,
                decoration: InputDecoration(
                  labelText: 'Number of days',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  if (_startDateController.text.isNotEmpty && text.isNotEmpty) {
                    final startDate = DateFormat('yyyy-MM-dd').parse(
                        _startDateController.text);
                    final days = int.tryParse(text) ?? 0;
                    _autoSelectDays(startDate, days);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today_outlined),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _startDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          if (_daysController.text.isNotEmpty) {
                            final days = int.tryParse(_daysController.text) ??
                                0;
                            _autoSelectDays(pickedDate, days);
                          }
                        });
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time_outlined),
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _startTimeController.text =
                              pickedTime.format(context);
                        });
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('Remind Every',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _daysOfWeek.values.map((day) => _buildDayToggle(day))
              .toList(),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _medicines.add({
                'reminderNo': _generateUniqueReminderNo(),
                'userEmail': "",
                'name': _medicineNameController.text,
                'dosage': _dosageController.text,
                'interval': _selectedFrequency,
                'days': int.tryParse(_daysController.text) ?? 0,
                'pillintake': _pillIntakeController.text,
                'startDate': _startDateController.text,
                'startTime': _startTimeController.text,
                'additionalInstructions': _additionalInstructions.text,
                'selectedDays': List<String>.from(_selectedDays),
              });
              _medicineNameController.clear();
              _dosageController.clear();
              _daysController.clear();
              _pillIntakeController.clear();
              _additionalInstructions.clear();
              _startDateController.clear();
              _startTimeController.clear();
              _selectedDays.clear();
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Widget _buildDayToggle(String day) {
    final isSelected = _selectedDays.contains(day);
    return ChoiceChip(
      label: Text(day),
      selected: isSelected,
      onSelected: (selected) {
        _toggleDaySelection(day);
      },
      selectedColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isSelected ? Colors.blueGrey : Colors.grey),
      ),
    );
  }
}


