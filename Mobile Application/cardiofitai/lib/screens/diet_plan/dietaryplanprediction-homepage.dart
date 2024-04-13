import 'package:flutter/material.dart';

import '../../components/navbar_component.dart';

class DietaryPlanHomePage extends StatefulWidget {
  const DietaryPlanHomePage(double width, double height, {super.key});

  @override
  State<DietaryPlanHomePage> createState() => _DietaryPlanHomePageState();
}

class _DietaryPlanHomePageState extends State<DietaryPlanHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: LeftNavBar(
        name: 'widget.user.name',
        email: 'widget.user.email',
        width: 150,
        height: 300),
    appBar: AppBar(
      title: Align(
          alignment: Alignment.center, child: Text('Customised Dietery Plan')),
    ),
  );

}
//Calling the navigation bar component


