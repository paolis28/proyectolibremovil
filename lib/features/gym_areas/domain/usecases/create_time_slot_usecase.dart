import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/gym_areas_repository.dart';

/// Use Case para crear un horario (Time Slot)
class CreateTimeSlotUseCase {
  final GymAreasRepository repository;

  CreateTimeSlotUseCase(this.repository);

  Future<Either<Failure, TimeSlot>> call({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    // Validaciones
    if (dayOfWeek.trim().isEmpty) {
      return Left(ValidationFailure('El día de la semana es requerido'));
    }

    if (startTime.trim().isEmpty) {
      return Left(ValidationFailure('La hora de inicio es requerida'));
    }

    if (endTime.trim().isEmpty) {
      return Left(ValidationFailure('La hora de fin es requerida'));
    }

    // Validar formato de hora (HH:mm)
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(startTime)) {
      return Left(ValidationFailure('Formato de hora de inicio inválido (use HH:mm)'));
    }

    if (!timeRegex.hasMatch(endTime)) {
      return Left(ValidationFailure('Formato de hora de fin inválido (use HH:mm)'));
    }

    // Validar que la hora de inicio sea menor que la hora de fin
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (start >= end) {
      return Left(ValidationFailure('La hora de inicio debe ser menor que la hora de fin'));
    }

    return await repository.createTimeSlot(
      gymAreaId: gymAreaId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}