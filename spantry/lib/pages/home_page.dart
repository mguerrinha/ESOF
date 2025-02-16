import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:spantry/pages/inventory/inventory_page.dart';
import 'package:spantry/pages/recipes/recipe_details_page.dart';
import 'package:spantry/services/database/database_service.dart';
import 'package:spantry/services/firestore/product_management.dart';
import 'package:spantry/services/firestore/recipe_management.dart';
import 'package:spantry/services/notification/local_notifications.dart';
import 'package:spantry/utils/pick_image.dart';
import '../model/product.dart';
import '../model/recipe.dart';
import '../services/firestore/scan_barcode_handler.dart';
import '../services/firestore/shoplist_management.dart';
import '../utils/utils.dart';
import '../utils/scroller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final productManagement = ProductManagement();
  List<Widget> pages = <Widget>[
    const HomePage(),
    const InventoryPage(),
  ];

  final ShopListManagement shopListManagement = ShopListManagement();
  final RecipeManagement recipeManagement = RecipeManagement();
  final CategoriesScroller categoriesScroller = CategoriesScroller();
  late TextEditingController recipeName = TextEditingController();
  late TextEditingController recipePersons = TextEditingController();
  late TextEditingController recipeTime = TextEditingController();
  late TextEditingController recipeDescription = TextEditingController();
  late TextEditingController recipeIngredients = TextEditingController();
  final DatabaseService databaseService = DatabaseService();

  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    syncDataWithLocalDatabase();
    dateTime =
        TextEditingController(text: DateFormat.yMMMd().format(productDateTime));
  }

  void syncDataWithLocalDatabase() async {
    await shopListManagement.syncShopListWithLocalDatabase();
    await recipeManagement.syncRecipesWithLocalDatabase();
    await productManagement.syncProductsWithLocalDatabase();
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void addRecipe() async {
    if (recipeName.text.isEmpty ||
        recipePersons.text.isEmpty ||
        recipeTime.text.isEmpty ||
        recipeDescription.text.isEmpty ||
        recipeIngredients.text.isEmpty ||
        _image == null) {
      Utils.showSnackBar("All fields must be completed", Colors.red);
    } else {
      try {
        String imageUrl = await recipeManagement.uploadImageToStorage(
            'recipes/${recipeName.text}', _image!);

        Recipe newRecipe = Recipe(
          name: recipeName.text,
          persons: int.parse(recipePersons.text),
          description: recipeDescription.text,
          ingredients: recipeIngredients.text,
          time: int.parse(recipeTime.text),
          image: imageUrl,
        );

        recipeManagement.addRecipe(newRecipe);

        recipeName.clear();
        recipeTime.clear();
        recipePersons.clear();
        recipeDescription.clear();
        recipeIngredients.clear();
        _image = null;

        Navigator.pop(context);
      } catch (e) {
        Utils.showSnackBar(
            "Failed to upload image: ${e.toString()}", Colors.red);
      }
    }
  }

  void openAddRecipeBox() {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              scrollable: true,
              title: const Text('Add recipe'),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Text('Image: '),
                          IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: selectImage,
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: recipeName,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                    TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: recipePersons,
                      decoration: const InputDecoration(hintText: 'Persons'),
                    ),
                    TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: recipeTime,
                      decoration:
                      const InputDecoration(hintText: 'Cook Time (min)'),
                    ),
                    TextField(
                      controller: recipeIngredients,
                      decoration:
                      const InputDecoration(hintText: 'Ingredients'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 1,
                    ),
                    TextField(
                      controller: recipeDescription,
                      decoration:
                      const InputDecoration(hintText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 1,
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: addRecipe,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ));
  }

  String name = "";
  late TextEditingController productName = TextEditingController();
  final TextEditingController productQuantity = TextEditingController();
  late TextEditingController dateTime = TextEditingController();
  DateTime productDateTime = DateTime.now();
  String? productCategory = "All";
  String productCategory1 = "All";
  final LocalNotifications localNotifications = LocalNotifications();

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

  void openAddProdductBox() {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
                      onChanged: (String? newValue) {
                        setState(() {
                          productCategory = newValue!;
                        });
                      },
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
                  onPressed: () async {
                    if (productName.text.isEmpty ||
                        productQuantity.text.isEmpty) {
                      Utils.showSnackBar(
                          "All fields must be completed", Colors.red);
                    } else {
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

  void openUpdateProductBox({required Product product}) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
        body: Column(
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(children: [
                    const Text(
                      'My Products',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(
                      width: 114,
                    ),
                    ElevatedButton(
                      onPressed: openAddProdductBox,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ])),
            ),
            Container(
              color: Colors.green.shade100,
              height: 5,
              width: double.infinity,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: productManagement.getAllProductsStream(),
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
                  if (snapshot.connectionState == ConnectionState.waiting)
                    {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data!.docs.map(buildItemsList)
                            .toList(),
                      );
                    }
                    return const Text('No items');
                  },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(children: [
                    const Text(
                      'My Recipes',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(
                      width: 128,
                    ),
                    ElevatedButton(
                      onPressed: openAddRecipeBox,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ])),
            ),
            Container(
              color: Colors.green.shade100,
              height: 5,
              width: double.infinity,
            ),
            const SizedBox(height: 5),
            Flexible(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: recipeManagement.getRecipesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    return ListView(
                      children: snapshot.data!.docs.map(buildRecipeList)
                          .toList(),
                    );
                  }
                  return const Text('No items');
                },
              ),
            ),
          ],
        ));
  }

  Widget buildItemsList(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic> ?? {};
    String name = data['name'] as String? ?? 'Unknown';
    String category = data['category'] as String? ?? 'No Category';
    String uid = data['uid'];
    int quantity = (data['quantity'] as int?) ?? 0;
    DateTime displayDate = data['dateTime'] is Timestamp
        ? (data['dateTime'] as Timestamp).toDate()
        : DateTime.now();
    String formatedDate = DateFormat.yMMMd().format(displayDate);
    Product product = Product(uid: uid,
        name: name,
        quantity: quantity,
        category: category,
        dateTime: displayDate);

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      category,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
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
                    children: <Widget>[
                      IconButton(
                        onPressed: () => openUpdateProductBox(product: product),
                        icon: const Icon(Icons.edit),
                        iconSize: 30,
                        color: Colors.green,
                      ),
                      IconButton(
                        onPressed: () => productManagement.updateProduct(
                            Product(uid: uid,
                                name: name,
                                quantity: quantity - 1,
                                category: category,
                                dateTime: displayDate), -1),
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
    );
  }

/*
  Widget buildLocalItemsList(Product product) {
    String formattedDate = DateFormat.yMMMd().format(product.dateTime ?? DateTime.now());

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      product.category,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    Text(
                      "${product.quantity}",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: () => openUpdateProductBox(product: product),
                        icon: const Icon(Icons.edit),
                        iconSize: 30,
                        color: Colors.green,
                      ),
                      IconButton(
                        onPressed: () => productManagement.updateProduct(
                            Product(
                                uid: product.uid,
                                name: product.name,
                                quantity: product.quantity - 1,
                                category: product.category,
                                dateTime: product.dateTime),
                            -1),
                        icon: Icon(Icons.clear),
                        iconSize: 30,
                        color: Colors.orange.shade800,
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
*/

  Widget buildRecipeList(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>? ?? {};
    String name = data['name'] as String? ?? 'Unknown';
    int persons = (data['persons'] as int?) ?? 0;
    int time = (data['time'] as int?) ?? 0;
    String imageUrl = data['image'] as String? ?? '';
    String description = data['description'] as String? ?? 'No description';
    String ingredients = data['ingredients'] as String? ?? 'No ingredients';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipeDetailsPage(
                  name: name,
                  persons: persons,
                  time: time,
                  imageUrl: imageUrl,
                  description: description,
                  ingredients: ingredients,
                ),
          ),
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$persons",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.access_time,
                          color: Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$time min",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(20.0)),
                child: imageUrl.isEmpty
                    ? Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text('No image available'),
                )
                    : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
