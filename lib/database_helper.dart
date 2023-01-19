import 'Note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper databaseHelper = DatabaseHelper._createInstance();
  static Database? _database;

  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initalizeDatabase();
    return _database;
  }

  Future<Database> initalizeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    db.execute(
        'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await database;
    var result = db!.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database? db = await database;
    var result = db!.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database? db = await database;
    var result = await db!.update(noteTable, note.toMap(),
        where: '$colID = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int? id) async {
    Database? db = await database;
    var result =
        await db!.rawDelete('DELETE FROM $noteTable where $colID = $id');
    return result;
  }

  Future<int?> getCount() async {
    Database? db = await database;
    List<Map<String, dynamic>> x =
        await db!.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();

    int count = noteMapList.length;

    List<Note> noteList = <Note>[];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
