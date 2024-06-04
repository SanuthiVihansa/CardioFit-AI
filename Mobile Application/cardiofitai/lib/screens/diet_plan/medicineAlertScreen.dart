import 'dart:convert';
import 'dart:io';
import 'package:cardiofitai/screens/diet_plan/api_key.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage({super.key});

  @override
  State<MedicineAlertPage> createState() => _MedicineAlertPageState();
}

class _MedicineAlertPageState extends State<MedicineAlertPage> {
  String _selectedInterval = '1';
  final List<String> _intervals = ['1', '2', '4', '6', '8', '12', '24'];
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final List<Map<String, String>> _medicines = [];
  File? pickedImage;
  XFile? image;
  String apikey = APIKey.apiKey;

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });

      Future<String> encodeImage(String imagePath) async {
        final bytes = await File(imagePath).readAsBytes();
        return base64Encode(bytes);
      }

      String base64Image = await encodeImage(image.path);

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apikey"
      };

      Map<String, dynamic> payload = {
        "model": "gpt-4-vision-preview",
        "messages": [
          {
            "role": "system",
            "content": "You are an assistant that can understand and describe images."
          },
          {
            "role": "user",
            "content": "What’s in this image?"
          }
        ],
        "image": "data:image/jpeg;base64,$base64Image",
        "max_tokens": 300
      };

      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: headers,
        body: jsonEncode(payload),
      );

      print(response.body);
    }
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
                onPressed: _pickImage,
                child: Text("Attach Report"),
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _medicines.add({
                      'name': _medicineNameController.text,
                      'dosage': _dosageController.text,
                      'interval': _selectedInterval,
                      'days': _daysController.text,
                    });
                    _medicineNameController.clear();
                    _dosageController.clear();
                    _daysController.clear();
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
                        'Every ${medicine['interval']} hours for ${medicine['days']} days'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Populate fields with current data for editing
                            _medicineNameController.text = medicine['name']!;
                            _dosageController.text = medicine['dosage']!;
                            _selectedInterval = medicine['interval']!;
                            _daysController.text = medicine['days']!;
                            // Remove the current item from the list
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
