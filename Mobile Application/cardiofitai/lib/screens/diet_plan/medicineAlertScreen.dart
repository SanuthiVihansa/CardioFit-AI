import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage({super.key});

  @override
  State<MedicineAlertPage> createState() => _MedicineAlertPageState();
}

class _MedicineAlertPageState extends State<MedicineAlertPage> {
  late String _selectedInterval;
  final List<String> _intervals = ['1', '2', '4', '6', '8', '12', '24'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Medicine Name *',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dosage in mg',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('Medicine Type'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.medical_information_rounded, size: 50),
                    Text('Bottle'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.masks, size: 50),
                    Text('Pill'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.adb_rounded, size: 50),
                    Text('Syringe'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.tablet, size: 50),
                    Text('Tablet'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Interval Selection *'),
            Row(
              children: [
                Text('Remind me every '),
                DropdownButton<String>(
                  hint: Text('Select an interval'),
                  value: _selectedInterval,
                  items: _intervals.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedInterval = newValue!;
                    });
                  },
                ),
                Text(' hours'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}