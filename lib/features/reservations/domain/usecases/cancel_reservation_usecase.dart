import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/reservations_repository.dart';

/// Use Case para cancelar una reservación
class CancelReservationUseCase {
  final ReservationsRepository repository;

  CancelReservationUseCase(this.repository);

  Future<Either<Failure, void>> call(int reservationId) async {
    return await repository.cancelReservation(reservationId);
  }
}