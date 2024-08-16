// import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
// import 'package:cardiofitai/screens/defect_prediction/report_home_screen.dart';
// import 'package:cardiofitai/screens/diet_plan/diet_,mainhome_page.screen.dart';
// import 'package:cardiofitai/screens/ecg_comparison_and_analysis/analysis_file_selection_screen.dart';
// import 'package:cardiofitai/screens/ecg_comparison_and_analysis/comparison_file_selection_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../components/navbar_component.dart';
// import '../../models/user.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen(this.user, {super.key});
//
//   final User user;
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late double _width;
//
//   // ignore: unused_field
//   late double _height;
//
//   final double _devWidth = 753.4545454545455;
//
//   // ignore: unused_field
//   final double _devHeight = 392.72727272727275;
//
//   @override
//   void initState() {
//     super.initState();
//
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//   }
//
//   void _onClickEcgAnalysisBtn() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (BuildContext context) =>
//                 const AnalysisFileSelectionScreen()));
//   }
//
//   void _onClickEcgComparisonBtn() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (BuildContext context) =>
//                 const ComparisonFileSelectionScreen()));
//   }
//
//   void _onClickDietPlanBtn() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (BuildContext context) => DietHomePage(widget.user)));
//   }
//
//   void _onClickDiseasePredictionBtn() {
//     Navigator.push(context,
//         MaterialPageRoute(builder: (BuildContext context) => ReportHome()));
//   }
//
//   void _onClickReportingAndAnalyticsBtn() {}
//
//   Widget DietAdvice() {
//     double halfScreenWidth = (MediaQuery.of(context).size.width / 2) - 50;
//
//     return Container(
//       width: halfScreenWidth,
//       margin: const EdgeInsets.only(right: 20, bottom: 10),
//       child: Material(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//         elevation: 4,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Flexible(
//               fit: FlexFit.loose,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 child: Image.asset(
//                   'assets/dieteryimage.jpg',
//                   width: halfScreenWidth,
//                   fit: BoxFit.fitWidth,
//                 ),
//               ),
//             ),
//             Flexible(
//               fit: FlexFit.tight,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Center(
//                     child: Text("Dietery Advice",
//                         style: TextStyle(
//                             color: Colors.blueGrey,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700)),
//                   ),
//                   Center(
//                       child:
//                       Text("Know the right amount of nutrition you need")),
//                   SizedBox(height: 10)
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget ReportAnalaysis() {
//     double halfScreenWidth = (MediaQuery.of(context).size.width / 2) - 50;
//
//     return Container(
//       width: halfScreenWidth,
//       margin: const EdgeInsets.only(right: 20, bottom: 10),
//       child: Material(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//         elevation: 4,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Flexible(
//               fit: FlexFit.loose,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 child: Image.asset(
//                   'assets/reportanalysis.jpg',
//                   width: halfScreenWidth,
//                   fit: BoxFit.fitWidth,
//                 ),
//               ),
//             ),
//             Flexible(
//               fit: FlexFit.tight,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Center(
//                     child: Text("Report Analysis",
//                         style: TextStyle(
//                             color: Colors.blueGrey,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700)),
//                   ),
//                   Center(child: Text("Scan and analyse report information")),
//                   SizedBox(height: 10)
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget MedicineAlert() {
//     double halfScreenWidth = (MediaQuery.of(context).size.width / 2) - 50;
//
//     return Container(
//       width: halfScreenWidth,
//       margin: const EdgeInsets.only(right: 20, bottom: 10),
//       child: Material(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//         elevation: 4,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Flexible(
//               fit: FlexFit.loose,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 child: Image.asset(
//                   'assets/reportanalysis.jpg',
//                   width: halfScreenWidth,
//                   fit: BoxFit.fitWidth,
//                 ),
//               ),
//             ),
//             Flexible(
//               fit: FlexFit.tight,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Center(
//                     child: Text("Notification Service ",
//                         style: TextStyle(
//                             color: Colors.blueGrey,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700)),
//                   ),
//                   Center(
//                       child: Text(
//                           "Upload prescription and set reminders for pill intake")),
//                   SizedBox(height: 10)
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _width = MediaQuery.of(context).size.width;
//     _height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         leading: IconButton(
//           color: Colors.white,
//           icon: const Icon(Icons.menu),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//         title: const Text(
//           "CardioFit AI",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//       ),
//       drawer: LeftNavBar(
//           user: widget.user,
//           name: widget.user.name,
//           email: widget.user.email,
//           width: 150,
//           height: 300),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text(
//             "Welcome !",
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: _width / (_devWidth / 20),
//                 color: Colors.red),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: <Widget>[
//                   SizedBox(
//                     width: 25,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to homepage
//                       Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                               builder: (BuildContext context) =>
//                                   AnalysisFileSelectionScreen()));
//                       ;
//                     },
//                     child: DietAdvice(),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to homepage
//                       Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                               builder: (BuildContext context) =>
//                                   ComparisonFileSelectionScreen()));
//                     },
//                     child: ReportAnalaysis(),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to homepage
//                       Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                               builder: (BuildContext context) =>
//                                   DietHomePage(widget.user)));
//                     },
//                     child: MedicineAlert(),
//                   ),
//                   const SizedBox(
//                     width: 25,
//                   ),
//                 ],
//               ),
//             ),
//           )
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           //   children: [
//           //     ElevatedButton(
//           //       onPressed: () {
//           //         _onClickEcgAnalysisBtn();
//           //       },
//           //       style: ButtonStyle(
//           //         fixedSize: MaterialStateProperty.all<Size>(
//           //           Size(_width / (_devWidth / 160.0),
//           //               _height / (_devHeight / 40)), // Button width and height
//           //         ),
//           //       ),
//           //       child: Text(
//           //         "ECG Analysis",
//           //         style: TextStyle(fontSize: _width / (_devWidth / 10)),
//           //       ),
//           //     ),
//           //     ElevatedButton(
//           //       onPressed: () {
//           //         _onClickEcgComparisonBtn();
//           //       },
//           //       style: ButtonStyle(
//           //         fixedSize: MaterialStateProperty.all<Size>(
//           //           Size(_width / (_devWidth / 160.0),
//           //               _height / (_devHeight / 40)), // Button width and height
//           //         ),
//           //       ),
//           //       child: Text(
//           //         "ECG Comparison",
//           //         style: TextStyle(fontSize: _width / (_devWidth / 10)),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           //   children: [
//           //     ElevatedButton(
//           //       onPressed: () {
//           //         _onClickDietPlanBtn();
//           //       },
//           //       style: ButtonStyle(
//           //         fixedSize: MaterialStateProperty.all<Size>(
//           //           Size(_width / (_devWidth / 160.0),
//           //               _height / (_devHeight / 40)), // Button width and height
//           //         ),
//           //       ),
//           //       child: Text(
//           //         "Diet Plan",
//           //         style: TextStyle(fontSize: _width / (_devWidth / 10)),
//           //       ),
//           //     ),
//           //     ElevatedButton(
//           //       onPressed: () {
//           //         _onClickDiseasePredictionBtn();
//           //       },
//           //       style: ButtonStyle(
//           //         fixedSize: MaterialStateProperty.all<Size>(
//           //           Size(_width / (_devWidth / 160.0),
//           //               _height / (_devHeight / 40)), // Button width and height
//           //         ),
//           //       ),
//           //       child: Text(
//           //         "Disease Prediction",
//           //         style: TextStyle(fontSize: _width / (_devWidth / 10)),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cardiofitai/components/navigation_panel_component.dart';
import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
import 'package:cardiofitai/screens/defect_prediction/report_home_screen.dart';
import 'package:cardiofitai/screens/diet_plan/diet_,mainhome_page.screen.dart';
import 'package:cardiofitai/screens/ecg_comparison_and_analysis/analysis_file_selection_screen.dart';
import 'package:cardiofitai/screens/ecg_comparison_and_analysis/comparison_file_selection_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/for_future_use/pmb_device_connection_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/for_future_use/real_time_record.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/electrode_placement_instructions_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/serial_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/navbar_component.dart';
import '../../models/user.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen(this.user, {super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => screen),
    );
  }

  void _onClickEcgAnalysisBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                const AnalysisFileSelectionScreen()));
  }

  void _onClickEcgComparisonBtn() {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) =>
    //             const ComparisonFileSelectionScreen()));
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) => const SerialMonitor2()));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ElectrodePlacementInstructionsScreen()));
  }

  void _onClickDietPlanBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DietHomePage(widget.user)));
  }

  void _onClickDiseasePredictionBtn() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ReportHome()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Cardio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Fit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: ' AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFF5B61),
      ),
      // drawer: LeftNavBar(
      //   user: widget.user,
      //   name: widget.user.name,
      //   email: widget.user.email,
      //   width: 150,
      //   height: 300,
      // ),
      body: Row(
        children: [
          NavigationPanelComponent("dashboard", widget.user),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Your dashboard content goes here
                  ProfileHeader(user: widget.user),
                  CurrentHealthInfo(user: widget.user),
                  ActivitiesGraph(),

                  // Additional widgets...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            child: Image.asset("assets/profile_avatar.png"),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('${user.age} years'),
              SizedBox(height: 8),
              Row(
                children: [
                  InfoCard(label: 'Weight', value: '${user.weight} kg'),
                  SizedBox(width: 8),
                  InfoCard(label: 'Height', value: '${user.height} m'),
                  SizedBox(width: 8),
                  InfoCard(label: 'BMI', value: '${user.bmi} kg/m2'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.redAccent[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CurrentHealthInfo extends StatelessWidget {
  final User user;

  const CurrentHealthInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatCard(label: 'Blood Sugar Level', value: user.bloodGlucoseLevel),
            StatCard(
                label: 'Cholestrol Level', value: user.bloodCholestrolLevel),
            StatCard(label: 'Heart Condition', value: user.cardiacCondition),
            StatCard(label: 'BMI status', value: user.bmi),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey, fontSize: 12),
        ),
      ],
    );
  }
}

class ActivitiesGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ECG Graphical Illustrations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            color: Colors.blueGrey[50], // Placeholder for graph
            child: Center(
              child: Text('Graph Placeholder'),
            ),
          ),
        ],
      ),
    );
  }
}
