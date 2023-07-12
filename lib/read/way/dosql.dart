import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

dynamic create_sql() async {
  final Directory sqldir = await getApplicationDocumentsDirectory();
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT,readpage TEXT,percentage TEXT,time INTEGER,readmoe INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 4,
  );
}

// Define a function that inserts dogs into the database
Future<void> insertsql(Map mangamap) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a reference to the database.
  print(await getDatabasesPath());
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT,readpage TEXT,percentage TEXT,time INTEGER,readmoe INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 4,
  );
  final db = await database;

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  Map<String, Object?> mangamaps = {
    'uid': mangamap["uid"],
    'title': mangamap['title'],
    'cover': mangamap['cover'],
    'author': mangamap['author'],
    'readpage': mangamap['readpage'],
    'percentage': mangamap['percentage'],
    'time': mangamap['time'],
    'readmoe': 0
  };
  await db.insert(
    'allcomic',
    mangamaps,
  );
}

Future<List<Map<String, dynamic>>> allconmic() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a reference to the database.
  print(await getDatabasesPath());
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT,readpage TEXT,percentage TEXT,time INTEGER,readmoe INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 4,
  );
  final db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query('allcomic', orderBy: 'time desc');
  print(maps.toString());
  return maps;
}

Future<List<Map<String, dynamic>>> getone(String uid) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a reference to the database.
  print(await getDatabasesPath());
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
  );
  final db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query('allcomic', where: '"group" = ?', whereArgs: [uid]);
  print(maps.toString());
  return maps;
}

Future<void> changeread(Map<String, Object?> changed) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a reference to the database.
  print(await getDatabasesPath());
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
  );
  // Get a reference to the database.
  final db = await database;
  print(changed);
  // Update the given Dog.
  await db.update(
    'allcomic',
    changed,
    // Ensure that the Dog has a matching id.
    where: 'uid = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [changed['uid']],
  );
  final List<Map<String, dynamic>> maps = await db
      .query('allcomic', where: '"uid" = ?', whereArgs: [changed['uid']]);
  print("!@#22" + maps.toString());
}

Future<bool> delcomic(String uid) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a reference to the database.
  print(await getDatabasesPath());
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'comic.db'),
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
  );
  // Get a reference to the database.
  try {
    final db = await database;
    // Update the given Dog.
    await db.delete('allcomic', where: '"uid" = ?', whereArgs: [uid]);
    //文件删除
    final Directory docDir = await getApplicationDocumentsDirectory();
    final Directory saveDir = new Directory('${docDir.path}/comic/$uid');
    saveDir.deleteSync(recursive: true);
  } catch (e) {
    print('DELETE Faild:$e');
    return false;
  }
  return true;
}
