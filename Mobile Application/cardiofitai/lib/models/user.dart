import 'dart:ffi';

class User {
  String name;
  String email;
  String password;
  String age;
  String height;
  String weight;
  String bmi;
  String dob;
  String activeLevel;
  String type;
  String bloodGlucoseLevel;
  String bloodCholestrolLevel;
  String cardiacCondition;
  String bloodTestType;
  String memberName;
  String memberRelationship;
  String memberPhoneNo;
  bool newUser;
  String gender;

  User(
      this.name,
      this.email,
      this.password,
      this.age,
      this.height,
      this.weight,
      this.bmi,
      this.dob,
      this.activeLevel,
      this.type,
      this.bloodGlucoseLevel,
      this.bloodCholestrolLevel,
      this.cardiacCondition,
      this.bloodTestType,
      this.memberName,
      this.memberPhoneNo,
      this.memberRelationship,
      this.newUser,
      this.gender);
}
