import 'package:cardiofitai/components/navbar_component.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';

class DietHomePage extends StatefulWidget {
  const DietHomePage(this.user,{super.key});

  final User user;



  @override
  State<DietHomePage> createState() => _DietHomePageState();
}

class _DietHomePageState extends State<DietHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_scaffoldKey ,
      appBar: AppBar(
        leading:
      IconButton(
        icon:Icon(Icons.menu),
        onPressed: (){
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      ),
      drawer:LeftNavBar(
          name: widget.user.name,
          email: widget.user.email,
          width: 150,
          height: 300
      ),
      body: Center(child: Text("Welcome to Diet Home")),
    );
  }
}
