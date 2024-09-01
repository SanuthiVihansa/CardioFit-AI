import 'package:cardiofitai/screens/common/dashboard_screen.dart';
import 'package:cardiofitai/screens/diet_plan/ReportReading/modiRecognitionScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/user.dart';
import '../../services/user_information_service.dart';
import 'diet_,mainhome_page.screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.user, {super.key});

  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double coverHeight = 280;
  final double profileHeight = 144;

  //Initialising form Controllers
  final _userNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _caluclateBMIController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();

  String dropdownValue = 'Less Active';
  late QuerySnapshot<Object?> _userSignUpInfo;

  get height => _heightController.text;

  get weight => _weightController.text;

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.user.name;
    _userInfo();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }


  //Function to generate a Report number
  Future<void> _userInfo() async {
    _userSignUpInfo = await UserLoginService.getUserByEmail(widget.user.email);
    _dobController.text = _userSignUpInfo.docs[0]["dob"];
    _ageController.text = _userSignUpInfo.docs[0]["age"];
    _heightController.text = _userSignUpInfo.docs[0]["height"];
    _weightController.text = _userSignUpInfo.docs[0]["weight"];
    _caluclateBMIController.text = _userSignUpInfo.docs[0]["bmi"];
    dropdownValue = _userSignUpInfo.docs[0]["activeLevel"];
    _genderController.text = _userSignUpInfo.docs[0]["gender"];
    setState(() {});
  }

  //Function to calculate BMI
  void calculateBMI(String weight, String height) {
    if (weight != "" && height != "") {
      double bmi = double.parse(weight) /
          (double.parse(height) / 100 * double.parse(height) / 100);
      double roundedBMI = double.parse((bmi).toStringAsFixed(2));

      _caluclateBMIController.text = roundedBMI.toString();
    } else {
      _caluclateBMIController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Assuming you have an AppBar
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Top Section
          buildTop(),

          // Main Content
          Padding(
            padding: const EdgeInsets.only(
                left: 30.0, right: 30.0, bottom: 30.0, top: 100.0),
            // Add some padding
            child: Column(
              children: [
                userName(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    // Arrange Age and Height widgets horizontally
                    children: [
                      Expanded(child: dateOfBirth()),
                      // Use Expanded to fill available space
                      SizedBox(width: 16.0),
                      // Add some horizontal spacing between widgets
                      Expanded(child: GenderDropdown()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    // Arrange Age and Height widgets horizontally
                    children: [
                      Expanded(child: Age()),
                      // Use Expanded to fill available space
                      SizedBox(width: 16.0),
                      // Add some horizontal spacing between widgets
                      Expanded(child: Height()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    // Arrange Age and Height widgets horizontally
                    children: [
                      Expanded(child: Weight()),
                      // Use Expanded to fill available space
                      SizedBox(width: 16.0),
                      // Add some horizontal spacing between widgets
                      Expanded(child: BMI()),
                    ],
                  ),
                ),


                // ActiveLevel(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      backBtn(),
                      SizedBox(
                        width: 20,
                      ),
                      saveInfoBtn()
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTop() {
    final top = coverHeight - profileHeight / 2;
    final bottom = (coverHeight + profileHeight / 2);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        buildCoverImage(),
        Positioned(top: top, child: buildProfileImage()),
        Positioned(top: bottom, child: buildUserName())
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Image.asset('assets/coverimage.jpg',
            width: double.infinity, height: coverHeight, fit: BoxFit.cover),
      );

  Widget buildProfileImage() {
    final imageUrl =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D';

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.grey.shade800,
          backgroundImage: NetworkImage(imageUrl),
          foregroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0, // Adjust the width as needed
              ),
            ),
          ));
    } else {
      return const SizedBox(); // Placeholder or alternative widget if URL is invalid
    }
  }

  Widget buildUserName() {
    return Text(
      widget.user.name,
      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 4.0),
    );
  }

  //Build a Form Widget to display profile data
  Widget userName() => TextField(
        controller: _userNameController,
        decoration: InputDecoration(
          errorText: "",
          labelText: "Name",
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {},
      );

  Widget dateOfBirth() {
    return TextFormField(
      controller: _dobController,
      decoration: InputDecoration(
        errorText: "",
        labelText: 'DOB',
        border: OutlineInputBorder(),
      ),
      readOnly: true, // Make the field read-only so that only the date picker can set the value
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(), // The current date as the initial date
          firstDate: DateTime(1900), // Start date
          lastDate: DateTime.now(), // End date, ensuring the date can't be in the future
        );

        if (pickedDate != null) {
          String formattedDate = "${pickedDate.toLocal()}".split(' ')[0];
          setState(() {
            _dobController.text = formattedDate; // Set the date in the controller
            _ageController.text = _calculateAge(pickedDate).toString(); // Calculate and set the age
          });
        }
      },
    );
  }

  Widget Age() => TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: "",
          labelText: 'Age',
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {},
      );

  Widget Height() => TextField(
        controller: _heightController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: "",
          labelText: 'Height',
          suffix: Text("cm"),
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {
          // double height = double.parse(_heightController.text);

          calculateBMI(weight, height);
        },
      );

  Widget Weight() => TextField(
        controller: _weightController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: "",
          labelText: 'Weight',
          border: OutlineInputBorder(),
          suffix: Text("Kg"),
        ),
        onChanged: (text) {
          calculateBMI(weight, height);
        },
      );

  Widget BMI() => TextField(
        readOnly: true,
        controller: _caluclateBMIController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: "",
          labelText: 'BMI',
          suffix: Text.rich(
            TextSpan(
              text: 'Kg/m', // Normal text
              style: TextStyle(fontSize: 16.0), // Base text size
              children: <InlineSpan>[
                WidgetSpan(
                  child: Transform.translate(
                    offset: const Offset(0, -5),
                    // Adjust the offset to move it up
                    child: Text(
                      '2',
                      textScaleFactor: 0.7,
                      // Adjust the scale to make it smaller
                      style: TextStyle(fontSize: 16.0), // Base text size
                    ),
                  ),
                ),
              ],
            ),
          ),
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {},
      );

  Widget ActiveLevel() => DropdownButton<String>(
        // Ensure dropdownValue is initialized with a value from the items list
        value: dropdownValue ?? 'Less Active', // Default to 'Less Active'
        icon: const Icon(Icons.arrow_drop_down_circle_rounded),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: const [
          DropdownMenuItem<String>(
              value: 'Less Active', child: Text('Less Active')),
          DropdownMenuItem<String>(
              value: 'Intermediate', child: Text('Intermediate')),
          DropdownMenuItem<String>(
              value: 'Very Active', child: Text('Very Active')),
        ],
      );

  Widget backBtn() => ElevatedButton(
      child: Text("Back"),
      onPressed: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen(widget.user)));
      });

  Widget saveInfoBtn() => ElevatedButton(
      child: Text("Save"),
      onPressed: () {
        User updatedUserInfo = User(
            widget.user.name,
            widget.user.email,
            widget.user.password,
            _ageController.text,
            _heightController.text,
            _weightController.text,
            _caluclateBMIController.text,
            _dobController.text,
            dropdownValue.characters.string,
            widget.user.type,
            "0",
            "0",
            "No",
            "0",
            widget.user.memberName,
            widget.user.memberRelationship,
            widget.user.memberPhoneNo,
            false,
            _genderController.text);
        UserLoginService.updateUser(updatedUserInfo);
        if (widget.user.newUser == false) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => DashboardScreen(widget.user)));
        } else {
          // IF NEW USER
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  RecognitionScreen(widget.user)));
        }
      });

  Widget GenderDropdown() => DropdownButtonFormField<String>(
        value:
            _genderController.text.isNotEmpty ? _genderController.text : null,
        onChanged: (String? newValue) {
          setState(() {
            _genderController.text = newValue!;
          });
        },
        decoration: InputDecoration(
          errorText: "",
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem<String>(
            value: 'Female',
            child: Text('Female'),
          ),
          DropdownMenuItem<String>(
            value: 'Male',
            child: Text('Male'),
          ),
        ],
      );
}
