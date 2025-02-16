import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spantry/services/firestore/search_products.dart';
import '../firestore_test/add_products_test.mocks.dart';
import '../search_test/search_test.dart';
import 'package:flutter/material.dart';

@GenerateMocks([DocumentSnapshot])

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Category Filtering Tests', () {
    late SearchProducts searchProducts;
    late MockProductManagement mockProductManagement;

    setUp(() {
      mockProductManagement = MockProductManagement();
      searchProducts = SearchProducts(productManagement: mockProductManagement);
    });

    test('filterCategories filters by specific category', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'Apple', 'category': 'Fruits'}),
        DocumentSnapshotMock('2', {'name': 'Broccoli', 'category': 'Vegetables'})
      ];

      final filteredDocs = searchProducts.filterCategories(docs, 'Fruits');

      expect(filteredDocs.length, 1);
      expect(filteredDocs.first.id, '1');
    });

    test('filterCategories handles the "All" category', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'Apple', 'category': 'Fruits'}),
        DocumentSnapshotMock('2', {'name': 'Broccoli', 'category': 'Vegetables'})
      ];

      final filteredDocs = searchProducts.filterCategories(docs, 'All');

      expect(filteredDocs.length, 2);
      expect(filteredDocs.map((doc) => doc.id), containsAll(['1', '2']));
    });

    test('filterCategories returns empty if no match', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'Apple', 'category': 'Fruits'}),
        DocumentSnapshotMock('2', {'name': 'Broccoli', 'category': 'Vegetables'})
      ];

      final filteredDocs = searchProducts.filterCategories(docs, 'Dairy');

      expect(filteredDocs.isEmpty, true);
    });
  });

  group('Dropdown Button Tests', () {
    testWidgets('Dropdown initializes with correct value', (WidgetTester tester) async {
      String productCategory1 = 'All';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DropdownButton<String>(
            value: productCategory1,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Meat', child: Text('Meat')),
              DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
              DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
            ],
            onChanged: (String? newValue) {
              productCategory1 = newValue!;
            },
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ));

      expect(find.text('All'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('Dropdown changes value when an item is tapped', (WidgetTester tester) async {
      String productCategory1 = 'All';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test AppBar'),
            actions: <Widget>[
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: productCategory1,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Meat', child: Text('Meat')),
                      DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
                      DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        productCategory1 = newValue!;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  );
                },
              ),
            ],
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meat').last);
      await tester.pumpAndSettle();

      expect(find.text('Meat'), findsOneWidget);
    });

    testWidgets('Dropdown displays all options correctly', (WidgetTester tester) async {
      String productCategory1 = 'All';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test AppBar'),
            actions: <Widget>[
              DropdownButton<String>(
                value: productCategory1,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Meat', child: Text('Meat')),
                  DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
                  DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
                ],
                onChanged: (String? newValue) {},
                icon: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsWidgets);
      expect(find.text('Meat'), findsOneWidget);
      expect(find.text('Vegetables'), findsOneWidget);
      expect(find.text('Fruits'), findsOneWidget);
    });
  });
}
