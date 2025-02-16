import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/product_management.dart';
import '../pages/inventory/list_products_view.dart';

class IndividualTile extends StatelessWidget {
  final Product product;
  Function(BuildContext)? deleteFunction;
  final ProductManagement productManagement = ProductManagement();

  IndividualTile({
    super.key,
    required this.product,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                onPressed: deleteFunction,
                icon: Icons.delete,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container (
            height: 100,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                            product.quantity.toString(),
                            style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        product.category,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductsListView(product: product,))),
                        icon: const Icon(Icons.edit),
                        iconSize: 30,
                        color: Colors.green,
                      ),
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
