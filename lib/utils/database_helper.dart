import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:e_fridge/models/product.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String productTable = 'product_table';
  String colId = 'id';
  String colName = 'name';
  String colQuantity = 'quantity';
  String colExpirationDate = 'expiration_date';
  String colImage = 'image';
  String colParentId = 'parent_id';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if(_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'products.db';
    
    var productsDatabase = openDatabase(path, version: 1, onCreate: _createDB);
    return productsDatabase;
  }

  void _createDB(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $productTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
          '$colName TEXT, $colQuantity INTEGER, $colExpirationDate TEXT, $colImage TEXT, '
          '$colParentId INTEGER)');
  }

  // Get operations
  Future<List<Map<String, dynamic>>> getProductMapList() async {
    Database db = await this.database;
    var result = await db.query(productTable);
    return result;
  }

  Future<List<Map<String, dynamic>>> getProductMapListByParentId(int parentId) async {
    Database db = await this.database;
    var result = await db.query(productTable, where: '$colParentId = ?', whereArgs: [parentId]);
    return result;
  }

  // Insert operation
  Future<int> insertProduct(Product product) async {
    Database db = await this.database;
    var result = await db.insert(productTable, product.toMap());
    return result;
  }

  // Update operation
  Future<int> updateProduct(Product product) async {
    Database db = await this.database;
    var result = await db.update(productTable, product.toMap(), where: '$colId = ?', whereArgs: [product.id]);
    return result;
  }

  // Migrate operation
  Future<int> migrateProduct(Product product) async {
    Database db = await this.database;
    var result = await db.rawUpdate('UPDATE $productTable SET $colParentId = ?, $colExpirationDate = ? WHERE $colId = ?',
                                    [0, product.expirationDate, product.id]);
    return result;
  }

  // Delete operation
  Future<int> deleteProduct(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $productTable WHERE $colId = $id');
    return result;
  }

  // Get number of Product objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $productTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Converting Map to Product list
  Future<List<Product>> getProductList() async {
    var productMapList = await getProductMapList();
    int count = productMapList.length;

    List<Product> productList = List<Product>();

    for(int i = 0; i<count; i++) {
      productList.add(Product.fromMapObject(productMapList[i]));
    }

    return productList;
  }

  Future<List<Product>> getProductListByParentId(int parentId) async {
    var productMapListByParentId = await getProductMapListByParentId(parentId);
    int count = productMapListByParentId.length;

    List<Product> productListByParentId = List<Product>();

    for(int i = 0; i<count; i++) {
      productListByParentId.add(Product.fromMapObject(productMapListByParentId[i]));
    }

    return productListByParentId;
  }
}
