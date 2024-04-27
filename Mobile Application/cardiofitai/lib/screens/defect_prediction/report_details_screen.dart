import 'package:flutter/material.dart';

class ReportDetails extends StatelessWidget{
  final bool isNormal;
  final bool hasMyocardialInfarction;

  ReportDetails({required this.isNormal, required this.hasMyocardialInfarction});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('ECG Diagnosis'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                isNormal?'ECG: Normal' : 'ECG: Myocardial Infarction',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(height: 20.0),
              if(hasMyocardialInfarction)
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Urgent Action Required!'),
                            content: Text('Please visit a doctor immediately'),
                            actions : <Widget>[
                              TextButton(onPressed: () {
                                Navigator.of(context).pop();
                              },
                                child: Text('OK'),
                              )
                            ]
                          );
                        },
                      );
                },
                child: Text('Visit Doctor'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}