import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'package:spantry/services/firestore/search_products.dart';
import 'search_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductManagement>()
])

void main() {
  group('Search Products Tests', () {
    late MockProductManagement mockProductManagement;
    late SearchProducts searchProducts;

    setUp(() {
      mockProductManagement = MockProductManagement();
      searchProducts = SearchProducts(productManagement: mockProductManagement);
    });

    test('filterDocuments filters by name', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'massa', 'quantity': 2}),
        DocumentSnapshotMock('2', {'name': 'sugar', 'quantity': 1})
      ];

      final filteredDocs = searchProducts.filterDocuments(docs, 'mass');

      expect(filteredDocs.length, 1);
      expect(filteredDocs.first.id, '1');
    });

    test('filterDocuments filters by quantity', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'massa', 'quantity': 2}),
        DocumentSnapshotMock('2', {'name': 'sugar', 'quantity': 1})
      ];

      final filteredDocs = searchProducts.filterDocuments(docs, '1');

      expect(filteredDocs.length, 1);
      expect(filteredDocs.first.id, '2');
    });

    test('filterDocuments returns empty if no match', () {
      final List<DocumentSnapshot> docs = [
        DocumentSnapshotMock('1', {'name': 'massa', 'quantity': 2}),
        DocumentSnapshotMock('2', {'name': 'sugar', 'quantity': 1})
      ];

      final filteredDocs = searchProducts.filterDocuments(docs, 'butter');

      expect(filteredDocs.isEmpty, true);
    });

    testWidgets('Search field initializes with provided text', (WidgetTester tester) async {
      String searchText = 'initial text';
      TextEditingController controller = TextEditingController(text: searchText);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Card(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ));

      expect(find.text(searchText), findsOneWidget);
    });

    testWidgets('Typing in search updates the text', (WidgetTester tester) async {
      TextEditingController controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Card(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ));

      String inputText = 'hello';
      await tester.enterText(find.byType(TextField), inputText);
      await tester.pump();

      expect(find.text(inputText), findsOneWidget);
    });
  });
}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  DocumentSnapshotMock(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;
}