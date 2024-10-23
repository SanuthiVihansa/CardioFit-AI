import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';  // Added for launching URLs

import '../../../models/user.dart';
import 'dietaryplanprediction-homepage.dart';

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen(this.user, {super.key});

  final User user;

  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  List<dynamic> _recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    const String appId = '043ed680';
    const String appKey = 'f469a4a7d5184ef0b377b435bc4f373d';


    // Adjust health and nutrient filters based on user's health parameters
    List<String> dietFilters = [];
    List<String> healthFilters = [];

    // Check if the person is healthy
    bool isHealthy = true;

    // If user's BMI is greater than 25, suggest low-fat diet
    if (double.parse(widget.user.bmi) > 25) {
      dietFilters.add('low-fat');
      isHealthy = false;
    }

    // If cholesterol level is above 200, suggest low-cholesterol diet
    if (double.parse(widget.user.bloodCholestrolLevel) > 200) {
      healthFilters.add('low-cholesterol');
      isHealthy = false;
    }

    // If glucose level is above 110, suggest low-sugar diet
    if (double.parse(widget.user.bloodGlucoseLevel) > 110) {
      healthFilters.add('low-sugar');
      isHealthy = false;
    }

    // If cardiac condition exists, suggest low-sodium diet
    if (widget.user.cardiacCondition == "Yes") {
      healthFilters.add('low-sodium');
      isHealthy = false;
    }

    // If the person is healthy, suggest balanced diet
    if (isHealthy) {
      dietFilters.add('balanced');
    }

    // Convert diet and health filters to query string
    String dietQuery = dietFilters.isNotEmpty ? '&diet=${dietFilters.join('&diet=')}' : '';
    String healthQuery = healthFilters.isNotEmpty ? '&health=${healthFilters.join('&health=')}' : '';

    // Build the API URL
    String url =
        'https://api.edamam.com/search?app_id=$appId&app_key=$appKey&q=healthy&from=0&to=10$dietQuery$healthQuery';

    // Send the HTTP GET request
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _recipes = jsonDecode(response.body)['hits'];
        isLoading = false;
      });
    } else {
      // Handle errors
      print('Failed to load recipes: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Menu for ${widget.user.name}'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>
                    DietaryPlanHomePage(widget.user)));

          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
          ? Center(child: Text('No recipes found.'))
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,  // Number of items per row
          crossAxisSpacing: 10,  // Space between items horizontally
          mainAxisSpacing: 10,  // Space between items vertically
          childAspectRatio: 1.1,  // Adjust the aspect ratio to fit your design
        ),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index]['recipe'];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: recipe['image'],
              height: 200,  // Adjusted height for grid layout
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),  // Adjust padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Title
                Text(
                  recipe['label'],
                  style: TextStyle(
                    fontSize: 14,  // Adjusted font size for grid layout
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                // Calories and Diet Labels
                Text(
                  '${recipe['calories'].toStringAsFixed(0)} kcal',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),  // Adjusted font size
                ),
                SizedBox(height: 5),
                // View More Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Open the recipe in the default browser
                      _openRecipe(recipe['url']);
                    },
                    child: Text(
                      'View',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Method to open recipe link in the browser
  void _openRecipe(String url) async {
    final Uri recipeUrl = Uri.parse(url);
    if (!await launchUrl(recipeUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
