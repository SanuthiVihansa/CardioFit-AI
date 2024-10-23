import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';  // Added for launching URLs

import '../../../models/user.dart';

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
    List<String> healthFilters = [];
    if (double.parse(widget.user.bmi) > 25) {
      healthFilters.add('low-fat');
    }
    if (double.parse(widget.user.bloodCholestrolLevel) > 200) {
      healthFilters.add('low-cholesterol');
    }
    if (double.parse(widget.user.bloodGlucoseLevel) > 110) {
      healthFilters.add('low-sugar');
    }
    if (widget.user.cardiacCondition == "Yes") {
      healthFilters.add('low-sodium');
    }

    // Convert health filters to query string
    String healthQuery = healthFilters.isNotEmpty
        ? '&health=${healthFilters.join('&health=')}'
        : '';

    // Build the API URL
    String url =
        'https://api.edamam.com/search?app_id=$appId&app_key=$appKey&q=healthy&from=0&to=10$healthQuery';

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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
          ? Center(child: Text('No recipes found.'))
          : ListView.builder(
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
      margin: EdgeInsets.all(10),
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
              height: 200,
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Title
                Text(
                  recipe['label'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                // Calories and Diet Labels
                Text(
                  '${recipe['calories'].toStringAsFixed(0)} kcal',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                // View More Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Open the recipe in the default browser
                      _openRecipe(recipe['url']);
                    },
                    child: Text(
                      'View Recipe',
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
