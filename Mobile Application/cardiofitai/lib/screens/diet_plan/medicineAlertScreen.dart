import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/prescription_reading_api_service.dart';

class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage({super.key});

  @override
  State<MedicineAlertPage> createState() => _MedicineAlertPageState();
}

class _MedicineAlertPageState extends State<MedicineAlertPage> {
  final apiService = ApiService();
  String _selectedInterval = '1';
  final List<String> _intervals = ['1', '2', '4', '6', '8', '12', '24'];
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _pillIntakeController = TextEditingController();
  final List<Map<String, String>> _medicines = [];
  File? pickedImage;
  XFile? image;
  String prescriptionInfo = '';
  bool detecting = false;

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

  void _addMedicinesFromPrescriptionInfo() {
    try {
      final List<dynamic> parsedInfo = jsonDecode(prescriptionInfo);
      for (var medicineInfo in parsedInfo) {
        final Map<String, String> medicine = {
          'name': medicineInfo['Medicine Name'] ?? '',
          'dosage': medicineInfo['Dosage'] ?? '',
          'interval': medicineInfo['Intake Frequency'] ?? '',
          'days': medicineInfo['Duration'] ?? '',
          'pillIntakePerTime': medicineInfo['Pill Intake per Time'] ?? '',
        };
        setState(() {
          _medicines.add(medicine);
        });
      }
    } catch (error) {
      _showErrorSnackBar('Failed to parse prescription info');
    }
  }

  void _populateFieldsForEditing(Map<String, String> medicine) {
    _medicineNameController.text = medicine['name'] ?? '';
    _dosageController.text = medicine['dosage'] ?? '';
    _selectedInterval = _intervals.contains(medicine['interval']) ? medicine['interval']! : '1';
    _daysController.text = medicine['days'] ?? '';
    _pillIntakeController.text = medicine['pillIntakePerTime'] ?? '';
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
              if (prescriptionInfo.isNotEmpty) // Ensure the prescriptionInfo is not empty
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _medicineNameController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name *',
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Interval Selection'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Remind me every',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedInterval,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedInterval = newValue!;
                            });
                          },
                          items: _intervals.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _daysController,
                      decoration: InputDecoration(
                        labelText: 'Number of days',
                        border: OutlineInputBorder(),
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _medicines.add({
                      'name': _medicineNameController.text,
                      'dosage': _dosageController.text,
                      'interval': _selectedInterval,
                      'days': _daysController.text,
                      'pillIntakePerTime': _pillIntakeController.text,
                    });
                    _medicineNameController.clear();
                    _dosageController.clear();
                    _daysController.clear();
                    _pillIntakeController.clear();
                    _selectedInterval = '1';
                  });
                },
                child: Text('Add'),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final medicine = _medicines[index];
                  return ListTile(
                    title: Text('${medicine['name']} - ${medicine['dosage']} mg'),
                    subtitle: Text(
                        'Every ${medicine['interval']} hours for ${medicine['days']} days. Pill Intake per Time: ${medicine['pillIntakePerTime']}'),
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
                onPressed: () {},
                child: Text('Set Alarm'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
