import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference ocrDataTempCollectionReference =
_firestore.collection("OCR_Data_Temp");

class OCRServiceTemp {
  static Future<Response> addReportContent(String username,int reportID, String content) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "username": username,
      "reportID": reportID,
      "content": content
    };

    await ocrDataTempCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Test Record Created";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<QuerySnapshot<Object?>> getUserReportsNo() async {
    return await ocrDataTempCollectionReference
        .orderBy('reportID', descending: true).limit(1).get();
  }
}
