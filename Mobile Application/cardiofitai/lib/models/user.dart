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
  String memberPhoneNo;
  String memberRelationship;
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

  User copyWith({
    String? name,
    String? email,
    String? password,
    String? age,
    String? height,
    String? weight,
    String? bmi,
    String? dob,
    String? activeLevel,
    String? type,
    String? bloodGlucoseLevel,
    String? bloodCholestrolLevel,
    String? cardiacCondition,
    String? bloodTestType,
    String? memberName,
    String? memberPhoneNo,
    String? memberRelationship,
    bool? newUser,
    String? gender,
  }) {
    return User(
      name ?? this.name,
      email ?? this.email,
      password ?? this.password,
      age ?? this.age,
      height ?? this.height,
      weight ?? this.weight,
      bmi ?? this.bmi,
      dob ?? this.dob,
      activeLevel ?? this.activeLevel,
      type ?? this.type,
      bloodGlucoseLevel ?? this.bloodGlucoseLevel,
      bloodCholestrolLevel ?? this.bloodCholestrolLevel,
      cardiacCondition ?? this.cardiacCondition,
      bloodTestType ?? this.bloodTestType,
      memberName ?? this.memberName,
      memberPhoneNo ?? this.memberPhoneNo,
      memberRelationship ?? this.memberRelationship,
      newUser ?? this.newUser,
      gender ?? this.gender,
    );
  }
}
