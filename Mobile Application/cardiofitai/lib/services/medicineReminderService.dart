import 'package:cardiofitai/models/response.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference medicineReminderCollectionReference =
    _firestore.collection("MedicineReminder");

class MedicineReminderService {
  //create medicineReminder
  static Future<Response> medicineReminder(
      int reminderNo,
      String userEmail,
      String medicineName,
      String dosage,
      String pillIntake,
      String interval,
      int days,
      String startDate,
      String additionalInstructions,
      List<String> daysOfWeek,
      String startTime) async {
    Response response = Response();
    Map<String, dynamic> data = <String, dynamic>{
      "reminderNo": reminderNo,
      "userEmail": userEmail,
      "medicineName": medicineName,
      "dosage": dosage,
      "pillIntake": pillIntake,
      "interval": interval,
      "days": days,
      "startDate": startDate,
      "additionalInstructions": additionalInstructions,
      "daysOfWeek": daysOfWeek,
      "startTime": startTime
    };

    await medicineReminderCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Reminder Saved";
    }).catchError((onError) {
      response.code = 500;
      response.message = onError;
    });
    return response;
  }
}
