import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/product.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

class HttpHandler {
  Future<http.Response> get(Uri url) {
    return http.get(url);
  }
}

class ScanBarcodeHandler {
  final HttpHandler httpHandler;
  ScanBarcodeHandler({HttpHandler? httpHandler})
      : httpHandler = httpHandler ?? HttpHandler();

  Future<Product?> scanAndFetchProduct() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      if (barcodeScanRes != '-1') {
        return fetchProductDetails(barcodeScanRes);
      }
      return null;
    } on PlatformException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Product?> fetchProductDetails(String barcode) async {
    final String apiUrl =
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
    try {
      final response = await httpHandler.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        if (productData['product'] != null) {
          return Product(
              name: productData['product']['product_name'] ?? 'No name available',
              image: productData['product']['image_url'] ?? '',
              quantity: 0,
              barcode: barcode,
              category: '');
        }
      }
    } catch (e) {
    }
    return null;
  }
}
