

class SectionEntity {
  final int? id;
  final String name; 
  final String categoryType; 
  final String? createdAt;

  const SectionEntity({
    this.id,
    required this.name,
    required this.categoryType,
    this.createdAt,
  });

  factory SectionEntity.fromMap(Map<String, dynamic> map) {
    return SectionEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryType: map['category_type'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category_type': categoryType,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class ArtworkEntity {
  final int? id;
  final String title; 
  final String artist; 
  final int? year; 
  final String? medium; 
  final double? dimensionWidth; 
  final double? dimensionHeight; 
  final String? dimensionUnit; 
  final String imageUrl; 
  final String description; 
  final int sectionId; 
  final String? createdAt;

  const ArtworkEntity({
    this.id,
    required this.title,
    required this.artist,
    this.year,
    this.medium,
    this.dimensionWidth,
    this.dimensionHeight,
    this.dimensionUnit,
    required this.imageUrl,
    required this.description,
    required this.sectionId,
    this.createdAt,
  });

  factory ArtworkEntity.fromMap(Map<String, dynamic> map) {
    return ArtworkEntity(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String,
      year: map['year'] as int?,
      medium: map['medium'] as String?,
      dimensionWidth: map['dimension_width'] as double?,
      dimensionHeight: map['dimension_height'] as double?,
      dimensionUnit: map['dimension_unit'] as String?,
      imageUrl: map['image_url'] as String,
      description: map['description'] as String,
      sectionId: map['section_id'] as int,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'medium': medium,
      'dimension_width': dimensionWidth,
      'dimension_height': dimensionHeight,
      'dimension_unit': dimensionUnit,
      'image_url': imageUrl,
      'description': description,
      'section_id': sectionId,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

