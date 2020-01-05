import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String _databaseFile = 'resounder.db';

class Sound {
  final int id;
  final String name;

  Sound({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  Sound.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'];
}

class SoundProvider {
  static Database _database;

  static Future<Database> open() async {
    if (_database != null) return _database;

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseFile);

    _database = await openDatabase(path, version: 1,
        onCreate: (db, version) async {
          await db
              .execute("CREATE TABLE sounds(id INTEGER PRIMARY KEY, name TEXT)");
        });
    return _database;
  }

  static _checkOpen() {
    if (_database == null || !_database.isOpen) {
      throw Exception(
          "Open should be called before using any of the provider functions");
    }
  }

  static Future<Sound> insert(Sound sound) async {
    _checkOpen();
    int id = await _database.insert('sounds', sound.toMap());
    return Sound(id: id, name: sound.name);
  }

  static Future<List<Sound>> queryAll() async {
    _checkOpen();
    var soundRecords = await _database.query('sounds');
    return soundRecords.map((record) => Sound.fromMap(record)).toList();
  }

  static Future close() async {
    _database.close();
    _database = null;
  }
}