import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:spantry/model/product.dart';
import 'package:spantry/model/recipe.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'DataBase.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE ShoppingList (
          uid TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          dateTime TEXT,
          quantity INTEGER NOT NULL,
          category TEXT NOT NULL,
          "check" INTEGER,
          added INTEGER
        )
      ''');
        await db.execute('''
        CREATE TABLE Recipe (
          uid TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          persons INTEGER NOT NULL,
          description TEXT NOT NULL,
          ingredients TEXT NOT NULL,
          time INTEGER NOT NULL,
          image TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE Product (
          uid TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          dateTime TEXT,
          "check" INTEGER,
          category TEXT NOT NULL,
          added INTEGER
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE ShoppingList ADD COLUMN "check" INTEGER');
        }
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE Product (
            uid TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            dateTime TEXT,
            "check" INTEGER,
            category TEXT NOT NULL,
            added INTEGER
          )
        ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE ShoppingList ADD COLUMN added INTEGER');
          await db.execute('ALTER TABLE Product ADD COLUMN added INTEGER');
        }
      },
    );
  }

  Future<void> insertShopListProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('ShoppingList', {
        'uid': product.uid,
        'name': product.name.toLowerCase(),
        'dateTime': product.dateTime?.toIso8601String(),
        'quantity': product.quantity,
        'category': product.category,
        'check': product.check == null ? null : (product.check! ? 1 : 0),
        'added': product.added == null ? null : (product.added! ? 1 : 0),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<Product>> getShopListProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ShoppingList');
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<void> deleteShopListProduct(String uid) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'ShoppingList',
        where: 'uid = ?',
        whereArgs: [uid],
      );
    });
  }

  Future<void> updateShopListProduct(String uid, bool added) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'ShoppingList',
        {'added': added ? 1 : 0},
        where: 'uid = ?',
        whereArgs: [uid],
      );
    });
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('Recipe', {
        'uid': recipe.uid,
        'name': recipe.name.toLowerCase(),
        'persons': recipe.persons,
        'description': recipe.description,
        'ingredients': recipe.ingredients,
        'time': recipe.time,
        'image': recipe.image,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Recipe');
    return List.generate(maps.length, (i) {
      return Recipe.fromJson(maps[i]);
    });
  }

  Future<void> deleteRecipe(String uid) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'Recipe',
        where: 'uid = ?',
        whereArgs: [uid],
      );
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'Recipe',
        recipe.json(),
        where: 'uid = ?',
        whereArgs: [recipe.uid],
      );
    });
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('Product', {
        'uid': product.uid,
        'name': product.name.toLowerCase(),
        'quantity': product.quantity,
        'dateTime': product.dateTime?.toIso8601String(),
        'check': product.check == null ? null : (product.check! ? 1 : 0),
        'category': product.category,
        'added': product.added == null ? null : (product.added! ? 1 : 0),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Product');
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'Product',
        {
          'uid': product.uid,
          'name': product.name.toLowerCase(),
          'quantity': product.quantity,
          'dateTime': product.dateTime?.toIso8601String(),
          'check': product.check == null ? null : (product.check! ? 1 : 0),
          'category': product.category,
          'added': product.added == null ? null : (product.added! ? 1 : 0),
        },
        where: 'uid = ?',
        whereArgs: [product.uid],
      );
    });
  }

  Future<void> deleteProduct(String uid) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'Product',
        where: 'uid = ?',
        whereArgs: [uid],
      );
    });
  }
}
