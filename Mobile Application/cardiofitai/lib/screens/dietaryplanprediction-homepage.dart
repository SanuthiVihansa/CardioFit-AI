import 'package:flutter/material.dart';

import '../components/navbar_component.dart';

class DietaryPlanHomePage extends StatefulWidget {
  const DietaryPlanHomePage({super.key});

  @override
  State<DietaryPlanHomePage> createState() => _DietaryPlanHomePageState();
}

class _DietaryPlanHomePageState extends State<DietaryPlanHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: LeftNavBar(
        name: 'widget.user.name',
        email: 'widget.user.email',
        countDN:10,
        width: 150,
        height: 300),
    appBar: AppBar(
      title: Align(
          alignment: Alignment.center, child: Text('Welcome to Procumate')),
    ),
  );

}
//Calling the navigation bar component


