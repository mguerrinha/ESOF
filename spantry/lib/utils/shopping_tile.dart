import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'package:spantry/services/firestore/shoplist_management.dart';
import 'package:spantry/pages/inventory/inventory_page.dart';
import '../../services/firestore/scan_barcode_handler.dart';
import 'package:flutter/services.dart';
import 'package:spantry/utils/utils.dart';

class ShoppingTile extends StatefulWidget {
  final Product product;
  final Function(BuildContext)? deleteFunction;

  ShoppingTile({
    Key? key,
    required this.product,
    required this.deleteFunction,
  }) : super(key: key);

  @override
  _ShoppingTileState createState() => _ShoppingTileState();
}

class _ShoppingTileState extends State<ShoppingTile> {
  final productManagement = ProductManagement();
  final shopListManagement = ShopListManagement();
  final inventoryPage = InventoryPage();
  DateTime productDateTime = DateTime.now();
  late TextEditingController productName;
  late TextEditingController productQuantity;
  late TextEditingController dateTime = TextEditingController();
  late String productCategory = "All";

  @override
  void initState() {
    super.initState();
    productName = TextEditingController(text: widget.product.name);
    productQuantity =
        TextEditingController(text: widget.product.quantity.toString());
    productDateTime = widget.product.dateTime ?? DateTime.now();
    dateTime =
        TextEditingController(text: DateFormat.yMMMd().format(productDateTime));
  }

  void addProduct(Product product) {
    setState(() {
      widget.product.added = true;
      widget.product.uid ??= DateTime.now().millisecondsSinceEpoch.toString();
      widget.product.dateTime = productDateTime;
    });

    Product productFinal = Product(
      name: widget.product.name,
      quantity: widget.product.quantity,
      category: productCategory,
      uid: widget.product.uid,
      dateTime: widget.product.dateTime,
    );

    shopListManagement.addedProduct(productFinal);
    productManagement.addProduct(productFinal);
    shopListManagement.syncShopListWithLocalDatabase();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
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

  @override
  void dispose() {
    productQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  handleDelete(context);
                },
                icon: Icons.delete,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.product.name),
                Text('${widget.product.quantity}'),
                widget.product.added != true
                    ? IconButton(
                        onPressed: () {
                          openAddProdductBox();
                        },
                        icon: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.kitchen,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Text(
                          'Added!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }

  void handleDelete(BuildContext context) {
    widget.deleteFunction!(context);
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
                      controller: productName,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                    TextField(
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
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(
                          value: 'Protein',
                          child: Text('Protein'),
                        ),
                        DropdownMenuItem(
                            value: 'Carbohydrates',
                            child: Text('Carbohydrates')),
                        DropdownMenuItem(
                            value: 'Legumes', child: Text('Legumes')),
                        DropdownMenuItem(
                          value: 'Vegetables',
                          child: Text('Vegetables'),
                        ),
                        DropdownMenuItem(
                          value: 'Fruits',
                          child: Text('Fruits'),
                        ),
                        DropdownMenuItem(
                            value: 'Grease', child: Text('Grease')),
                        DropdownMenuItem(value: 'Dairy', child: Text('Dairy')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          productCategory = newValue!;
                        });
                      },
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
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: handleScanBarcode,
                    child: const Text('Scan Barcode')),
                ElevatedButton(
                  onPressed: () {
                    if (productName.text.isEmpty ||
                        productQuantity.text.isEmpty) {
                      Utils.showSnackBar(
                          "All fields must be completed", Colors.red);
                    } else {
                      addProduct(Product(
                        name: productName.text,
                        quantity: int.parse(productQuantity.text),
                        dateTime: productDateTime,
                        category: productCategory,
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
}
