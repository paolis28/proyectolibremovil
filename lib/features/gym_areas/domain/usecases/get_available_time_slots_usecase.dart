import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/gym_areas_repository.dart';

/// Use Case para obtener horarios disponibles
class GetAvailableTimeSlotsUseCase {
  final GymAreasRepository repository;

  GetAvailableTimeSlotsUseCase(this.repository);

  Future<Either<Failure, List<TimeSlot>>> call({
    required int gymAreaId,
    required DateTime date,
  }) async {
    return await repository.getAvailableTimeSlots(
      gymAreaId: gymAreaId,
      date: date,
    );
  }
}