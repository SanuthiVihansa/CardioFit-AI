import 'package:flutter/material.dart';
import 'report_details_screen.dart';
class ReportHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Report Status'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Your Report Status',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetails(
                        isNormal: false, // Example values, replace with actual data
                        hasMyocardialInfarction: true, // Example values, replace with actual data
                      ),
                    ),
                  );
                },
                child: Text('Check Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
