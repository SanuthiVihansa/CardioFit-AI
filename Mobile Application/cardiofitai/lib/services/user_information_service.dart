import 'dart:io';

import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference userCollectionReference =
    _firestore.collection("User");

//Get User for Login
class UserLoginService {
  static Future<QuerySnapshot<Object?>> getUserByEmail(String email) async {
    return await userCollectionReference.where("email", isEqualTo: email).get();
  }

//Create User when sign up
  static Future<Response> addAccount(
      String name,
      String email,
      String password,
      String age,
      String height,
      String weight,
      String bmi,
      String dob,
      String activeLevel,
      String type,
      String bloodGlucoseLevel,
      String bloodCholestrolLevel,
      String cardiacCondition,
      String bloodTestType,
      String memberName,
      String memberRelationship,
      String memberPhone,
      bool newUser
      ) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "name": name,
      "email": email,
      "password": password,
      "age": age,
      "height": height,
      "weight": weight,
      "bmi": bmi,
      "dob": dob,
      "activeLevel": activeLevel,
      "type": type,
      "bloodGlucoseLevel": bloodGlucoseLevel,
      "bloodCholestrolLevel": bloodCholestrolLevel,
      "cardiacCondition": cardiacCondition,
      "bloodTestType": bloodTestType,
      "memberName": memberName,
      "memberRelationship": memberRelationship,
      "memberPhone": memberPhone,
      "newUser":newUser
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
          "bmi": user.bmi,
          "dob": user.dob,
          "activeLevel": user.activeLevel,
          "type": user.type,
          "bloodGlucoseLevel": user.bloodGlucoseLevel,
          "bloodCholestrolLevel": user.bloodCholestrolLevel,
          "cardiacCondition": user.cardiacCondition,
          "bloodTestType": user.bloodTestType,
          "memberName" :user.memberName,
          "memberRelationship" : user.memberRelationship,
          "memberPhoneNo": user.memberPhoneNo,
          "newUser":user.newUser
        };

        await document.reference.update(data); // Update the document
        response.code = 200;
        response.message = "User Information updated!";

        String userData = '{"name" : "' +
            data["name"] +
            '", "email" : "' +
            data["email"] +
            '", "password" : "' +
            data["password"] +
            '", "age" : "' +
            data["age"] +
            '", "height" : "' +
            data["height"] +
            '", "weight" : "' +
            data["weight"] +
            '", "bmi" : "' +
            data["bmi"] +
            '","dob" : "' +
            data["dob"] +
            '","activeLevel" : "' +
            data["activeLevel"] +
            '", "type" : "' +
            data["type"] +
            '", "bloodGlucoseLevel" : "' +
            data["bloodGlucoseLevel"] +
            '", "bloodCholestrolLevel" : "' +
            data["bloodCholestrolLevel"] +
            '", "cardiacCondition" : "' +
            data["cardiacCondition"] +
            '", "bloodTestType" : "' +
            data["bloodTestType"] +
            '", "memberName" : "' +
            data["memberName"] +
            '", "memberRelationship" : "' +
            data["memberRelationship"] +
            '", "memberPhone" : "' +
            data["memberPhone"] +
            '", "newUser" : "' +
            data["newUser"].toString() +
            '"}';

        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        File file = File('$path/userdata.txt');
        file.writeAsString(userData);






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

  //Update new user parameter
  static Future<Response> updateNewUser(User user) async {
    Response response = Response();

    try {
      // Query the collection to find the user by email
      QuerySnapshot querySnapshot = await userCollectionReference
          .where("email", isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        QueryDocumentSnapshot document = querySnapshot.docs[0];

        // Create a map containing only the newUser field
        Map<String, dynamic> data = <String, dynamic>{
          "newUser": user.newUser
        };

        // Update the document with the newUser field
        await document.reference.update(data);

        response.code = 200;
        response.message = "User Information updated!";
        String userData = '{"newUser" : "' + data["newUser"].toString() + '"}';

        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        File file = File('$path/userdata.txt');
        file.writeAsString(userData);

      } else {
        response.code = 404;
        response.message = "User not found";
      }
    } catch (e) {
      response.code = 500;
      response.message = "Server Error";
    }

    return response;
  }


}
