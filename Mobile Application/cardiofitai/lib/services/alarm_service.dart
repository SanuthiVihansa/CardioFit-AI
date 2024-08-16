import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference alarmcollectionReference =
_firestore.collection("Alarm");

class AlarmService {
  //Get all alarms created
  static Future<QuerySnapshot<Object?>> getCreatedAlarms(String email) async {
    return await alarmcollectionReference.where("userEmail", isEqualTo: email)
        .get();
  }

  //create medicineReminder
  static Future<Response> createAlarm(
      int reminderNo,
      String userEmail,
      String medicineName,
      String dosage,
      String pillIntake,
      String frequency,
      int days,
      String startDate,
      String additionalInstructions,
      List<String> daysOfWeek,
      String startTime,
      ) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "reminderNo": reminderNo,
      "userEmail": userEmail,
      "medicineName": medicineName,
      "dosage": dosage,
      "pillIntake": pillIntake,
      'frequency': frequency,
      "days": days,
      "startDate": startDate,
      "additionalInstructions": additionalInstructions,
      "daysOfWeek": daysOfWeek,
      "startTime": startTime,
    };

    await alarmcollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Reminder Saved";
    }).catchError((onError) {
      response.code = 500;
      response.message = onError.toString();
    });
    return response;
  }

}