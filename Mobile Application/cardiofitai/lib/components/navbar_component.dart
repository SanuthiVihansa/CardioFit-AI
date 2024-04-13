import 'package:cardiofitai/screens/diet_plan/user_profile_screen.dart';
import 'package:flutter/material.dart';

class LeftNavBar extends StatelessWidget {
   final String name;
   final String email;
   final double width;
   final double height;

  LeftNavBar({
    required this.name,
    required this.email,
    required this.width,
    required this.height,
  });


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('name'),
            accountEmail: Text('email'),
            currentAccountPicture: ElevatedButton(
              onPressed: (){
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
                },
              child: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D',
                    width: double.infinity,
                    height: 90,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Purchase Request"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigator.of(context).push(
                // MaterialPageRoute(
                //   builder: (context) => PurchaseRequestScreen(width, height),
                // ),
              // );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text("Delivery Note History"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         DeliveryNoteHistoryScreen(width, height),
              //   ),
              // );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("LOG OUT"),
            // onTap: () async {
            //   final directory = await getApplicationDocumentsDirectory();
            //   final path = directory.path;
            //   File file = File('$path/userdata.txt');
            //   await file.delete();
            //
            //   Navigator.of(context).pop(); // Close the drawer
            //   Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (BuildContext context) => LoginScreen(width, height),
            //     ),
            //   );
            // },
          )
        ],
      ),
    );
  }



}
