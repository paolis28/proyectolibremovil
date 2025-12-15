import 'package:equatable/equatable.dart';

/// Entidad de Horario (Time Slot)
class TimeSlot extends Equatable {
  final int id;
  final int gymAreaId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;
  final int? availableSpots; // Espacios disponibles (puede ser null)
  final int? capacity; // Capacidad total (puede ser null)

  const TimeSlot({
    required this.id,
    required this.gymAreaId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.availableSpots,
    this.capacity,
  });

  // Getter para compatibilidad con el código existente
  int? get availableCapacity => availableSpots ?? capacity;

  // Getter para capacidad total
  int get totalCapacity => capacity ?? availableSpots ?? 0;

  @override
  List<Object?> get props => [
    id,
    gymAreaId,
    dayOfWeek,
    startTime,
    endTime,
    isActive,
    availableSpots,
    capacity,
  ];

  @override
  bool get stringify => true;

  // CopyWith para crear copias modificadas
  TimeSlot copyWith({
    int? id,
    int? gymAreaId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
    int? availableSpots,
    int? capacity,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      gymAreaId: gymAreaId ?? this.gymAreaId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      availableSpots: availableSpots ?? this.availableSpots,
      capacity: capacity ?? this.capacity,
    );
  }
}