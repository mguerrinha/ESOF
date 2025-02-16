import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spantry/services/firestore/scan_barcode_handler.dart';
import 'package:spantry/model/product.dart';
import 'scan_barcode_widget_test.mocks.dart';

@GenerateMocks([HttpHandler, ScanBarcodeHandler])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Barcode Scanner Widget Tests', () {
    late MockScanBarcodeHandler mockScanBarcodeHandler;

    setUp(() {
      mockScanBarcodeHandler = MockScanBarcodeHandler();
    });

    testWidgets('Test handleScanBarcode method', (WidgetTester tester) async {
      when(mockScanBarcodeHandler.scanAndFetchProduct())
          .thenAnswer((_) async => Product(
        name: 'Test Product',
        quantity: 1,
        barcode: '123456789',
        category: 'Test Category',
      ));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await mockScanBarcodeHandler.scanAndFetchProduct();
              },
              child: Text('Scan Barcode'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Scan Barcode'));
      await tester.pump();

      verify(mockScanBarcodeHandler.scanAndFetchProduct()).called(1);
    });

    testWidgets('Test scanAndFetchProduct populates text field', (WidgetTester tester) async {
      when(mockScanBarcodeHandler.scanAndFetchProduct())
          .thenAnswer((_) async => Product(
        name: 'Test Product',
        quantity: 1,
        barcode: '123456789',
        category: 'Test Category',
      ));

      final TextEditingController productNameController = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextField(controller: productNameController),
                ElevatedButton(
                  onPressed: () async {
                    final product = await mockScanBarcodeHandler.scanAndFetchProduct();
                    if (product != null) {
                      productNameController.text = product.name;
                    }
                  },
                  child: Text('Scan Barcode'),
                ),
              ],
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Scan Barcode'));
      await tester.pump();

      verify(mockScanBarcodeHandler.scanAndFetchProduct()).called(1);

      await tester.pump();

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('Test dialog with product details appears', (WidgetTester tester) async {
      when(mockScanBarcodeHandler.scanAndFetchProduct())
          .thenAnswer((_) async => Product(
        name: 'Test Product',
        quantity: 1,
        barcode: '123456789',
        category: 'Test Category',
      ));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final product = await mockScanBarcodeHandler.scanAndFetchProduct();
                if (product != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Product Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Name: ${product.name}'),
                          Text('Quantity: ${product.quantity}'),
                          Text('Barcode: ${product.barcode}'),
                          Text('Category: ${product.category}'),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Text('Scan Barcode'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Scan Barcode'));
      await tester.pump();

      verify(mockScanBarcodeHandler.scanAndFetchProduct()).called(1);

      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Name: Test Product'), findsOneWidget);
      expect(find.text('Quantity: 1'), findsOneWidget);
      expect(find.text('Barcode: 123456789'), findsOneWidget);
      expect(find.text('Category: Test Category'), findsOneWidget);
    });
  });
}
