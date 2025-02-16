import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/model/recipe.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../database/database_service.dart';

class RecipeManagement {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final CollectionReference recipes = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('recipes');

  final DatabaseService _databaseService = DatabaseService();

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> addRecipe(Recipe recipe) async {
    final docRecipe = recipes.doc(recipe.name.toLowerCase());
    recipe.uid = docRecipe.id;
    final json = recipe.json();
    await docRecipe.set(json);
    await _databaseService.insertRecipe(recipe);
  }

  Stream<QuerySnapshot> getRecipesStream() {
    return recipes.orderBy('name').snapshots();
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    var docSnapshot = await recipes.doc(updatedRecipe.name.toLowerCase()).get();

    if (docSnapshot.exists) {
      await recipes.doc(updatedRecipe.name.toLowerCase()).update({
        'name': updatedRecipe.name,
        'persons': updatedRecipe.persons,
        'description': updatedRecipe.description,
        'ingredients': updatedRecipe.ingredients,
        'time': updatedRecipe.time,
      });
      await _databaseService.updateRecipe(updatedRecipe);
    } else {
      print('Recipe not found');
    }
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    await _databaseService.deleteRecipe(recipe.uid!);
    await recipes.doc(recipe.name.toLowerCase()).delete();
  }

  Future<void> syncRecipesWithLocalDatabase() async {
    QuerySnapshot snapshot = await recipes.get();
    List<Recipe> recipesList = snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();

    for (var recipe in recipesList) {
      await _databaseService.insertRecipe(recipe);
    }
  }
}

