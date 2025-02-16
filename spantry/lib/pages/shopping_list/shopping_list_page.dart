import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spantry/services/firestore/product_actions.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'package:spantry/utils/shopping_tile.dart';
import 'package:spantry/services/firestore/shoplist_management.dart';
import 'package:spantry/model/product.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  String name = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ProductManagement productManagement = ProductManagement();
  final ShopListManagement shopListManagement = ShopListManagement();
  final TextEditingController productName = TextEditingController();
  final TextEditingController productQuantity = TextEditingController();
  final TextEditingController productCategory = TextEditingController();
  late final ProductActions productActions;

  @override
  void initState() {
    super.initState();
    productActions = ProductActions(
      shopListManagement: shopListManagement,
      productName: productName,
      productQuantity: productQuantity,
      productCategory: productCategory,
    );
    syncDataWithLocalDatabase();
  }

  void syncDataWithLocalDatabase() async {
    await shopListManagement.syncShopListWithLocalDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Scaffold(
              appBar: AppBar(
                title: Text("Shopping List"),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => productActions.addNewProduct(context),
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white,),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: shopListManagement.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    /*return FutureBuilder<List<Product>>(
                        future: databaseService.getShopListProducts(),
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
                    List shoppingList = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: shoppingList.length,
                      itemBuilder: (context, index) {
                        if (index < shoppingList.length) {
                          DocumentSnapshot document = shoppingList[index];

                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          String product_Name = data['name'];
                          int product_Quantity = data['quantity'];
                          String product_Category = data['category'];
                          bool product_added = data['added'] ?? false;
                          return ShoppingTile(
                            product: Product(
                                name: product_Name,
                                quantity: product_Quantity,
                                category: product_Category,
                                added: product_added
                            ),
                            deleteFunction: (context) => shopListManagement.deleteProduct(product_Name),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    );
                  }
                  else {
                    return const Text('No items');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

