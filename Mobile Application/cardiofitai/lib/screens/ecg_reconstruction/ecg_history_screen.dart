import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/ecg_reconstruction/all_lead_display_screen_from_history.dart';
import 'package:cardiofitai/services/ecg_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EcgHistoryScreen extends StatefulWidget {
  const EcgHistoryScreen(this._user, {super.key});

  final User _user;

  @override
  State<EcgHistoryScreen> createState() => _EcgHistoryScreenState();
}

class _EcgHistoryScreenState extends State<EcgHistoryScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  List<Map<String, dynamic>> _ecgHistoryData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEcgHistory();
  }

  Future<void> _loadEcgHistory() async {
    _ecgHistoryData = await EcgService.getEcgHistory(widget._user.email);
    setState(() {
      _isLoading = false;
    });
  }

  void _onTapSingleRecord(
      List<double> l1Data,
      List<double> l2Data,
      List<double> l3Data,
      List<double> avrData,
      List<double> avlData,
      List<double> avfData,
      List<double> v1Data,
      List<double> v2Data,
      List<double> v3Data,
      List<double> v4Data,
      List<double> v5Data,
      List<double> v6Data,
      Timestamp datetime) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => AllLeadDisplayScreenFromHistory(
            widget._user,
            l1Data,
            l2Data,
            l3Data,
            avrData,
            avlData,
            avfData,
            v1Data,
            v2Data,
            v3Data,
            v4Data,
            v5Data,
            v6Data,
            datetime)));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "ECG History",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text("Loading")],
                ),
              )
            : _ecgHistoryData.length == 0
                ? Center(
                    child: Text("No ECG Hostory"),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: _width / (_devWidth / 80),
                        vertical: _height / (_devHeight / 20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: _height / (_devHeight / 20)),
                          child: Text(
                            "Tap to View Your ECG Reports",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: _height / (_devHeight / 20)),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: _ecgHistoryData.length,
                              itemBuilder: (context, index) => Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.monitor_heart),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text("${index + 1}"),
                                            Text(
                                              "Date: ${DateFormat('yyyy-MM-dd').format(_ecgHistoryData[index]["datetime"].toDate())}",
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: _width /
                                                      (_devWidth / 20)),
                                              child: Text(
                                                "Time: ${DateFormat('HH:mm:ss').format(_ecgHistoryData[index]["datetime"].toDate())}",
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        onTap: () {
                                          _onTapSingleRecord(
                                              _ecgHistoryData[index]["l1"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["l2"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["l3"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["avr"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["avl"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["avf"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v1"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v2"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v3"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v4"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v5"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]["v6"]
                                                  .cast<double>(),
                                              _ecgHistoryData[index]
                                                  ["datetime"]);
                                        },
                                      ),
                                      Divider()
                                    ],
                                  )),
                        ),
                      ],
                    ),
                  ));
  }
}
