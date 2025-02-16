import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'package:spantry/utils/inventory_tile.dart';
import 'package:spantry/utils/utils.dart';
import '../../services/firestore/scan_barcode_handler.dart';
import 'package:spantry/services/firestore/search_products.dart';
import '../../services/notification/local_notifications.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String name = "";
  final ProductManagement productManagement = ProductManagement();
  late TextEditingController productName = TextEditingController();
  final TextEditingController productQuantity = TextEditingController();
  late TextEditingController dateTime = TextEditingController();
  DateTime productDateTime = DateTime.now();
  String? productCategory = "All";
  String productCategory1 = "All";
  final LocalNotifications localNotifications = LocalNotifications();

  @override
  void initState() {
    super.initState();
    dateTime = TextEditingController(text: DateFormat.yMMMd().format(productDateTime));
    syncDataWithLocalDatabase();
  }

  void syncDataWithLocalDatabase() async {
    await productManagement.syncProductsWithLocalDatabase();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime.now(), lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        productDateTime = picked;
        dateTime.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  Future<void> handleScanBarcode() async {
    ScanBarcodeHandler handler = ScanBarcodeHandler();
    Product? product = await handler.scanAndFetchProduct();
    if (product != null) {
      setState(() {
        productName.text = product.name;
      });
    }
  }

  void openAddProdductBox() {
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
                      key: const Key('name'),
                      controller: productName,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                    TextField(
                      key: const Key('quantity'),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: productQuantity,
                      decoration: const InputDecoration(hintText: 'Quantity'),
                    ),
                    DropdownButtonFormField<String>(
                        value: productCategory,
                        icon: const Icon(Icons.menu),
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          filled: true,

                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            productCategory = newValue!;
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Protein',child: Text('Protein'),),
                          DropdownMenuItem(value: 'Carbohydrates', child: Text('Carbohydrates')),
                          DropdownMenuItem(value: 'Legumes', child: Text('Legumes')),
                          DropdownMenuItem(value: 'Vegetables',child: Text('Vegetables'),),
                          DropdownMenuItem(value: 'Fruits',child: Text('Fruits'),),
                          DropdownMenuItem(value: 'Grease',child: Text('Grease')),
                          DropdownMenuItem(value: 'Dairy',child: Text('Dairy')),
                        ],
                    ),
                    TextField(
                      controller: dateTime,
                      decoration: const InputDecoration(
                          hintText: "Date time",
                          filled: true,
                          suffixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () {
                        selectDate();
                        setState(() {

                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: handleScanBarcode,
                    child: const Text('Scan Barcode')
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (productName.text.isEmpty || productQuantity.text.isEmpty) {
                      Utils.showSnackBar("All fields must be completed", Colors.red);
                    }
                    else {

                      productManagement.addProduct(Product(
                        name: productName.text,
                        quantity: int.parse(productQuantity.text),
                        dateTime: productDateTime,
                        category: productCategory ?? "All",
                      ));
                      productName.clear();
                      productQuantity.clear();
                      Navigator.pop(context);
                      productCategory = "All";
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    SearchProducts searchProducts = SearchProducts(productManagement: productManagement);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Scaffold(
              appBar: AppBar(
                title: Card(
                  child: TextField(
                    controller: TextEditingController(text: name)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: name.length),
                      ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            name = '';
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                  ),
                ),
                actions: [
                  DropdownButton(
                    value: productCategory1,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Protein',child: Text('Protein'),),
                        DropdownMenuItem(value: 'Carbohydrates', child: Text('Carbohydrates')),
                        DropdownMenuItem(value: 'Legumes', child: Text('Legumes')),
                        DropdownMenuItem(value: 'Vegetables',child: Text('Vegetables'),),
                        DropdownMenuItem(value: 'Fruits',child: Text('Fruits'),),
                        DropdownMenuItem(value: 'Grease',child: Text('Grease')),
                        DropdownMenuItem(value: 'Dairy',child: Text('Dairy')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          productCategory1 = newValue!;
                        });
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                  ),

                  SizedBox(width: 10,),

                  ElevatedButton(
                      onPressed: openAddProdductBox,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 20,)
                ],
              ),

              body: StreamBuilder<QuerySnapshot>(
                stream: productManagement.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    /*return FutureBuilder<List<Product>>(
                        future: databaseService.getProducts(),
                        builder: (context, localSnapshot) {
                          if (localSnapshot.hasData) {
                            return ListView(
                              children: localSnapshot.data!.map<Widget>((product) => buildLocalItemsList(product)).toList(),
                            );
                          }
                          return const Text('No items');
                          });*/
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> filteredCategory = searchProducts.filterCategories(snapshot.data!.docs, productCategory1);
                    List<DocumentSnapshot> filteredDocs = searchProducts.filterDocuments(filteredCategory, name);
                    return ListView(
                      children: filteredDocs.map(buildListItem).toList(),
                    );
                  }
                  return const Text('No items');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic> ?? {};
    if (data['quantity'] == 0) {
      productManagement.deleteProductCollection(Product(name: data['name'], quantity: 0, category: data['category']));
    }
    String name = data['name'] as String? ?? 'Unknown';
    String category = data['category'] as String? ?? 'No Category';
    int quantity = (data['quantity'] as int?) ?? 0;
    Product product = Product(name: name, quantity: quantity, category: category);
    return InventoryTile(product: product,
        deleteFunction: (context) => productManagement.deleteProductCollection(product));
  }
}
