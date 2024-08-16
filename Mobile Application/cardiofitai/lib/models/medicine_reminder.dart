class MedicalReminder{
   int reminderNo;
   String userEmail;
   String medicineName;
   String dosage;
   String pillIntake;
   String interval;
   int days;
   String startDate;
   String additionalInstructions;
   List<String> daysOfWeek;
   String startTime;


  MedicalReminder(this.reminderNo,this.userEmail,this.medicineName,this.dosage,this.pillIntake,this.days,this.interval,this.additionalInstructions,this.startDate,this.startTime,this.daysOfWeek);
}