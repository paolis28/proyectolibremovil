import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/gym_area.dart';
import '../entities/time_slot.dart';

/// Repository abstracto para Gym Areas (Domain Layer)
abstract class GymAreasRepository {
  /// Obtener todas las áreas del gimnasio
  Future<Either<Failure, List<GymArea>>> getAllGymAreas();

  /// Obtener área por ID
  Future<Either<Failure, GymArea>> getGymAreaById(int id);

  /// Obtener horarios de un área
  Future<Either<Failure, List<TimeSlot>>> getTimeSlotsByGymArea(int gymAreaId);

  /// Obtener horarios disponibles para una fecha
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required int gymAreaId,
    required DateTime date,
  });

  /// Crear área del gimnasio
  Future<Either<Failure, GymArea>> createGymArea({
    required String name,
    required String description,
    required int capacity,
    String? imageUrl,
  });

  /// Crear horario (Time Slot)
  Future<Either<Failure, TimeSlot>> createTimeSlot({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  });
}