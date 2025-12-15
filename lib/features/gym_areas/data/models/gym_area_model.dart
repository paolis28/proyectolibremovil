import '../../domain/entities/gym_area.dart';

/// Modelo de datos para Área del Gimnasio
class GymAreaModel extends GymArea {
  const GymAreaModel({
    required super.id,
    required super.name,
    super.description,
    required super.capacity,
    super.imageUrl,
    super.isActive,
  });

  /// From JSON
  factory GymAreaModel.fromJson(Map<String, dynamic> json) {
    return GymAreaModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] as int?) == 1,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
    };
  }
}