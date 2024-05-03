import 'package:cardiofitai/components/navbar_component.dart';
import 'package:cardiofitai/screens/diet_plan/recognitionscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'package:intl/intl.dart';


import '../../models/user.dart';

class DietHomePage extends StatefulWidget {
  const DietHomePage(this.user, {super.key});

  final User user;

  @override
  State<DietHomePage> createState() => _DietHomePageState();
}

class _DietHomePageState extends State<DietHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double _height;
  Widget DietAdvice() {
    double halfScreenWidth = (MediaQuery.of(context).size.width / 2)-50;

    return Container(
      width: halfScreenWidth,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  'assets/dieteryimage.jpg',
                  width: halfScreenWidth,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text("Dietery Advice",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ),
                  Center(child: Text("Know the right amount of nutrition you need")),

                  SizedBox(height: 10)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget ReportAnalaysis() {
    double halfScreenWidth = (MediaQuery.of(context).size.width / 2)-50;

    return Container(
      width: halfScreenWidth,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  'assets/reportanalysis.jpg',
                  width: halfScreenWidth,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text("Report Analysis",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ),
                  Center(child: Text("Scan and analyse report information")),
                  SizedBox(height: 10)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final today = DateTime.now();

    return Scaffold (
      backgroundColor: const Color(0xFFE9E9E9),
      key: _scaffoldKey,
      drawer: LeftNavBar(
          user: widget.user,
          name: widget.user.name,
          email: widget.user.email,
          width: 150,
          height: 300),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Positioned(
              top: 0,
              height: _height * 0.85,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: const Radius.circular(40),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top:40,left: 32,right: 32,bottom: 20 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.menu,color: CupertinoColors.secondaryLabel,),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        title: Text(
                          "${DateFormat("EEEE").format(today)},${DateFormat("d MMMM").format(today)}",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                        subtitle: Text("Hello, "+widget.user.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        trailing: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D',
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children:<Widget> [
                          _RadialProgress(
                            key: UniqueKey(),
                            width: width * 0.15,
                            height: _height * 0.15,
                          ),
                          Spacer(), // This will push _RadialProgress to the start
                          SizedBox(width: 200),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              _IngredientProgress(
                                width: width * 0.28,
                                ingredients: "PROTEIN",
                                progress: 0.3,
                                progressColor: Colors.green,
                                leftAmount: 72,
                              ),
                              _IngredientProgress(
                                width: width * 0.28,
                                ingredients: "CARBS",
                                progress: 0.3,
                                progressColor: Colors.redAccent,
                                leftAmount: 252,
                              ),
                              _IngredientProgress(
                                width: width * 0.28,
                                ingredients: "FAT",
                                progress: 0.1,
                                progressColor: Colors.yellowAccent,
                                leftAmount: 61,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: _height*0.90,
              left: 0,
              right: 0,
              child: Container(
                height: _height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (<Widget>[
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 8,
                        left: 32,
                        right: 16,
                      ),
                      child: Text(
                        "Health Insights",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 25,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to homepage
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (BuildContext context) => DietHomePage(widget.user)));;
                              },
                              child: DietAdvice(),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to homepage
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (BuildContext context) =>RecognitionScreen()));;
                              },
                              child: ReportAnalaysis(),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                            bottom: 10, left: 32, right: 32),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF8C001A),
                                  Color(0xF56C0609),
                                ])),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 20,),
                            const Text(
                              "YOUR CURRENT",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                            const Text("BODY MASS INDEX",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700)),
                            Text(widget.user.bmi,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
class _IngredientProgress extends StatelessWidget{

  final String ingredients;
  final double leftAmount;
  final double progress,width;
  final Color progressColor;

  const _IngredientProgress({super.key, required this.ingredients, required this.leftAmount, required this.progress,required this.width, required this.progressColor});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(ingredients,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700),),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 10,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius:BorderRadius.all(Radius.circular(5)),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: 10,
                  width: width*progress,
                  decoration: BoxDecoration(
                    borderRadius:BorderRadius.all(Radius.circular(5)),
                    color: progressColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 10,),
            Text("${leftAmount}g left")

          ],
        )
      ],
    );
  }

}

class _RadialProgress extends StatelessWidget{

  final double height,width;

  const _RadialProgress({required Key key,required this.height,required this.width}):super(key:key);

  @override
  Widget build(BuildContext context) {
   return CustomPaint(
     painter: _RadialPainter(progress:0.75),
     child: Container(
       height: height,
       width: width,
       child: Center(
         child: RichText(
           text: TextSpan(
             children: [
               TextSpan(text: "1731",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700,color: const Color(
                   0xFF8C001A))),
               TextSpan(text: "\n"),
               TextSpan(text: " kcal",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: const Color(0xFF8C001A))),

             ]
           ),
         ),
       ),
     ),
   );
  }
}

class _RadialPainter extends CustomPainter{
  final double progress;

  _RadialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth=10
      ..color=Color(0xFF8C001A)
      ..style=PaintingStyle.stroke
      ..strokeCap=StrokeCap.round;


    Offset center = Offset(size.width/2, size.height/2);
    double relativeProgress = 360*progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width/2), // using fromCircle instead of fromCenter
      math.radians(-90),
      math.radians(-relativeProgress),
      false,
      paint,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

