import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';

/// Repository abstracto para Reservations (Domain Layer)
abstract class ReservationsRepository {
  /// Obtener mis reservaciones
  Future<Either<Failure, List<Reservation>>> getMyReservations({String? status});

  /// Crear nueva reservación
  Future<Either<Failure, Reservation>> createReservation({
    required int gymAreaId,
    required int timeSlotId,
    required DateTime reservationDate,
    String? notes,
  });

  /// Cancelar reservación
  Future<Either<Failure, void>> cancelReservation(int reservationId);
}