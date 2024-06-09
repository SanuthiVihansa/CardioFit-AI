class MedicalReminder{
   String medicineName;
   String dosage;
   String pillIntake;
   String interval;
   int days;
   String startDate;
   String additionalInstructions;
   List<String> daysOfWeek;
   String startTime;

  MedicalReminder(this.medicineName,this.dosage,this.pillIntake,this.days,this.interval,this.additionalInstructions,this.startDate,this.startTime,this.daysOfWeek);
}