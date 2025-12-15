import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_datasource.dart';

/// Implementación del repositorio de reservaciones
class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Reservation>>> getMyReservations({
    String? status,
  }) async {
    try {
      final reservations = await remoteDataSource.getMyReservations(
        status: status,
      );
      return Right(reservations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation({
    required int gymAreaId,
    required int timeSlotId,
    required DateTime reservationDate,
    String? notes,
  }) async {
    try {
      final dateString = reservationDate.toIso8601String().split('T')[0];

      final reservation = await remoteDataSource.createReservation(
        gymAreaId: gymAreaId,
        timeSlotId: timeSlotId,
        reservationDate: dateString,
        notes: notes,
      );

      return Right(reservation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(int reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}