import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference testCollectionReference =
    _firestore.collection("Test");

class TestService {
  static Future<Response> addAccount(String email, String password) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "email": email,
      "password": password
    };

    await testCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Test Record Created";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }
}
