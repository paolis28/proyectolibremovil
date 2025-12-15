import '../../domain/entities/time_slot.dart';

/// Modelo de datos para Horario
class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.id,
    required super.gymAreaId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    super.isActive,
    super.availableSpots,
    super.capacity,
  });

  /// From JSON
  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as int,
      gymAreaId: json['gym_area_id'] as int,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: (json['is_active'] as int?) == 1,
      availableSpots: json['available_spots'] as int?,
      capacity: json['capacity'] as int?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_area_id': gymAreaId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive ? 1 : 0,
      'available_spots': availableSpots,
      'capacity': capacity,
    };
  }
}