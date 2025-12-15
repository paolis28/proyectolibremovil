import 'package:equatable/equatable.dart';

/// Entidad de dominio para Área del Gimnasio
class GymArea extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int capacity;
  final String? imageUrl;
  final bool isActive;

  const GymArea({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    this.imageUrl,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, capacity, imageUrl, isActive];
}