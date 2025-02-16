import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../model/product.dart';
import '../../services/firestore/product_management.dart';
import '../../services/notification/local_notifications.dart';

class ProductsListView extends StatefulWidget {
  final Product product;

  const ProductsListView({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  final ProductManagement productManagement = ProductManagement();
  final TextEditingController productQuantity = TextEditingController();
  late TextEditingController dateTime = TextEditingController();
  DateTime productDateTime = DateTime.now();
  String? productCategory = "All";
  final LocalNotifications localNotifications = LocalNotifications();

  @override
  void initState() {
    super.initState();
    syncDataWithLocalDatabase();
    dateTime = TextEditingController(text: DateFormat.yMMMd().format(productDateTime));
  }

  void syncDataWithLocalDatabase() async {
    await productManagement.syncProductsWithLocalDatabase();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context, firstDate: widget.product.dateTime ?? DateTime.now(), lastDate: DateTime(3000));
    if (picked != null) {
      setState(() {
        productDateTime = picked;
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
                    Text(widget.product.name),
                    TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: productQuantity,
                      decoration: const InputDecoration(hintText: 'Quantity'),
                    ),
                    TextField(
                      controller: dateTime,
                      decoration: const InputDecoration(
                          hintText: 'Date Time',
                          filled: true,
                          prefixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () {
                        selectDate();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    int productQuant = int.parse(productQuantity.text);
                    productManagement.addProduct(Product(
                        dateTime: productDateTime,
                        name: widget.product.name,
                        quantity: productQuant,
                        category: widget.product.category,
                    ));
                    productQuantity.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ));
  }

  void openUpdateProductBox({required Product product}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Update product'),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(product.name),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: productQuantity,
                      decoration: const InputDecoration(hintText: 'Quantity'),
                    ),
                    TextField(
                      controller: dateTime,
                      decoration: const InputDecoration(
                          hintText: 'Date Time',
                          filled: true,
                          prefixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () {
                        selectDate();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    int productQuant = int.parse(productQuantity.text);
                    productManagement.updateProduct(
                        Product(
                            uid: product.uid,
                            name: product.name,
                            quantity: productQuant,
                            dateTime: productDateTime,
                            category: product.category),
                        productQuant - product.quantity);
                    dateTime.clear();
                    productQuantity.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name.toUpperCase()),
        actions: [
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
          SizedBox(width: 20,),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productManagement.getSpecificProductsStream(widget.product.name),
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
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map(buildListItem).toList(),
            );
          }
          return const Text('No items');
        },
      ),
    );
  }

  Widget buildListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic> ?? {};
    if (data['quantity'] == 0) {
      productManagement.deleteProduct(Product(uid: data['uid'],name: data['name'], quantity: 0, category: data['category']));
    }
    String name = data['name'] as String? ?? 'Unknown';
    String category = data['category'] as String? ?? 'No Category';
    String uid = data['uid'];
    int quantity = (data['quantity'] as int?) ?? 0;
    DateTime displayDate = data['dateTime'] is Timestamp
        ? (data['dateTime'] as Timestamp).toDate()
        : DateTime.now();
    String formatedDate = DateFormat.yMMMd().format(displayDate);
    Product product = Product(uid: uid, name: name, quantity: quantity, category: category, dateTime: displayDate);
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => productManagement.deleteProduct(product),
                icon: Icons.delete,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container (
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            product.category,
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          Text(
                            product.quantity.toString(),
                            style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        formatedDate,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          IconButton(
                            onPressed: () => openUpdateProductBox(product: product),
                            icon: const Icon(Icons.edit),
                            iconSize: 30,
                            color: Colors.green,
                          ),
                          IconButton(
                              onPressed: () => productManagement.updateProduct(Product(uid: uid, name: name, quantity: quantity-1, category: category, dateTime: displayDate), -1),
                              icon: Icon(Icons.clear),
                              iconSize: 30,
                              color: Colors.orange.shade800,
                          ),
                        ]
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
