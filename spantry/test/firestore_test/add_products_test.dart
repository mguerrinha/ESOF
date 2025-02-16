import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'add_products_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductManagement>(), MockSpec<Product>()])

void main() {
  group('Firebase Firestore Tests', () {
    late MockProductManagement mockProductManagement;
    setUp(() {
      mockProductManagement = MockProductManagement();
    });

    test('addProduct succeeds', () async {
      final Product product = Product(name: "massa", quantity: 1, category: "All");

      when(mockProductManagement.addProduct(product)).thenAnswer((_) => Future.value());

      await mockProductManagement.addProduct(product);

      verify(mockProductManagement.addProduct(product)).called(1);
    });

    test('addProduct fails when product name contains invalid characters', () async {
      final Product invalidProduct = Product(name: "Massa@123!", quantity: 1, category: "All");

      when(mockProductManagement.addProduct(invalidProduct)).thenThrow(const FormatException('Invalid characters in product name'));

      expect(() async => await mockProductManagement.addProduct(invalidProduct),
          throwsA(isA<FormatException>()));

      verify(mockProductManagement.addProduct(invalidProduct)).called(1);
    });

    test('addProduct fails when product quantity is negative', () async {
      final Product productWithNegativeQuantity = Product(name: "Massa", quantity: -5, category: "All");

      when(mockProductManagement.addProduct(productWithNegativeQuantity)).thenThrow(ArgumentError('Negative quantity not allowed'));

      expect(() async => await mockProductManagement.addProduct(productWithNegativeQuantity),
          throwsA(isA<ArgumentError>()));

      verify(mockProductManagement.addProduct(productWithNegativeQuantity)).called(1);
    });
  });
}