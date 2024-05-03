import 'package:flutter/material.dart';
import 'report_details_screen.dart';

// class ReportHome extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Background GIF
//         Positioned.fill(
//           child: Image.asset(
//             'assets/defect_prediction/ECG Gif.gif', // Replace 'background.gif' with the path to your GIF file
//             fit: BoxFit.cover,
//           ),
//         ),
//         Scaffold(
//           appBar: AppBar(
//             title: Text('Your Report Status'),
//             backgroundColor: Colors.red,
//           ),
//           backgroundColor: Colors.transparent, // Make the scaffold background transparent
//           body: Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     'Your Report Status',
//                     style: TextStyle(fontSize: 24.0),
//
//                   ),
//                   SizedBox(height: 20.0),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ReportDetails(
//                             isNormal: false, // Example values, replace with actual data
//                             hasMyocardialInfarction: true, // Example values, replace with actual data
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text('Check Now'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'report_details_screen.dart';

class ReportHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background GIF
        Positioned.fill(
          child: Image.asset(
            'assets/defect_prediction/ECG Gif.gif',
            // Replace 'background.gif' with the path to your GIF file
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(
              'Your Report Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
          backgroundColor: Colors.transparent,
          // Make the scaffold background transparent
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Your Report Status',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReportDetailsScreen(), // Change to your desired screen
                        ),
                      );
                    },
                    child: Text('Predict Now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
