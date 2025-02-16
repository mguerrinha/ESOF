import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'edit_delete_products_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductManagement>(), MockSpec<Product>()])

void main() {
  group('Firebase Firestore Tests', () {
    late MockProductManagement mockProductManagement;
    setUp(() {
      mockProductManagement = MockProductManagement();
    });

    test('deleteProduct succeeds', () async {
      final Product product = Product(name: "massa", quantity: 1, category: "All");

      when(mockProductManagement.deleteProduct(product)).thenAnswer((_) => Future.value());

      await mockProductManagement.deleteProduct(product);

      verify(mockProductManagement.deleteProduct(product)).called(1);
    });

    test('deleteProduct fails when product does not exist', () async {
      final Product nonexistentProduct = Product(name: "Fantasy", quantity: 1, category: "All");

      when(mockProductManagement.deleteProduct(nonexistentProduct)).thenThrow(ArgumentError('Product does not exist'));

      expect(() async => await mockProductManagement.deleteProduct(nonexistentProduct),
          throwsA(isA<ArgumentError>()));

      verify(mockProductManagement.deleteProduct(nonexistentProduct)).called(1);
    });

    test('deleteProduct fails with a null product', () async {
      Product? nullProduct = null;

      when(mockProductManagement.deleteProduct(nullProduct)).thenThrow(ArgumentError('Null product cannot be deleted'));

      expect(() async => await mockProductManagement.deleteProduct(nullProduct),
          throwsA(isA<ArgumentError>()));

      verify(mockProductManagement.deleteProduct(nullProduct)).called(1);
    });

    test('updateProduct succeeds', () async {
      final Product product = Product(name: "massa", quantity: 1, category: "All");

      when(mockProductManagement.updateProduct(product, 5)).thenAnswer((_) => Future.value());

      await mockProductManagement.updateProduct(product, 5);

      verify(mockProductManagement.updateProduct(product, 5)).called(1);
    });

    test('updateProduct fails with invalid update parameter', () async {
      final Product product = Product(name: "massa", quantity: 1, category: "All");

      when(mockProductManagement.updateProduct(product, -1)).thenThrow(ArgumentError('Invalid update parameter'));

      expect(() async => await mockProductManagement.updateProduct(product, -1),
          throwsA(isA<ArgumentError>()));

      verify(mockProductManagement.updateProduct(product, -1)).called(1);
    });

    test('updateProduct fails when product does not exist', () async {
      final Product product = Product(name: "Unknown", quantity: 0, category: "All");

      when(mockProductManagement.updateProduct(product, 1)).thenThrow(Exception('Product not found'));

      expect(() async => await mockProductManagement.updateProduct(product, 1),
          throwsA(isA<Exception>()));

      verify(mockProductManagement.updateProduct(product, 1)).called(1);
    });
  });
}
