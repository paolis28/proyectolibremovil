import 'package:equatable/equatable.dart';

/// Entidad de dominio para Reservación
class Reservation extends Equatable {
  final int id;
  final int userId;
  final int gymAreaId;
  final int timeSlotId;
  final DateTime reservationDate;
  final String status;
  final String? notes;
  final String? gymAreaName;
  final String? gymAreaImage;
  final String? startTime;
  final String? endTime;
  final String? dayOfWeek;

  const Reservation({
    required this.id,
    required this.userId,
    required this.gymAreaId,
    required this.timeSlotId,
    required this.reservationDate,
    required this.status,
    this.notes,
    this.gymAreaName,
    this.gymAreaImage,
    this.startTime,
    this.endTime,
    this.dayOfWeek,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    gymAreaId,
    timeSlotId,
    reservationDate,
    status,
    notes,
    gymAreaName,
    gymAreaImage,
    startTime,
    endTime,
    dayOfWeek,
  ];
}