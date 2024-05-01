import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/navbar_component.dart';
import '../../models/user.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen(this.user, {super.key});

  final User user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double _width;

  // ignore: unused_field
  late double _height;

  final double _devWidth = 753.4545454545455;

  // ignore: unused_field
  final double _devHeight = 392.72727272727275;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _onClickEcgMonitoringBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                const ECGMonitoringHomeScreen()));
  }

  void _onClickDietPlanBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DietHomePage(widget.user)));
  }

  void _onClickReportingAndAnalyticsBtn() {}

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "CardioFit AI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      drawer: LeftNavBar(
          user: widget.user,
          name: widget.user.name,
          email: widget.user.email,
          width: 150,
          height: 300),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Welcome !",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _width / (_devWidth / 20),
                color: Colors.red),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _onClickEcgMonitoringBtn();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(_width / (_devWidth / 160.0),
                        _height / (_devHeight / 40)), // Button width and height
                  ),
                ),
                child: Text(
                  "ECG Monitoring",
                  style: TextStyle(fontSize: _width / (_devWidth / 10)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _onClickDietPlanBtn();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(_width / (_devWidth / 160.0),
                        _height / (_devHeight / 40)), // Button width and height
                  ),
                ),
                child: Text(
                  "Diet Plan",
                  style: TextStyle(fontSize: _width / (_devWidth / 10)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _onClickReportingAndAnalyticsBtn();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(_width / (_devWidth / 160.0),
                        _height / (_devHeight / 40)), // Button width and height
                  ),
                ),
                child: Text(
                  "Reporting & Analytics",
                  style: TextStyle(fontSize: _width / (_devWidth / 10)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
