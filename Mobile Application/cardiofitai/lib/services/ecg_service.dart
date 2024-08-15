import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference ecgCollectionReference = _firestore.collection("ECG");

class EcgService {
  static Future<Response> addECG(
      String email,
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
      List<double> v6Data) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "email": email,
      "l1": l1Data,
      "l2": l2Data,
      "l3": l3Data,
      "avr": avrData,
      "avl": avlData,
      "avf": avfData,
      "v1": v1Data,
      "v2": v2Data,
      "v3": v3Data,
      "v4": v4Data,
      "v5": v5Data,
      "v6": v6Data,
      "datetime": Timestamp.now()
      // use data["datetime"].toDate() when retrieving
    };

    // String date = DateFormat('yyyy-MM-dd').format(dateTime); // Example: 2024-08-15
    // String time = DateFormat('HH:mm:ss').format(dateTime);   // Example: 14:30:00

    await ecgCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "ECG Record Created";
    }).catchError((e) {
      response.code = 500;
      response.message = e.toString();
    });

    return response;
  }
}
