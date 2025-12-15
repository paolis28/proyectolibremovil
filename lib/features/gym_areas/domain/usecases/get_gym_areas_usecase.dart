import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/gym_area.dart';
import '../repositories/gym_areas_repository.dart';

/// Use Case para obtener todas las áreas del gimnasio
class GetGymAreasUseCase {
  final GymAreasRepository repository;

  GetGymAreasUseCase(this.repository);

  Future<Either<Failure, List<GymArea>>> call() async {
    return await repository.getAllGymAreas();
  }
}