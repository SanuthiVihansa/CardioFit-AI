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
  late double _height;
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
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
        user: widget.user,
          name: widget.user.name,
          email: widget.user.email,
          width: 150,
          height: 300
      ),
      body: Stack(
        children:
          <Widget>[
            //Top App Bar Like Structure
            Positioned(
                top: 0,
                height: _height*0.35,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: const Radius.circular(40),
                  ),
                  child: Container(
                    color:Colors.white,
                  ),

            ),
            ),
            Positioned(
                child: Container(
                  height: _height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (
                      <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8,
                              left: 32,
                              right: 16,
                            ),
                          child: Text(
                              "Health Insights",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                        Expanded(
                          child:Row(
                            children: <Widget>[
                              SizedBox(
                                width: 35,
                              ),
                              ButtonSample(),
                            ],
                          ) ,
                        ),
                        Expanded(
                          child:Container(
                            color: Colors.blueAccent,
                          ) ,
                        ),
                      ]
                    ),
                  ),
                ),
            ),
          ],
      )

    );
  }

  Widget ButtonSample()=>(
    InkWell(
      onTap: (){},
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(75),
          color: Colors.blue, // You can change the color here
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.restaurant_menu,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              'Diet Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
);
}
