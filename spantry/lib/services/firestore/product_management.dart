import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/model/sub_product.dart';
import 'package:spantry/services/notification/local_notifications.dart';
import '../database/database_service.dart';

class ProductManagement {
  final CollectionReference products = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('inventory');

  final CollectionReference all_products = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('all_products');
  final LocalNotifications localNotifications = LocalNotifications();

  final DatabaseService _databaseService = DatabaseService();

  Future<void> addProduct(Product product) async {
    final LocalNotifications localNotifications = LocalNotifications();
    product.notificationId = await localNotifications.scheduleNotification(product);
    var docSnapshot = await products.doc(product.name.toLowerCase()).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      products
          .doc(product.name.toLowerCase())
          .update({'quantity': data?['quantity'] + product.quantity});
      final docProduct = products
          .doc(product.name.toLowerCase())
          .collection('individual')
          .doc();
      final docProduct2 = all_products.doc(docProduct.id);
      product.uid = docProduct.id;
      final json = product.json();
      await docProduct.set(json);
      await docProduct2.set(json);
      await _databaseService.insertProduct(product);
      return;
    }
    SubProduct subProduct = SubProduct(
        name: product.name.toLowerCase(),
        quantity: product.quantity,
        category: product.category
        );
    final docSubProduct = products.doc(subProduct.name.toLowerCase());
    final json1 = subProduct.json();
    await docSubProduct.set(json1);
    final docProduct = products
        .doc(subProduct.name.toLowerCase())
        .collection('individual')
        .doc();
    final docProduct2 = all_products.doc(docProduct.id);
    product.uid = docProduct.id;
    final json = product.json();
    await docProduct.set(json);
    await docProduct2.set(json);
    await _databaseService.insertProduct(product);
  }

  Stream<QuerySnapshot> getProductsStream() {
    return products.orderBy('quantity').snapshots();
  }

  Stream<QuerySnapshot> getSpecificProductsStream(String name) {
    return products
        .doc(name)
        .collection('individual')
        .orderBy('dateTime')
        .snapshots();
  }
  
  Stream<QuerySnapshot> getAllProductsStream() {
    return all_products.orderBy('dateTime').snapshots();
  }

  Future<void> updateProduct(Product newProduct, int update) async {
    final LocalNotifications localNotifications = LocalNotifications();
    localNotifications.cancelNotification(newProduct.notificationId ?? 0);
    final notificationId = await localNotifications.scheduleNotification(newProduct);
    var docSnapshot = await products.doc(newProduct.name).get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    products.doc(newProduct.name).update({
      'quantity': data?['quantity'] + update,
    });

    all_products.doc(newProduct.uid).update({
      'quantity' : newProduct.quantity,
      'dateTime' : newProduct.dateTime,
      'notificationId' : notificationId,
    });
    await _databaseService.updateProduct(newProduct);

    return products
        .doc(newProduct.name)
        .collection('individual')
        .doc(newProduct.uid)
        .update({
      'quantity': newProduct.quantity,
      'dateTime': newProduct.dateTime,
      'notificationId' : notificationId,
    });
  }

  Future<void> deleteProduct(Product product) async {
    LocalNotifications localNotifications = LocalNotifications();
    await localNotifications.cancelNotification(product.notificationId ?? 0);
    var docSnapshot = await products.doc(product.name).get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    products
        .doc(product.name)
        .update({'quantity': data?['quantity'] - product.quantity});

    all_products.doc(product.uid).delete();
    await _databaseService.deleteProduct(product.uid!);

    return products
        .doc(product.name)
        .collection('individual')
        .doc(product.uid)
        .delete();
  }

  Future<void> deleteProductCollection(Product product) async {
    LocalNotifications localNotifications = LocalNotifications();
    products.doc(product.name).collection('individual').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    QuerySnapshot querySnapshot = await all_products.where('name', isEqualTo: product.name).get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int notificationId = data['notificationId'];
      await _databaseService.deleteProduct(doc.id);
      await all_products.doc(doc.id).delete();
      await localNotifications.cancelNotification(notificationId);
    }
    return products.doc(product.name).delete();
  }

  Future<void> syncProductsWithLocalDatabase() async {
    QuerySnapshot snapshot = await all_products.get();
    List<Product> productsList = snapshot.docs.map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>)).toList();

    for (var product in productsList) {
      await _databaseService.insertProduct(product);
    }
  }
}
