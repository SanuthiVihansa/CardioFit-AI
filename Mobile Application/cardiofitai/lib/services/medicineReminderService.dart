import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';
import '../models/medicine_reminder.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference medicineReminderCollectionReference =
    _firestore.collection("MedicineReminder");

class MedicineReminderService {
  //Get MedicineReminder
  static Future<QuerySnapshot<Object?>> getAllUserReminder(String email) async {
    return await medicineReminderCollectionReference
        .where("userEmail", isEqualTo: email)
        .get();
  }

  // Get specific Reminder of specific User
  static Future<QuerySnapshot<Object?>> getUserReminder(
      String email, int reminderNo) async {
    return await medicineReminderCollectionReference
        .where("userEmail", isEqualTo: email)
        .where("reminderNo", isEqualTo: reminderNo)
        .get();
  }

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
    String startTime,
  ) async {
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
      "startTime": startTime,
    };

    await medicineReminderCollectionReference.doc().set(data).whenComplete(() {
      response.code = 200;
      response.message = "Reminder Saved";
    }).catchError((onError) {
      response.code = 500;
      response.message = onError.toString();
    });
    return response;
  }

  // Update a created medicine reminder
  static Future<Response> updateReminder(
      MedicalReminder medicalReminder) async {
    Response response = Response();

    try {
      QuerySnapshot querySnapshot = await medicineReminderCollectionReference
          .where("userEmail", isEqualTo: medicalReminder.userEmail)
          .where("reminderNo", isEqualTo: medicalReminder.reminderNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot document = querySnapshot.docs[0];

        Map<String, dynamic> data = <String, dynamic>{
          "reminderNo": medicalReminder.reminderNo,
          "userEmail": medicalReminder.userEmail,
          "medicineName": medicalReminder.medicineName,
          "dosage": medicalReminder.dosage,
          "pillIntake": medicalReminder.pillIntake,
          "interval": medicalReminder.interval,
          "days": medicalReminder.days,
          "startDate": medicalReminder.startDate,
          "additionalInstructions": medicalReminder.additionalInstructions,
          "daysOfWeek": medicalReminder.daysOfWeek,
          "startTime": medicalReminder.startTime,
        };

        await document.reference.update(data); // Update the document
        response.code = 200;
        response.message = "Reminder updated successfully!";
      } else {
        response.code = 404;
        response.message = "Reminder not found";
      }
    } catch (e) {
      response.code = 500;
      response.message = "Server Error: ${e.toString()}";
    }

    return response;
  }

  //Delete a reminder
  static deleteReminder(MedicalReminder medicalReminder) async {
    Response response = Response();

    try {
      QuerySnapshot querySnapshot = await medicineReminderCollectionReference
          .where("userEmail", isEqualTo: medicalReminder.userEmail)
          .where("reminderNo", isEqualTo: medicalReminder.reminderNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot document = querySnapshot.docs[0];
        await document.reference.delete(); // delete the document
        response.code = 200;
        response.message = "Reminder deleted successfully!";
      } else {
        response.code = 404;
        response.message = "Reminder not found";
      }
    } catch (e) {
      response.code = 500;
      response.message = "Server Error: ${e.toString()}";
    }

    return response;
  }
}
