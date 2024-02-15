import 'package:fav_loc/model/Location.dart';
import 'package:riverpod/riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as systempaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final Database db = await sql.openDatabase(
    // Store the database instance in a variable
    path.join(dbPath, 'locs.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_locs(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserLocationNotifier extends StateNotifier<List<modelLocation>> {
  UserLocationNotifier() : super(const []);

  Future<void> loadLocs() async {
    final db = await _getDatabase();
    final data = await db.query('user_locs');
    final locations = data
        .map(
          (row) => modelLocation(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: yourLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();

    state = locations;
  }

  Future<void> addLocation(
      String title, File image, yourLocation location) async {
    final Directory locDir = await systempaths
        .getApplicationDocumentsDirectory(); // Await the Future
    final String filename = path.basename(image.path);
    final File copiedImage = await image.copy('${locDir.path}/$filename');
    final newLoc =
        modelLocation(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert('user_locs', {
      // Use the database instance to insert data
      'id': newLoc.id,
      'title': newLoc.title,
      'image': copiedImage.path, // Store the path of the copied image
      'lat': newLoc.location.latitude,
      'lng': newLoc.location.longitude,
      'address': newLoc.location.address,
    });

    state = [newLoc, ...state];
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, List<modelLocation>>(
  (ref) => UserLocationNotifier(),
);
