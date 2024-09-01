import 'dart:convert';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../services/medicineReminderService.dart';
import '../../../services/prescription_reading_api_service.dart';
import 'notificationHomePage.dart';

class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage(this.user, {super.key});

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
  final TextEditingController _endDateController = TextEditingController();
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
  int _lastSubmitRecordNo = 0;

  @override
  void initState() {
    super.initState();
    _generateReminderNo();
  }

  Future<void> _generateReminderNo() async {
    try {
      _lastSubmittedRecordInfo =
      await MedicineReminderService.findLastReminderSubmitted(
          widget.user.email);
      if (_lastSubmittedRecordInfo.docs.isNotEmpty) {
        _lastSubmitRecordNo =
            _lastSubmittedRecordInfo.docs[0]["reminderNo"] ?? 0;
      } else {
        _lastSubmitRecordNo = 0; // Initialize to 0 if no previous record found
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching last reminder: $e');
      _lastSubmitRecordNo = 0; // Default to 0 in case of an error
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
    await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }
//When the analyse button is clicked,call the API get its respond and call _addMedicinesFromPrescriptionInfo method
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
    if (frequency.contains('once')) return '1';
    if (frequency.contains('twice')) return '2';
    if (frequency.contains('thrice') || frequency.contains('three times'))
      return '3';
    if (frequency.contains('four times')) return '4';
    if (frequency.contains('q.d') ||
        frequency.contains('qd') ||
        frequency.contains('daily') ||
        frequency.contains('once daily')) return '1';
    if (frequency.contains('b.i.d') ||
        frequency.contains('bid') ||
        frequency.contains('twice daily')) return '2';
    if (frequency.contains('t.i.d') ||
        frequency.contains('tid') ||
        frequency.contains('three times daily')) return '3';
    if (frequency.contains('q.i.d') ||
        frequency.contains('qid') ||
        frequency.contains('four times daily')) return '4';
    return '1';
  }

  int normalizeDuration(String duration) {
    duration = duration.toLowerCase();
    if (duration.contains('one week') || duration.contains('1/52')) return 7;
    if (duration.contains('two weeks') || duration.contains('2/52')) return 14;
    if (duration.contains('three weeks') || duration.contains('3/52'))
      return 21;
    if (duration.contains('four weeks') ||
        duration.contains('4/52') ||
        duration.contains('a month')) return 28;
    final match = RegExp(r'(\d+) day').firstMatch(duration);
    if (match != null) return int.parse(match.group(1)!);
    return 0; // Default to 0 if unable to parse
  }
//Extract the string which was passed from the API, break down into parts and store in _medicines list
  void _addMedicinesFromPrescriptionInfo() {
    try {
      final jsonStartIndex = prescriptionInfo.indexOf('[');
      final jsonEndIndex = prescriptionInfo.lastIndexOf(']') + 1;

      if (jsonStartIndex != -1 && jsonEndIndex != -1) {
        final jsonString =
        prescriptionInfo.substring(jsonStartIndex, jsonEndIndex);

        final List<dynamic> parsedInfo = jsonDecode(jsonString);
        for (var medicineInfo in parsedInfo) {
          final int days = normalizeDuration(medicineInfo['Duration'] ?? '');
          final DateTime startDate = DateTime.now();
          final DateTime endDate = startDate.add(Duration(days: days));

          final Map<String, dynamic> medicine = {
            'reminderNo': _lastSubmitRecordNo,
            'userEmail': widget.user.email,
            'name': medicineInfo['Medicine Name'] ?? '',
            'dosage': medicineInfo['Dosage'] ?? '',
            'pillintake': medicineInfo['Pill Intake'] ?? '',
            'interval': normalizeFrequency(medicineInfo['Frequency'] ?? ''),
            'days': days,
            'startDate': DateFormat('yyyy-MM-dd').format(startDate),
            'startTime': TimeOfDay.now().format(context),
            'endDate': DateFormat('yyyy-MM-dd').format(endDate),
            'additionalInstructions':
            medicineInfo['Additional Instructions'] ?? '',
            'selectedDays': _selectedDays,
          };
          setState(() {
            _medicines.add(medicine);
          });
        }
      } else {
        _showErrorSnackBar('Failed to find JSON data in the prescription info');
      }
    } catch (error) {
      _showErrorSnackBar('Failed to parse prescription info');
    }
  }
//when the edit icon is clicked the relevant matching data is inserted to the controls
  void _populateFieldsForEditing(Map<String, dynamic> medicine) {
    _medicineNameController.text = medicine['name'] ?? '';
    _dosageController.text = medicine['dosage'] ?? '';
    _selectedFrequency = medicine['interval'] ?? 'once';
    _daysController.text = medicine['days'].toString();
    _pillIntakeController.text = medicine['pillintake'] ?? '';
    _additionalInstructions.text = medicine['additionalInstructions'] ?? '';
    _startDateController.text = medicine['startDate'] ?? '';
    _endDateController.text = medicine['endDate'] ?? '';
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
      btnOkColor: Colors.red,
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
      final dayOfWeek = (startDate.add(Duration(days: i)).weekday) % 7 + 1;
      _selectedDays.add(_daysOfWeek[dayOfWeek]!);
    }
  }

  // String _getDayName(int dayNumber) {
  //   switch (dayNumber) {
  //     case DateTime.monday:
  //       return "Mon";
  //     case DateTime.tuesday:
  //       return "Tue";
  //     case DateTime.wednesday:
  //       return "Wed";
  //     case DateTime.thursday:
  //       return "Thu";
  //     case DateTime.friday:
  //       return "Fri";
  //     case DateTime.saturday:
  //       return "Sat";
  //     case DateTime.sunday:
  //       return "Sun";
  //     default:
  //       return "";
  //   }
  // }

  void _calculateEndDate() {
    if (_startDateController.text.isNotEmpty &&
        _daysController.text.isNotEmpty) {
      final startDate =
      DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final days = int.tryParse(_daysController.text) ?? 0;
      final endDate = startDate.add(Duration(days: days));
      _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
      _autoSelectDays(startDate, days);
    }
  }

  void _addMedicine() {
    setState(() {
      _medicines.add({
        'reminderNo': _lastSubmitRecordNo,
        'userEmail': widget.user.email,
        'name': _medicineNameController.text,
        'dosage': _dosageController.text,
        'interval': normalizeFrequency(_selectedFrequency ?? ''),
        'days': int.tryParse(_daysController.text) ?? 0,
        'pillintake': _pillIntakeController.text,
        'startDate': _startDateController.text,
        'startTime': _startTimeController.text,
        'endDate': _endDateController.text,
        'additionalInstructions': _additionalInstructions.text,
        'selectedDays': List<String>.from(_selectedDays),
      });
      _medicineNameController.clear();
      _dosageController.clear();
      _daysController.clear();
      _pillIntakeController.clear();
      _additionalInstructions.clear();
      _startDateController.clear();
      _endDateController.clear();
      _startTimeController.clear();
      _selectedDays.clear();
    });
  }
//when set alarm button is clicked it navigates here
  Future<void> _onTapSubmitBtn(BuildContext context) async {
    if(_medicines.isNotEmpty) {
      for (var medicine in _medicines) {
        if (medicine['interval'].isEmpty ||
            medicine['days'] == 0 ||
            medicine['startDate'].isEmpty ||
            medicine['endDate'].isEmpty ||
            medicine['startTime'].isEmpty) {
          _showErrorSnackBar('Please edit the entry for ${medicine['name']} to include frequency, duration, start date, start time, and end date.');
          return;
        } else {
          for (var extractedMedicine in _medicines) {
            _lastSubmitRecordNo += 1;
            //Generate an increment number and store the reminder in firebase in the collection medicineReminder
            await MedicineReminderService.medicineReminder(
              _lastSubmitRecordNo,
              widget.user.email,
              extractedMedicine["name"] ?? '',
              extractedMedicine["dosage"] ?? '',
              extractedMedicine["pillintake"] ?? '',
              extractedMedicine["interval"] ?? '',
              extractedMedicine["days"] ?? 0,
              extractedMedicine["startDate"] ?? '',
              extractedMedicine["endDate"] ?? '',
              extractedMedicine["additionalInstructions"] ?? '',
              List<String>.from(extractedMedicine["selectedDays"] ?? []),
              extractedMedicine["startTime"] ?? '',
            );

            await scheduleAlarmsForMedicine(
              medicineName: extractedMedicine["name"],
              dosage: extractedMedicine["dosage"],
              pillIntake: int.tryParse(extractedMedicine["pillintake"]) ?? 1,
              frequency: extractedMedicine["interval"],
              startDate:
              DateFormat('yyyy-MM-dd').parse(extractedMedicine["startDate"]),
              endDate:
              DateFormat('yyyy-MM-dd').parse(extractedMedicine["endDate"]),
              selectedDays: List<String>.from(
                  extractedMedicine["selectedDays"]),
              startTime: extractedMedicine["startTime"],
            );
          }

          _showSuccessDialog('Reminders set successfully', '');

          Navigator.of(context).push(MaterialPageRoute(
              builder: (buildContext) =>
                  NotificationHomePage(widget.user)));
        }
      }
    }
    _showErrorSnackBar('No Items added to set reminder');
  }
//Setting the alarms - Alarm package related.
  Future<void> scheduleAlarmsForMedicine({
    required String medicineName,
    required String dosage,
    required int pillIntake,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> selectedDays,
    required String startTime,
  }) async {
    final int interval = int.parse(frequency);
    final List<String> timeParts = startTime.split(":");
    final int startHour = int.parse(timeParts[0]);
    final int startMinute = int.parse(timeParts[1].split(" ")[0]);



    for (DateTime currentDate = startDate;
    currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
    currentDate = currentDate.add(Duration(days: 1))) {
      if (selectedDays.contains(DateFormat('E').format(currentDate))) {
        for (int j = 0; j < interval; j++) {
          final DateTime alarmTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            startHour + j * (24 ~/ interval),
            startMinute,
          );

          // Create a document in Firestore and get its ID
          final alarmDocRef = FirebaseFirestore.instance.collection('alarms').doc();
          final alarmId = alarmDocRef.id;
          final int alarmIdHash = alarmId.hashCode;

          final alarmSettings = AlarmSettings(
            id: alarmIdHash,
            dateTime: alarmTime,
            assetAudioPath: 'assets/diet_component/audio_assets/alarmsound.mp3',
            loopAudio: true,
            vibrate: true,
            volume: 0.8,
            fadeDuration: 2,
            notificationTitle: medicineName,
            notificationBody:
            'Take $pillIntake pill(s) of $medicineName. $dosage mg. ${_additionalInstructions.text}',
          );

          await Alarm.set(alarmSettings: alarmSettings);

          await alarmDocRef.set({
            'userEmail': widget.user.email,
            'reminderNo': _lastSubmitRecordNo,
            'alarmIdNo':alarmIdHash,
            'isActive':true,
            'medicineName': medicineName,
            'dosage': dosage,
            'pillIntake': pillIntake,
            'frequency': frequency,
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
            'selectedDays': selectedDays,
            'startTime': startTime,
            'scheduledAlarmDateTime': alarmTime.toIso8601String(),
          }).catchError((error) {
            _showErrorSnackBar('Failed to add alarm: $error');
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_startTimeController.text.isEmpty) {
      _startTimeController.text = TimeOfDay.now().format(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
              'Set Medicine Reminder',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (buildContext) => NotificationHomePage(widget.user)));
          },
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle('Upload Prescription'),
              _buildImagePickerOptions(),
              _buildPickedImage(),
              if (pickedImage != null) _buildDetectButton(),
              if (prescriptionInfo.isNotEmpty) _buildPrescriptionInfo(),
              _buildDivider(),
              _buildTitle('Set Reminder Manually'),
              SizedBox(height: 10),
              _setRemindersManuallyForm(),
              SizedBox(height: 16),
              _buildMedicineList(),
              _buildSetAlarmButton(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
//Title related styling
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }
//two options to upload prescriptions to the system
  Widget _buildImagePickerOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImagePickerButton('Open Gallery', Icons.image,
                    () => _pickImage(ImageSource.gallery)),
            _buildImagePickerButton('Start Camera', Icons.camera_alt,
                    () => _pickImage(ImageSource.camera)),
          ],
        ),
      ],
    );
  }
//Display the scanned Image in the app
  Widget _buildImagePickerButton(
      String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.red, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(width: 10),
          Icon(
            icon,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
  //Display the uploaded image, else show the default image
  Widget _buildPickedImage() {
    return pickedImage == null
        ? Center(
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.5,
        height: 500,
        child: Image.asset('assets/pick1.png'),
      ),
    )
        : Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          pickedImage!,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  //When an image is uploaded, display the analyse button
  Widget _buildDetectButton() {
    return detecting
        ? SpinKitWave(
      color: Colors.red,
      size: 30,
    )
        : Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding:
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          detectDisease();
        },
        child: const Text(
          'Analyse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(""),
      ),
    );
  }

  //Divide the section either to add details mannually
  Widget _buildDivider() {
    return Center(
      child: Text(
        'OR',
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  //Controld to mannual setting reimders
  Widget _setRemindersManuallyForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _medicineNameController, 'Medicine Name', TextInputType.text),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _buildTextField(
                  _dosageController, 'Dosage in mg', TextInputType.number),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(_pillIntakeController,
                  'Pill Intake per Time', TextInputType.number),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _buildTextField(_additionalInstructions,
                  'Additional Information', TextInputType.text),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('Reminder setup',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdownButtonFormField(),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _buildTextField(
                  _daysController, 'Number of days', TextInputType.number,
                  onChanged: (value) => _calculateEndDate()),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerTextField(),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _buildEndDatePickerTextField(),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTimePickerTextField()),
            Expanded(
              child: Column(
                children: [
                  Text('Remind Every',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Wrap(
                    spacing: 8.0,
                    children: _daysOfWeek.values
                        .map((day) => _buildDayToggle(day))
                        .toList(),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _addMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
//Styling of the controls of mannual setting part
  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType,
      {ValueChanged<String>? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: keyboardType,
      cursorColor: Colors.red,
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _selectedFrequency,
      items: _frequencyOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Frequency',
        labelStyle: TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onChanged: (newValue) {
        setState(() {
          _selectedFrequency = newValue!;
        });
      },
    );
  }

  Widget _buildDatePickerTextField() {
    return TextField(
      controller: _startDateController,
      decoration: InputDecoration(
        labelText: 'Start Date',
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today_outlined, color: Colors.red),
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
                _calculateEndDate();
              });
            }
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.red,
    );
  }

  Widget _buildEndDatePickerTextField() {
    return TextField(
      controller: _endDateController,
      decoration: InputDecoration(
        labelText: 'End Date',
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today_outlined, color: Colors.red),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _endDateController.text =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.red,
    );
  }

  Widget _buildTimePickerTextField() {
    return TextField(
      controller: _startTimeController,
      decoration: InputDecoration(
        labelText: 'Start Time',
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(Icons.access_time_outlined, color: Colors.red),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (pickedTime != null) {
              setState(() {
                _startTimeController.text = pickedTime.format(context);
              });
            }
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.red,
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
      selectedColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isSelected ? Colors.red : Colors.grey),
      ),
    );
  }
/*List to display the medicine reminders fetched when edit icon click populate to the _populateFieldsForEditing(medicine) or if delete remove the
  prescription from medicine list.*/
  Widget _buildMedicineList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.black),
          ),
          child: ListTile(
            title: Text(
              'Medicine Name: ${medicine['name']}  Dosage: ${medicine['dosage']}',
              style: TextStyle(color: Colors.black),
            ),
            subtitle: Text(
              'Frequency: ${medicine['interval']} time/s \t Duration: ${medicine['days']} days \t Pill Intake: ${medicine['pillintake']} \n Start Date: ${medicine['startDate']} \n End Date: ${medicine['endDate']} \n Additional Information: ${medicine['additionalInstructions']} \n Start Time: ${medicine['startTime']} \n Days of Week: ${medicine['selectedDays'].join(', ')}',
              style: TextStyle(color: Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    _populateFieldsForEditing(medicine);
                    setState(() {
                      _medicines.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _medicines.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
//When set alarm button is clicked
  Widget _buildSetAlarmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _onTapSubmitBtn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Set Alarm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
