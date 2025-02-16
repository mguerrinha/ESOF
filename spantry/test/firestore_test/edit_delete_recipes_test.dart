import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/model/recipe.dart';
import 'package:spantry/services/firestore/recipe_management.dart';
import 'edit_delete_recipes_test.mocks.dart';

@GenerateNiceMocks([MockSpec<RecipeManagement>(), MockSpec<Recipe>()])

void main() {
  group('Firebase Firestore Tests for Recipes', () {
    late MockRecipeManagement mockRecipeManagement;
    setUp(() {
      mockRecipeManagement = MockRecipeManagement();
    });

    test('deleteRecipe succeeds', () async {
      final Recipe recipe = Recipe(name: "Chocolate Cake", persons: 4, time: 30, description: "A delicious cake", ingredients: "Chocolate, Eggs, Flour, Sugar");

      when(mockRecipeManagement.deleteRecipe(recipe)).thenAnswer((_) => Future.value());

      await mockRecipeManagement.deleteRecipe(recipe);

      verify(mockRecipeManagement.deleteRecipe(recipe)).called(1);
    });

    test('deleteRecipe fails when recipe does not exist', () async {
      final Recipe nonexistentRecipe = Recipe(name: "Fantasy Cake", persons: 4, time: 30, description: "Not real", ingredients: "Magic");

      when(mockRecipeManagement.deleteRecipe(nonexistentRecipe)).thenThrow(ArgumentError('Recipe does not exist'));

      expect(() async => await mockRecipeManagement.deleteRecipe(nonexistentRecipe),
          throwsA(isA<ArgumentError>()));

      verify(mockRecipeManagement.deleteRecipe(nonexistentRecipe)).called(1);
    });

    test('updateRecipe succeeds', () async {
      final Recipe recipe = Recipe(name: "Chocolate Cake", persons: 4, time: 30, description: "Updated delicious cake", ingredients: "Chocolate, Eggs, Flour, Sugar");

      when(mockRecipeManagement.updateRecipe(recipe)).thenAnswer((_) => Future.value());

      await mockRecipeManagement.updateRecipe(recipe);

      verify(mockRecipeManagement.updateRecipe(recipe)).called(1);
    });

    test('updateRecipe fails when recipe does not exist', () async {
      final Recipe recipe = Recipe(name: "Unknown Cake", persons: 4, time: 30, description: "Does not exist", ingredients: "Nothing");

      when(mockRecipeManagement.updateRecipe(recipe)).thenThrow(Exception('Recipe not found'));

      expect(() async => await mockRecipeManagement.updateRecipe(recipe),
          throwsA(isA<Exception>()));

      verify(mockRecipeManagement.updateRecipe(recipe)).called(1);
    });

    test('updateRecipe fails with invalid update parameter', () async {
      final Recipe recipe = Recipe(name: "Chocolate Cake", persons: -1, time: 30, description: "Invalid persons count", ingredients: "Chocolate, Eggs, Flour, Sugar");

      when(mockRecipeManagement.updateRecipe(recipe)).thenThrow(ArgumentError('Invalid persons parameter'));

      expect(() async => await mockRecipeManagement.updateRecipe(recipe),
          throwsA(isA<ArgumentError>()));

      verify(mockRecipeManagement.updateRecipe(recipe)).called(1);
    });
  });
}
