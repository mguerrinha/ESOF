import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/shoplist_management.dart';
import 'package:spantry/services/firestore/product_actions.dart';
import 'shopping_list_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ShopListManagement>()
])

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ProductActions Tests', () {
    late MockShopListManagement mockShopListManagement;
    late ProductActions productActions;
    late TextEditingController nameController, quantityController, categoryController;

    setUp(() {
      mockShopListManagement = MockShopListManagement();
      nameController = TextEditingController();
      quantityController = TextEditingController();
      categoryController = TextEditingController();
      productActions = ProductActions(
        shopListManagement: mockShopListManagement,
        productName: nameController,
        productQuantity: quantityController,
        productCategory: categoryController,
      );
    });

    test('addProduct calls addProduct with correct product', () async {
      final product = Product(
        name: 'Apples',
        quantity: 10,
        category: 'Fruits',
      );

      await productActions.shopListManagement.addProduct(product);

      verify(mockShopListManagement.addProduct(argThat(
          isA<Product>()
              .having((p) => p.name, 'name', 'Apples')
              .having((p) => p.quantity, 'quantity', 10)
              .having((p) => p.category, 'category', 'Fruits')
      ))).called(1);
    });

    test('getProductsStream returns stream of products ordered by quantity', () async {
      when(mockShopListManagement.getProductsStream())
          .thenAnswer((_) => Stream.fromIterable([
        QuerySnapshotMock([
          QueryDocumentSnapshotMock({
            'name': 'Apples',
            'quantity': 5,
            'category': 'Fruits',
          }),
          QueryDocumentSnapshotMock({
            'name': 'Bananas',
            'quantity': 15,
            'category': 'Fruits',
          }),
        ])
      ]));

      final stream = productActions.shopListManagement.getProductsStream();
      await for (var snapshot in stream) {
        final products = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        expect(products.length, 2);
        expect(products[0]['name'], 'Apples');
        expect(products[1]['name'], 'Bananas');
      }
    });

    test('deleteProduct calls shopListManagement with correct product name', () {
      productActions.deleteProduct('Apples');

      verify(mockShopListManagement.deleteProduct('Apples')).called(1);
    });

    testWidgets('saveNewProduct navigates back when valid', (WidgetTester tester) async {
      nameController.text = 'Bananas';
      quantityController.text = '5';

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () => productActions.saveNewProduct(context),
              child: const Text('Test Button'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      verify(mockShopListManagement.addProduct(any)).called(1);
    });

    testWidgets('addNewProduct displays dialog with correct fields and can add a product', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () => productActions.addNewProduct(context),
              child: const Text('Open Dialog'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Add product'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Oranges');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '10');
      await tester.tap(find.text('Add'));
      await tester.pump();

      verify(mockShopListManagement.addProduct(any)).called(1);
    });

    testWidgets('saveNewProduct calls shopListManagement with correct product', (WidgetTester tester) async {
      nameController.text = 'Bananas';
      quantityController.text = '5';
      categoryController.text = 'Fruits';

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    productActions.saveNewProduct(context);
                  },
                  child: const Text('Test Button'),
                ),
              ),
            );
          },
        ),
      ));

      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      verify(mockShopListManagement.addProduct(argThat(
          isA<Product>().having((p) => p.name, 'name', 'Bananas')
              .having((p) => p.quantity, 'quantity', 5)
              .having((p) => p.category, 'category', 'Fruits')
      ))).called(1);
    });
  });
}

class QuerySnapshotMock extends Fake implements QuerySnapshot {
  final List<QueryDocumentSnapshotMock> documents;

  QuerySnapshotMock(this.documents);

  @override
  List<QueryDocumentSnapshot<Object?>> get docs => documents;
}

class QueryDocumentSnapshotMock extends Fake implements QueryDocumentSnapshot {
  final Map<String, dynamic> dataMap;

  QueryDocumentSnapshotMock(this.dataMap);

  @override
  Map<String, dynamic> data() => dataMap;
}