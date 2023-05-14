import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "people.db";
  static const _databaseVersion = 1;
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }


  /// create a database and table.
   Future _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  /// adding/create item
  static Future<int> createItem(String? title, String? description) async {
    Database db = await instance.database;
    final data = {'title': title, 'description': description};
    final id = await db.insert(
      'items',                    /// table name.
      data,
      /// An enumeration specifying how to handle conflicts that may occur when inserting or updating data in the database.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  /// read item
  static Future<List<Map<String, dynamic>>> getItems() async {
    Database db = await instance.database;
    return db.query(
      'items',
      orderBy: 'id',
    );
  }

  /// edit item.
  static Future<int> updateItem(int id, String title, String? description) async {
    print(' >>> id = $id  ');
    print(' >>> title = $title  ');
    print(' >>> description = $description  ');
    Database db = await instance.database;
    final data = {
      'title' : title,
      'description' : description,
      'createdAt' : DateTime.now().toString(),
    };
    final result = await db.update(
      'items',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  /// delete item.
  static Future<void> deleteItem(int id) async {
    Database db = await instance.database;
    try {
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch(err) {
      print('Something went wrong when deleting an item: $err');
    }
  }
}