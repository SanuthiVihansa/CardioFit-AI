import 'package:flutter/material.dart';

import 'aiSchedule.dart';

class SetMedicineReminderScreen extends StatefulWidget {
  @override
  _SetMedicineReminderScreenState createState() =>
      _SetMedicineReminderScreenState();
}

class _SetMedicineReminderScreenState extends State<SetMedicineReminderScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Set Medicine Reminder',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildCardButton(
                        'assets/ai_icon.png',
                        'AI Schedule',
                        'Schedule medicine reminders using AI',
                        screenWidth,
                        context,
                            () {
                          // Navigate to AI Schedule Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AISchedule(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildCardButton(
                        'assets/manual_icon.png',
                        'Manual Schedule',
                        'Set medicine reminders manually',
                        screenWidth,
                        context,
                            () {
                          // Navigate to Manual Schedule Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManualScheduleScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(String imagePath, String title, String subtitle,
      double screenWidth, BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 6,
        child: Container(
          height: 500,  // Reduced height to avoid overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 350,  // Height of the image container
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: screenWidth * 0.04, // Adjusted font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.02, // Adjusted font size
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screens for navigation
class AIScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Schedule')),
      body: Center(child: Text('AI Schedule Screen')),
    );
  }
}

class ManualScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Schedule')),
      body: Center(child: Text('Manual Schedule Screen')),
    );
  }
}
