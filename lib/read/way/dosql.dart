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
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
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
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
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
        'CREATE TABLE allcomic(uid TEXT PRIMARY KEY, title TEXT, cover TEXT,author TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('allcomic');
  print(maps.toString());
  return maps;
}
