import 'package:flutter/material.dart';
import 'package:spantry/model/recipe.dart';
import '../../services/firestore/recipe_management.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String imageUrl;

  RecipeDetailsPage({
    Key? key,
    required this.imageUrl,
    required String name,
    required int persons,
    required int time,
    required String description,
    required String ingredients,
  }) : _name = name,
        _persons = persons,
        _time = time,
        _description = description,
        _ingredients = ingredients,
        super(key: key);

  final String _name;
  final int _persons;
  final int _time;
  final String _description;
  final String _ingredients;

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late String name;
  late int persons;
  late int time;
  late String description;
  late String ingredients;
  final RecipeManagement recipeManagement = RecipeManagement();

  @override
  void initState() {
    super.initState();
    name = widget._name;
    persons = widget._persons;
    time = widget._time;
    description = widget._description;
    ingredients = widget._ingredients;
    syncDataWithLocalDatabase();
  }

  void syncDataWithLocalDatabase() async {
    await recipeManagement.syncRecipesWithLocalDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20.0),
          Center(
            child: Text(
              name[0].toUpperCase() + name.substring(1),
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard(
                  icon: Icons.person,
                  value: '$persons People',
                ),
                _buildInfoCard(
                  icon: Icons.access_time,
                  value: '$time min',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoundedBox(
                    title: 'Ingredients',
                    content: ingredients,
                  ),
                  const SizedBox(height: 30.0),
                  _buildRoundedBox(
                    title: 'Description',
                    content: description,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteRecipe,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Recipe'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openEditDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Details'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe() {
    Recipe recipe = Recipe(name: name, persons: persons, time: time, description: description, ingredients: ingredients);
    RecipeManagement().deleteRecipe(recipe);
    Navigator.pop(context);
  }

  void _openEditDialog() {
    final TextEditingController _ingredientsController = TextEditingController(text: ingredients);
    final TextEditingController _descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Edit Recipe Details'),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(hintText: 'Ingredients'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  ingredients = _ingredientsController.text;
                  description = _descriptionController.text;
                });
                Recipe updatedRecipe = Recipe(
                  name: name,
                  persons: persons,
                  time: time,
                  description: description,
                  ingredients: ingredients,
                );
                RecipeManagement().updateRecipe(updatedRecipe);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildRoundedBox({required String title, required String content}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.grey[200],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(content),
      ],
    ),
  );
}

Widget _buildInfoCard({required IconData icon, required String value}) {
  return Card(
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36.0),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

