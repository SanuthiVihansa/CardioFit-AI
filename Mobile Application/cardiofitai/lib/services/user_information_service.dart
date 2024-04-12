import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference employeeCollectionReference =
_firestore.collection("Employee");

class EmployeeOnboardingService {
  static Future<QuerySnapshot<Object?>> getUserByEmail(String email) async {
    return await employeeCollectionReference
        .where("email", isEqualTo: email)
        .get();
  }

  static Future<Response> updateEmployee(User user) async {
    Response response = Response();

    try {
      QuerySnapshot querySnapshot = await employeeCollectionReference
          .where("email", isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot document = querySnapshot.docs[0];

        Map<String, dynamic> data = <String, dynamic>{
          "name": user.name,
          "email": user.email,
          "age": user.age,
          "height": user.height,
          "weight": user.weight,
          "phone": user.phone,

        await document.reference.update(data); // Update the document
        response.code = 200;
        response.message = "Employee updated!";
      } else {
        response.code = 404;
        response.message = "Employee not found with the specified email";
      }
    } catch (e) {
      response.code = 500;
      response.message = e.toString();
    }

    return response;
  }

}

