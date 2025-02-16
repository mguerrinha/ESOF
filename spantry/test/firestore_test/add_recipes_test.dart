import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/model/recipe.dart';
import 'package:spantry/services/firestore/recipe_management.dart';
import 'add_recipes_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RecipeManagement>(),
  MockSpec<Recipe>(),
])

void main() {
  group('RecipeManagement', () {
    late MockRecipeManagement mockRecipeManagement;
    late Recipe validRecipe;

    setUp(() {
      mockRecipeManagement = MockRecipeManagement();
      validRecipe = Recipe(
          name: 'Chocolate Cake',
          persons: 4,
          time: 30,
          description: 'Delicious dark chocolate cake.',
          ingredients: 'Chocolate, Flour, Sugar, Eggs'
      );

      when(mockRecipeManagement.addRecipe(validRecipe)).thenAnswer((_) async => null);
    });

    test('addRecipe succeeds', () async {
      await mockRecipeManagement.addRecipe(validRecipe);

      verify(mockRecipeManagement.addRecipe(validRecipe)).called(1);
    });

    test('addRecipe fails when recipe name contains invalid characters', () async {
      final Recipe invalidRecipe = Recipe(
          name: 'Cake@123!',
          persons: 4,
          time: 30,
          description: 'Chocolate cake with invalid characters in name.',
          ingredients: 'Chocolate, Flour, Sugar, Eggs'
      );

      when(mockRecipeManagement.addRecipe(invalidRecipe))
          .thenThrow(FormatException('Invalid characters in recipe name'));

      expect(() async => await mockRecipeManagement.addRecipe(invalidRecipe),
          throwsA(isA<FormatException>()));

      verify(mockRecipeManagement.addRecipe(invalidRecipe)).called(1);
    });

    test('addRecipe fails when recipe time is negative', () async {
      final Recipe recipeWithNegativeTime = Recipe(
          name: 'Quick Cake',
          persons: 4,
          time: -30,
          description: 'This should not be possible.',
          ingredients: 'Ingredients'
      );

      when(mockRecipeManagement.addRecipe(recipeWithNegativeTime))
          .thenThrow(ArgumentError('Negative time not allowed'));

      expect(() async => await mockRecipeManagement.addRecipe(recipeWithNegativeTime),
          throwsA(isA<ArgumentError>()));

      verify(mockRecipeManagement.addRecipe(recipeWithNegativeTime)).called(1);
    });

    test('addRecipe fails when persons count is zero', () async {
      final Recipe recipeWithZeroPersons = Recipe(
          name: 'Family Cake',
          persons: 0,
          time: 45,
          description: 'A cake for no one?',
          ingredients: 'Ingredients'
      );

      when(mockRecipeManagement.addRecipe(recipeWithZeroPersons))
          .thenThrow(ArgumentError('Persons count must be greater than zero'));

      expect(() async => await mockRecipeManagement.addRecipe(recipeWithZeroPersons),
          throwsA(isA<ArgumentError>()));

      verify(mockRecipeManagement.addRecipe(recipeWithZeroPersons)).called(1);
    });
  });
}