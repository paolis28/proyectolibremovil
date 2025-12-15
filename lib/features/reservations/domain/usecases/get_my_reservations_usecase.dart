import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

/// Use Case para obtener mis reservaciones
class GetMyReservationsUseCase {
  final ReservationsRepository repository;

  GetMyReservationsUseCase(this.repository);

  Future<Either<Failure, List<Reservation>>> call({String? status}) async {
    return await repository.getMyReservations(status: status);
  }
}