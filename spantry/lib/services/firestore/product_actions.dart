import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spantry/services/firestore/shoplist_management.dart';
import '../../model/product.dart';

class ProductActions {
  final ShopListManagement shopListManagement;
  final TextEditingController productName;
  final TextEditingController productQuantity;
  final TextEditingController productCategory;

  ProductActions({
    required this.shopListManagement,
    required this.productName,
    required this.productQuantity,
    required this.productCategory,
  });

  void saveNewProduct(BuildContext context) {
    int productQuant = int.tryParse(productQuantity.text) ?? 0;
    if (productName.text.isNotEmpty && productQuant > 0) {
      shopListManagement.addProduct(Product(
        name: productName.text,
        quantity: productQuant,
        category: productCategory.text,
        added: false
      ));
      productName.clear();
      productQuantity.clear();
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteProduct(String product) async {
    shopListManagement.deleteProduct(product);
  }

  Future<void> addNewProduct(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            scrollable: true,
            title: const Text('Add product'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: productName,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    controller: productQuantity,
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => shopListManagement.generateProductList(),
                  child: const Text('Generate'),
              ),
              ElevatedButton(
                onPressed: () => saveNewProduct(context),
                child: const Text('Add'),
              ),
            ]
        )
    );
  }
}
