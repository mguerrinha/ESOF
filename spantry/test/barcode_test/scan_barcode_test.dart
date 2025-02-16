import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:spantry/services/firestore/scan_barcode_handler.dart';

class FakeHttpHandler extends HttpHandler {
  @override
  Future<http.Response> get(Uri url) async {
    if (url.toString() == 'https://world.openfoodfacts.org/api/v0/product/80135463.json') {
      return http.Response('''
        {
          "product": {
            "product_name": "Nutella",
            "image_url": "https://images.openfoodfacts.org/images/products/801/354/63/front_fr.5.400.jpg"
          }
        }
      ''', 200);
    }
    return http.Response('Not Found', 404);
  }
}

void main() {
  group('Unit Tests with Real HTTP Calls', () {
    test('The product was found in the database from Open Food Facts', () async {
      final handler = ScanBarcodeHandler();

      final product = await handler.fetchProductDetails('80135463');

      expect(product, isNotNull);
      expect(product!.name, isNotEmpty);
      expect(product.image, startsWith('http'));
      expect(product.barcode, '80135463');
    });
    test('The product was not found in the database from Open Food Facts', () async {
      final handler = ScanBarcodeHandler();

      final product = await handler.fetchProductDetails('99999999');

      expect(product, isNull);
    });
  });

  group('Unit Tests with Fake HTTP Calls', () {
    test('The barcode is valid', () async {
      final handler = ScanBarcodeHandler(httpHandler: FakeHttpHandler());

      final product = await handler.fetchProductDetails('80135463');

      expect(product, isNotNull);
      expect(product!.name, 'Nutella');
      expect(product.image, 'https://images.openfoodfacts.org/images/products/801/354/63/front_fr.5.400.jpg');
      expect(product.barcode, '80135463');
    });
    test('The barcode is not valid', () async {
      final handler = ScanBarcodeHandler(httpHandler: FakeHttpHandler());

      final product = await handler.fetchProductDetails('99999999');

      expect(product, isNull);
    });
  });
}

