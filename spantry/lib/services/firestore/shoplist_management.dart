import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/model/product.dart';
import '../database/database_service.dart';

class ShopListManagement {
  final CollectionReference products = FirebaseFirestore.instance.collection(
      'users').doc(FirebaseAuth.instance.currentUser!.uid).collection(
      'shoppinglist');

  final CollectionReference inventory = FirebaseFirestore.instance.collection(
      'users').doc(FirebaseAuth.instance.currentUser!.uid).collection(
      'all_products');

  final DatabaseService _databaseService = DatabaseService();

  Future<void> addProduct(Product product) async {
    final docProduct = products.doc(product.name.toLowerCase());
    product.uid = docProduct.id;
    final json = product.json();
    await docProduct.set(json);
    await _databaseService.insertShopListProduct(product);
  }

  Future<void> deleteProduct(String product) async {
    await _databaseService.deleteShopListProduct(product);
    return products.doc(product).delete();
  }

  Stream<QuerySnapshot> getProductsStream() {
    return products.orderBy('quantity').snapshots();
  }

  Future<void> generateProductList() async {
    final now = DateTime.now();
    final twoDaysLater = now.add(Duration(days: 2));

    QuerySnapshot querySnapshot = await inventory.where(
        'dateTime', isLessThanOrEqualTo: twoDaysLater).get();

    Map<String, Product> productMap = {};

    for (var doc in querySnapshot.docs) {
      var product = Product.fromJson(doc.data() as Map<String, dynamic>);
      productMap[product.name] = product;
    }

    for (var product in productMap.values) {
      await addProduct(product);
    }
  }

  Future<void> addedProduct(Product newProduct) async {
    if (newProduct.uid == null) {
      throw Exception('Product UID cannot be null');
    }

    await products.doc(newProduct.name).update({
      'added': true,
    });
    await _databaseService.updateShopListProduct(newProduct.uid!, true);
  }

  Future<void> syncShopListWithLocalDatabase() async {
    QuerySnapshot snapshot = await products.get();
    List<Product> productsList = snapshot.docs.map((doc) =>
        Product.fromJson(doc.data() as Map<String, dynamic>)).toList();

    for (var product in productsList) {
      await _databaseService.insertShopListProduct(product);
    }
  }
}