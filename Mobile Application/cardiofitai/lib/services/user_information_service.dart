import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference userCollectionReference =
_firestore.collection("User");

//Get User for Login
class UserLoginService {
  static Future<QuerySnapshot<Object?>> getUserByEmail(String email) async {
    return await userCollectionReference
        .where("email", isEqualTo: email)
        .get();
  }
//Create User when sign up
  static Future<Response> addAccount(
      String email,
      String password,
      ) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "email": email,
      "password": password,

    };

    await userCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Account Created";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }


  static Future<Response> updateUser(User user) async {
    Response response = Response();

    try {
      QuerySnapshot querySnapshot = await userCollectionReference
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
        };

        await document.reference.update(data); // Update the document
        response.code = 200;
        response.message = "User Information updated!";
      } else {
        response.code = 404;
        response.message = "User not found";
      }
    } catch (e) {
      response.code = 500;
      // response.message = e.toString();
      response.message = "Server Error";
    }

    return response;
  }


}

