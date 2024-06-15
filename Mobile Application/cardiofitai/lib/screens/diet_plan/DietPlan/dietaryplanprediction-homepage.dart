import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../components/navbar_component.dart';
import '../../../models/user.dart';
import '../../../services/user_information_service.dart';

class DietaryPlanHomePage extends StatefulWidget {
  const DietaryPlanHomePage(this.user, {super.key});
  final User user;

  @override
  State<DietaryPlanHomePage> createState() => _DietaryPlanHomePageState();
}

class _DietaryPlanHomePageState extends State<DietaryPlanHomePage> {
  late QuerySnapshot<Object?> _userSignUpInfo;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();
  String gender = 'Female';
  String cardiacCondition = 'Normal';
  String bmiResult = 'Normal';
  String bloodSugarResult = 'High';
  String cardiacConditionResult = 'Normal';
  String cholesterolResult = 'Normal';
  String advice = 'Get a balanced diet, Limit high sugary foods.';

  //Function to generate a Report number
  Future<void> _userInfo() async {
    _userSignUpInfo =
    await UserLoginService.getUserByEmail(widget.user.email);
    ageController.text = _userSignUpInfo.docs[0]["age"];
    bmiController.text = _userSignUpInfo.docs[0]["bmi"];
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userInfo();
  }

  void generatePrediction() {
    setState(() {
      // Assuming some logic to set these values based on input
      // Update the results accordingly
    });
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: LeftNavBar(
        user: widget.user,
        name: widget.user.name,
        email: widget.user.email,
        width: 150,
        height: 300),
    appBar: AppBar(
      title: Align(
          alignment: Alignment.center, child: Text('Customised Dietery Advice')),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: 'Age',border: OutlineInputBorder(),),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: gender,
                      onChanged: (String? newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      items: <String>['Female', 'Male'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            controller: bmiController,
            decoration: InputDecoration(labelText: 'BMI (kg/m²)',border: OutlineInputBorder(),),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cholesterolController,
                  decoration: InputDecoration(labelText: 'Blood Cholesterol Level',border: OutlineInputBorder(),),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: sugarController,
                  decoration: InputDecoration(labelText: 'Blood Sugar Level',border: OutlineInputBorder(),),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Cardiac Condition',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: cardiacCondition,
                onChanged: (String? newValue) {
                  setState(() {
                    cardiacCondition = newValue!;
                  });
                },
                items: <String>['Normal', 'Abnormal'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: generatePrediction,
              child: Text('Generate'),
            ),
          ),
          SizedBox(height: 20),
          Text('Dietary Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('BMI')),
              Expanded(child: Text(bmiResult, textAlign: TextAlign.center)),
              Expanded(child: Text('Cardiac Condition')),
              Expanded(child: Text(cardiacConditionResult, textAlign: TextAlign.center)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text('Blood Sugar Level')),
              Expanded(child: Text(bloodSugarResult, textAlign: TextAlign.center)),
              Expanded(child: Text('Blood Cholesterol Level')),
              Expanded(child: Text(cholesterolResult, textAlign: TextAlign.center)),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              advice,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
