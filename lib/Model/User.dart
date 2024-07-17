import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class User {
  int? id;
  String country;
  String username;
  String email;
  bool emailUsed;

  User({this.id, required this.country, required this.username, required this.email, required this.emailUsed});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country': country,
      'username': username,
      'email': email,
      'email_used': emailUsed ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      country: map['country'],
      username: map['username'],
      email: map['email'],
      emailUsed: map['email_used'] == 1,
    );
  }
}

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/my_database.db';
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          country TEXT,
          username TEXT,
          email TEXT,
          email_used INTEGER
        )
      ''');
    });
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    var users = await db.query('users', orderBy: 'id ASC');
    return users.isNotEmpty ? users.map((c) => User.fromMap(c)).toList() : [];
  }

  Future<int> addUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
