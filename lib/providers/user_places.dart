import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:favorite_places/models/place.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDB() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbpath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places( id TEXT PRIMARY KEY,title TEXT,image TEXT)');
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);
  Future<void> loadPlaces() async {
    final db = await _getDB();
    final data = await db.query("user_places");
    final places = data.map(
      (e) {
        return Place(
            id: e["id"] as String,
            title: e['title'] as String,
            image: File(e['image'] as String));
      },
    ).toList();
    state = places;
  }

  void addPlace(String title, File image) async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copy = await image.copy('${appDir.path}/$filename');
    final newPlace = Place(title: title, image: copy);
    final db = await _getDB();
    db.insert('user_places', {
      "id": newPlace.id,
      "title": newPlace.title,
      "image": newPlace.image.path
    });
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
