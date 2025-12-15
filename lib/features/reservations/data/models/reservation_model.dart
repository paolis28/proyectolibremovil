import '../../domain/entities/reservation.dart';

/// Modelo de datos para Reservación
class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.userId,
    required super.gymAreaId,
    required super.timeSlotId,
    required super.reservationDate,
    required super.status,
    super.notes,
    super.gymAreaName,
    super.gymAreaImage,
    super.startTime,
    super.endTime,
    super.dayOfWeek,
  });

  /// From JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      gymAreaId: json['gym_area_id'] as int,
      timeSlotId: json['time_slot_id'] as int,
      reservationDate: DateTime.parse(json['reservation_date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      gymAreaName: json['gym_area_name'] as String?,
      gymAreaImage: json['gym_area_image'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      dayOfWeek: json['day_of_week'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gym_area_id': gymAreaId,
      'time_slot_id': timeSlotId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
      'gym_area_name': gymAreaName,
      'gym_area_image': gymAreaImage,
      'start_time': startTime,
      'end_time': endTime,
      'day_of_week': dayOfWeek,
    };
  }
}