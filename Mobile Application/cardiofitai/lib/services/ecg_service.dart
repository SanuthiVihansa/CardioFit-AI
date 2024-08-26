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

  // static Future<QuerySnapshot<Object?>> getEcgHistory(String email) async {
  //   return await ecgCollectionReference
  //       .where("email", isEqualTo: email)
  //       .orderBy("datetime", descending: true).s
  //       .get();
  // }

  static Future<List<Map<String, dynamic>>> getEcgHistory(String email) async {
    QuerySnapshot<Object?> snapshot = await ecgCollectionReference
        .where("email", isEqualTo: email)
        .orderBy("datetime", descending: true)
        .get();

    // Map the documents to a list of maps containing only the email and datetime fields
    List<Map<String, dynamic>> ecgHistory = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'email': data['email'],
        "l1": data['l1'],
        "l2": data['l2'],
        "l3": data['l3'],
        "avr": data['avr'],
        "avl": data['avl'],
        "avf": data['avf'],
        "v1": data['v1'],
        "v2": data['v2'],
        "v3": data['v3'],
        "v4": data['v4'],
        "v5": data['v5'],
        "v6": data['v6'],
        'datetime': data['datetime'],
      };
    }).toList();

    return ecgHistory;
  }
}
