import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final int quantity;
  String? uid;
  final String category;
  DateTime? dateTime;
  String? barcode;
  String? image;
  bool? check;
  int? notificationId;
  bool? added;


  Product({
    required this.name,
    required this.quantity,
    this.uid,
    required this.category,
    this.dateTime,
    this.barcode,
    this.image,
    this.check,
    this.notificationId,
    this.added,
  });

  Map<String, dynamic> json() {
    return {
      'uid': uid,
      'name': name.toLowerCase(),
      'quantity': quantity,
      'dateTime': dateTime,
      'category': category,
      'notificationId': notificationId,
      'check': check == null ? null : (check! ? 1 : 0),
      'added': added == null ? null : (added! ? true : false),
    };
  }

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      uid: json['uid'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      dateTime: (json['dateTime'] as Timestamp?)?.toDate(),
      notificationId: json['notificationId'],
      check: json['check'] == null ? null : json['check'] == 1,
      added: json['added'] == null ? null : json['added'] == true,
    );
  }
}
