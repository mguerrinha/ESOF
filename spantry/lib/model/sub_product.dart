class SubProduct {
  final String name;
  int? quantity;
  final String category;

  SubProduct({
    required this.name,
    this.quantity,
    required this.category,
  });

  Map<String, dynamic> json() {
    return {'name': name, 'quantity': quantity, 'category': category};
  }

  static SubProduct fromJson(Map<String, dynamic> json) {
    return SubProduct(
        name: json['name'],
        quantity: json['quantity'],
        category: json['category']);
  }
}
