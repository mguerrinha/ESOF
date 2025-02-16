import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/model/product.dart';

class CategoriesManagement {

  Future<void> fetchProductsFromFirestore(List<Product> productList) async {

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('inventory')
        .get();
    productList.clear();
    snapshot.docs.forEach((DocumentSnapshot doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        Product product = Product(
          name: data['name'] as String? ?? 'Unknown name',
          quantity: data['quantity'] as int? ?? 0,
          category: data['category'] as String? ?? 'No category',
        );
        productList.add(product);
      }
    });
  }
}
