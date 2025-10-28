import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_art_painting_entity.dart';

class ArtPaintingDatabase extends GetxService {
  static Database? _database;

  static const String _dbName = 'art_painting.db';
  static const int _dbVersion = 1;

  static const String _tableSections = 'sections';
  static const String _tableArtworks = 'artworks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableSections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableArtworks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        year INTEGER,
        medium TEXT,
        dimension_width REAL,
        dimension_height REAL,
        dimension_unit TEXT,
        image_url TEXT NOT NULL,
        description TEXT NOT NULL,
        section_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (section_id) REFERENCES $_tableSections (id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sections_category_type ON $_tableSections (category_type)',
    );
    await db.execute(
      'CREATE INDEX idx_artworks_section_id ON $_tableArtworks (section_id)',
    );

    await _loadInitialData(db);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/db_art_painting/initial_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> sectionsJson = jsonData['sections'] ?? [];
      final batch = db.batch();

      for (var sectionMap in sectionsJson) {
        batch.insert(_tableSections, {
          'name': sectionMap['name'],
          'category_type': sectionMap['category_type'],
          'created_at': sectionMap['created_at'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);

      final List<dynamic> artworksJson = jsonData['artworks'] ?? [];
      final artworksBatch = db.batch();

      for (var artworkMap in artworksJson) {
        artworksBatch.insert(_tableArtworks, {
          'title': artworkMap['title'],
          'artist': artworkMap['artist'],
          'year': artworkMap['year'],
          'medium': artworkMap['medium'],
          'dimension_width': artworkMap['dimension_width'],
          'dimension_height': artworkMap['dimension_height'],
          'dimension_unit': artworkMap['dimension_unit'],
          'image_url': artworkMap['image_url'],
          'description': artworkMap['description'],
          'section_id': artworkMap['section_id'],
          'created_at': artworkMap['created_at'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await artworksBatch.commit(noResult: true);

      print('Initial data loaded successfully');
      print(
        'Sections: ${sectionsJson.length}, Artworks: ${artworksJson.length}',
      );
    } catch (e) {
      print('Error loading initial data: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<List<SectionEntity>> getSectionsByCategoryType(
    String categoryType,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableSections,
        where: 'category_type = ?',
        whereArgs: [categoryType],
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => SectionEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting sections by category type: $e');
      return [];
    }
  }

  Future<ArtworkEntity?> getArtworkById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return ArtworkEntity.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting artwork by ID: $e');
      return null;
    }
  }

  Future<List<ArtworkEntity>> getArtworksBySectionId(int sectionId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'section_id = ?',
        whereArgs: [sectionId],
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => ArtworkEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting artworks by section: $e');
      return [];
    }
  }

  Future<List<ArtworkEntity>> getArtworksBySectionIdPaged(
    int sectionId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final offset = (page - 1) * limit;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'section_id = ?',
        whereArgs: [sectionId],
        orderBy: 'id ASC',
        limit: limit,
        offset: offset,
      );
      return List.generate(maps.length, (i) => ArtworkEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting artworks by section with pagination: $e');
      return [];
    }
  }

  Future<int> getArtworksCountBySectionId(int sectionId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM $_tableArtworks
        WHERE section_id = ?
      ''',
        [sectionId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error getting artworks count: $e');
      return 0;
    }
  }

  Future<ArtworkEntity?> getRandomArtwork() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM $_tableArtworks ORDER BY RANDOM() LIMIT 1',
      );
      if (maps.isEmpty) return null;
      return ArtworkEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting random artwork: $e');
      return null;
    }
  }
}
