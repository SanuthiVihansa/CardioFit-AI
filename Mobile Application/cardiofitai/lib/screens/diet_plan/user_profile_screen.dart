import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
  final DateTime _dateOfBirth = DateTime.now();
  String dropdownValue = 'Less Active';

  @override
  // Widget build(BuildContext context) {
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.amberAccent.shade100,
  //       leading: IconButton(
  //         icon: Icon(
  //             Icons.arrow_back_ios
  //         ),
  //         onPressed: () {
  //           Navigator.pop(
  //             context,
  //             MaterialPageRoute(builder: (context) => DietHomePage()
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //     body: ListView(
  //       padding: EdgeInsets.zero,
  //       children: <Widget> [
  //         buildTop(),
  //         userName(),
  //         dateOfBirth(),
  //         Age(),
  //         Height(),
  //         Weight(),
  //         BMI(),
  //         ActiveLevel()
  //       ]
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Assuming you have an AppBar
      body: SingleChildScrollView(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Top Section
            buildTop(),
        
            // Main Content
            Padding(
              padding: const EdgeInsets.all(30.0), // Add some padding
              child: Column(
                children: [
                  userName(),
                  dateOfBirth(),
                  Row( // Arrange Age and Height widgets horizontally
                    children: [
                      Expanded(child: Age()), // Use Expanded to fill available space
                      SizedBox(width: 16.0), // Add some horizontal spacing between widgets
                      Expanded(child: Height()),
                    ],
                  ),
                  Weight(),
                  BMI(),
                  ActiveLevel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildTop() {
    final top = coverHeight - profileHeight/2;
    final bottom = (coverHeight + profileHeight/2);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        buildCoverImage(),
        Positioned(
          top: top,
          child:buildProfileImage()
        ),
        Positioned(
          top:bottom,
          child: buildUserName()
        )
      ],
    );
  }
  Widget buildCoverImage() => Container(
    color : Colors.grey,
    child:Image.asset(
      'assets/coverimage.jpg',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover
    ),
  );
  Widget buildProfileImage() {
    final imageUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D';

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
          )
      );
    } else {
      return const SizedBox(); // Placeholder or alternative widget if URL is invalid
    }
  }
  Widget buildUserName(){
    return Text("NAME",
      style:
      TextStyle(
          fontWeight: FontWeight.bold,
        letterSpacing: 4.0
      ),
    );
  }
  //Build a Form Widget to display profile data
  Widget userName() => TextField(
    controller: _userNameController,
    decoration: InputDecoration(
      errorText: "",
      labelText: 'Name',
      border: OutlineInputBorder(),
    ),
    onChanged: (text) {    },
  );
  Widget dateOfBirth() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'DOB',
        border: OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: _dateOfBirth.toString().substring(
            0, 10), // Display selected date in the format yyyy-MM-dd.
      ),
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
    onChanged: (text) {    },
  );
  Widget Height() => TextField(
    controller: _heightController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      errorText: "",
      labelText: 'Height',
      border: OutlineInputBorder(),
    ),
    onChanged: (text) {    },
  );
  Widget Weight() => TextField(
    controller: _weightController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      errorText: "",
      labelText: 'Weight',
      border: OutlineInputBorder(),
    ),
    onChanged: (text) {    },
  );
  Widget BMI() => TextField(
    controller: _caluclateBMIController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      errorText: "",
      labelText: 'BMI',
      border: OutlineInputBorder(),
    ),
    onChanged: (text) {    },
  );
  Widget ActiveLevel() => DropdownButton<String>(
    // Ensure dropdownValue is initialized with a value from the items list
    value: dropdownValue ?? 'Less Active',  // Default to 'Less Active'
    icon: const Icon(Icons.arrow_drop_down_circle_rounded),
    onChanged: (String? newValue) {
      setState(() {
        dropdownValue = newValue!;
      });
    },
    items: const[
      DropdownMenuItem<String>(
        value: 'Less Active',
        child: Text('Less Active')
    ),
      DropdownMenuItem<String>(
          value: 'Intermediate',
          child: Text('Intermediate')
      ),
      DropdownMenuItem<String>(
          value: 'Very Active',
          child: Text('Very Active')
      ),
    ],
  );
//Rate how active you are
//Taking medicines for...(dropdown)

}
