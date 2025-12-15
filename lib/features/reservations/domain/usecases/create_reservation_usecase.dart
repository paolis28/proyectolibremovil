import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

/// Use Case para crear una reservación
class CreateReservationUseCase {
  final ReservationsRepository repository;

  CreateReservationUseCase(this.repository);

  Future<Either<Failure, Reservation>> call({
    required int gymAreaId,
    required int timeSlotId,
    required DateTime reservationDate,
    String? notes,
  }) async {
    return await repository.createReservation(
      gymAreaId: gymAreaId,
      timeSlotId: timeSlotId,
      reservationDate: reservationDate,
      notes: notes,
    );
  }
}