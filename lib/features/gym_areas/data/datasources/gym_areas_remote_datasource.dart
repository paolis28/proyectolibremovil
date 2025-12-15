import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/gym_area_model.dart';
import '../models/time_slot_model.dart';

/// DataSource remoto para áreas del gimnasio
abstract class GymAreasRemoteDataSource {
  Future<List<GymAreaModel>> getAllGymAreas();
  Future<GymAreaModel> getGymAreaById(int id);
  Future<List<TimeSlotModel>> getTimeSlotsByGymArea(int gymAreaId);
  Future<List<TimeSlotModel>> getAvailableTimeSlots(int gymAreaId, String date);
  Future<GymAreaModel> createGymArea({
    required String name,
    required String description,
    required int capacity,
    String? imageUrl,
  });
  Future<TimeSlotModel> createTimeSlot({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  });
}

class GymAreasRemoteDataSourceImpl implements GymAreasRemoteDataSource {
  final ApiClient apiClient;

  GymAreasRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TimeSlotModel> createTimeSlot({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await apiClient.post(
        '/time-slots',
        {
          'gym_area_id': gymAreaId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
        },
      );

      if (response['success'] == true) {
        return TimeSlotModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Error al crear horario');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<GymAreaModel> createGymArea({
    required String name,
    required String description,
    required int capacity,
    String? imageUrl,
  }) async {
    try {
      final response = await apiClient.post(
        '/gym-areas',
        {
          'name': name,
          'description': description,
          'capacity': capacity,
          'image_url': imageUrl,
        },
      );

      if (response['success'] == true) {
        return GymAreaModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Error al crear área');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<GymAreaModel>> getAllGymAreas() async {
    try {
      final response = await apiClient.get('/gym-areas');

      if (response['success'] == true) {
        final List<dynamic> areasJson = response['data'];
        return areasJson.map((json) => GymAreaModel.fromJson(json)).toList();
      } else {
        throw ServerException(response['message'] ?? 'Error al obtener áreas');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<GymAreaModel> getGymAreaById(int id) async {
    try {
      final response = await apiClient.get('/gym-areas/$id');

      if (response['success'] == true) {
        return GymAreaModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Error al obtener área');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlotsByGymArea(int gymAreaId) async {
    try {
      final response = await apiClient.get('/time-slots/gym-area/$gymAreaId');

      if (response['success'] == true) {
        final List<dynamic> slotsJson = response['data'];
        return slotsJson.map((json) => TimeSlotModel.fromJson(json)).toList();
      } else {
        throw ServerException(response['message'] ?? 'Error al obtener horarios');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
      int gymAreaId,
      String date,
      ) async {
    try {
      final response = await apiClient.get(
        '/time-slots/gym-area/$gymAreaId/available?date=$date',
      );

      if (response['success'] == true) {
        final List<dynamic> slotsJson = response['data'];
        return slotsJson.map((json) => TimeSlotModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response['message'] ?? 'Error al obtener horarios disponibles',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}