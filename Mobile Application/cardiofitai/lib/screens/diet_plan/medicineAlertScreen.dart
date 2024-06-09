import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/prescription_reading_api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage({super.key});

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
  final List<Map<String, String>> _medicines = [];
  bool precautionLoading = false;
  String diseasePrecautions = '';
  File? pickedImage;
  XFile? image;
  String prescriptionInfo = '';
  bool detecting = false;
  String _selectedFrequency = 'once';
  final List<String> _frequencyOptions = ['once', 'twice', 'thrice', 'four times'];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
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
      prescriptionInfo = await apiService.sendImageToGPT4Vision(image: pickedImage!);
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
    if (frequency.contains('thrice') || frequency.contains('three times')) return 'thrice';
    if (frequency.contains('four times')) return 'four times';
    if (frequency.contains('q.d') || frequency.contains('qd') || frequency.contains('daily') || frequency.contains('once daily')) return 'once';
    if (frequency.contains('b.i.d') || frequency.contains('bid') || frequency.contains('twice daily')) return 'twice';
    if (frequency.contains('t.i.d') || frequency.contains('tid') || frequency.contains('three times daily')) return 'thrice';
    if (frequency.contains('q.i.d') || frequency.contains('qid') || frequency.contains('four times daily')) return 'four times';
    return 'once';
  }

  int normalizeDuration(String duration) {
    duration = duration.toLowerCase();
    if (duration.contains('one week') || duration.contains('1/52')) return 7;
    if (duration.contains('two weeks') || duration.contains('2/52')) return 14;
    if (duration.contains('three weeks') || duration.contains('3/52')) return 21;
    if (duration.contains('four weeks') || duration.contains('4/52') || duration.contains('a month')) return 28;
    final match = RegExp(r'(\d+) day').firstMatch(duration);
    if (match != null) return int.parse(match.group(1)!);
    return 0; // Default to 0 if unable to parse
  }

  void _addMedicinesFromPrescriptionInfo() {
    try {
      final jsonStartIndex = prescriptionInfo.indexOf('[');
      final jsonEndIndex = prescriptionInfo.lastIndexOf(']') + 1;

      if (jsonStartIndex != -1 && jsonEndIndex != -1) {
        final jsonString = prescriptionInfo.substring(jsonStartIndex, jsonEndIndex);

        final List<dynamic> parsedInfo = jsonDecode(jsonString);
        for (var medicineInfo in parsedInfo) {
          final int days = normalizeDuration(medicineInfo['Duration'] ?? '');
          final DateTime startDate = DateTime.now();
          final DateTime endDate = startDate.add(Duration(days: days));

          final Map<String, String> medicine = {
            'name': medicineInfo['Medicine Name'] ?? '',
            'dosage': medicineInfo['Dosage'] ?? '',
            'pillintake': medicineInfo['Pill Intake'] ?? '',
            'interval': normalizeFrequency(medicineInfo['Frequency'] ?? ''),
            'days': days.toString(),
            'startDate': DateFormat('yyyy-MM-dd').format(startDate),
            'endDate': DateFormat('yyyy-MM-dd').format(endDate),
            'additionalInstructions': medicineInfo['Additional Instructions'] ?? '',
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

  void _populateFieldsForEditing(Map<String, String> medicine) {
    _medicineNameController.text = medicine['name'] ?? '';
    _dosageController.text = medicine['dosage'] ?? '';
    _selectedFrequency = medicine['interval'] ?? 'once';
    _daysController.text = medicine['days'] ?? '';
    _pillIntakeController.text = medicine['pillintake'] ?? '';
    _additionalInstructions.text = medicine['additionalInstructions'] ?? '';
    _startDateController.text = medicine['startDate'] ?? '';
    _endDateController.text = medicine['endDate'] ?? '';
  }

  void _setReminder() {
    for (var medicine in _medicines) {
      if (medicine['interval']!.isEmpty || medicine['days']!.isEmpty) {
        _showErrorSnackBar('Please edit the entry for ${medicine['name']} to include both frequency and duration.');
        return;
      }
      // Set the reminder using the provided frequency and duration
      // This part can be implemented using a local notification package, such as flutter_local_notifications
    }
    _showSuccessDialog('Reminders set successfully', '');
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

  @override
  Widget build(BuildContext context) {
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
                    Text('START CAMERA', style: TextStyle(color: Colors.blueGrey)),
                    const SizedBox(width: 10),
                    Icon(Icons.camera_alt, color: Colors.blueGrey)
                  ],
                ),
              ),
              pickedImage == null
                  ? Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Image.asset('assets/pick1.png'),
              )
                  : Container(
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white54,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    title: Text('Medicine Name: ${medicine['name']}  Dosage: ${medicine['dosage']}'),
                    subtitle: Text(
                        'Frequency: ${medicine['interval']} \t Duration: ${medicine['days']}  \t Pill Intake: ${medicine['pillintake']} \n Start Date: ${medicine['startDate']} \t End Date: ${medicine['endDate']} \n Additional Information: ${medicine['additionalInstructions']}'),
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
                onPressed: _setReminder,
                child: Text('Set Alarm'),
              )
            ],
          ),
        ),
      ),
    );
  }

  _setRemindersManuallyForm(){
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _medicineNameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _additionalInstructions,
          decoration: InputDecoration(
            labelText: 'Additional Information',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16),
        Text('Reminder setup',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _pillIntakeController,
          decoration: InputDecoration(
            labelText: 'Pill Intake per Time',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _medicines.add({
                'name': _medicineNameController.text,
                'dosage': _dosageController.text,
                'interval': _selectedFrequency,
                'days': _daysController.text,
                'pillintake': _pillIntakeController.text,
                'startDate': _startDateController.text,
                'endDate': _endDateController.text,
                'additionalInstructions': _additionalInstructions.text,
              });
              _medicineNameController.clear();
              _dosageController.clear();
              _daysController.clear();
              _pillIntakeController.clear();
              _additionalInstructions.clear();
              _startDateController.clear();
              _endDateController.clear();
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
