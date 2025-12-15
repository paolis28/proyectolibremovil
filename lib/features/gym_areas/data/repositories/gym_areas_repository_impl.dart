import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/gym_area.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/gym_areas_repository.dart';
import '../datasources/gym_areas_remote_datasource.dart';

/// Implementación del repositorio de áreas del gimnasio
class GymAreasRepositoryImpl implements GymAreasRepository {
  final GymAreasRemoteDataSource remoteDataSource;

  GymAreasRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TimeSlot>> createTimeSlot({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final timeSlot = await remoteDataSource.createTimeSlot(
        gymAreaId: gymAreaId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(timeSlot);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, GymArea>> createGymArea({
    required String name,
    required String description,
    required int capacity,
    String? imageUrl,
  }) async {
    try {
      final area = await remoteDataSource.createGymArea(
        name: name,
        description: description,
        capacity: capacity,
        imageUrl: imageUrl,
      );
      return Right(area);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GymArea>>> getAllGymAreas() async {
    try {
      final areas = await remoteDataSource.getAllGymAreas();
      return Right(areas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, GymArea>> getGymAreaById(int id) async {
    try {
      final area = await remoteDataSource.getGymAreaById(id);
      return Right(area);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getTimeSlotsByGymArea(
      int gymAreaId,
      ) async {
    try {
      final slots = await remoteDataSource.getTimeSlotsByGymArea(gymAreaId);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required int gymAreaId,
    required DateTime date,
  }) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final slots = await remoteDataSource.getAvailableTimeSlots(
        gymAreaId,
        dateString,
      );
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}