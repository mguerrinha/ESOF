import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_management.dart';

class SearchProducts {
  final ProductManagement productManagement;

  SearchProducts({required this.productManagement});

  List<DocumentSnapshot> filterDocuments(List<DocumentSnapshot> docs, String name) {
    return docs.where((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final isNumeric = double.tryParse(name) != null;
      if (isNumeric) {
        final inputNumber = int.tryParse(name);
        return data.containsKey('quantity') && data['quantity'] == inputNumber;
      } else {
        return data['name'].toString().toLowerCase().startsWith(name.toLowerCase());
      }
    }).toList();
  }

  List<DocumentSnapshot> filterCategories(List<DocumentSnapshot> docs, String categories) {
    return docs.where((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      if (categories == "All") {
        return data['name'].toString().toLowerCase().startsWith("");
      }
      else {
        return data['category'].toString().startsWith(categories);
      }
    }).toList();
  }
}
