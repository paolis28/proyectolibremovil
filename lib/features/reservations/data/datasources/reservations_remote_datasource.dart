import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/reservation_model.dart';

/// DataSource remoto para reservaciones
abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations({String? status});
  Future<ReservationModel> createReservation({
    required int gymAreaId,
    required int timeSlotId,
    required String reservationDate,
    String? notes,
  });
  Future<void> cancelReservation(int reservationId);
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final ApiClient apiClient;

  ReservationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReservationModel>> getMyReservations({String? status}) async {
    try {
      String endpoint = '/reservations/my-reservations';
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await apiClient.get(endpoint);

      if (response['success'] == true) {
        final List<dynamic> reservationsJson = response['data'];
        return reservationsJson
            .map((json) => ReservationModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          response['message'] ?? 'Error al obtener reservaciones',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ReservationModel> createReservation({
    required int gymAreaId,
    required int timeSlotId,
    required String reservationDate,
    String? notes,
  }) async {
    try {
      final response = await apiClient.post('/reservations', {
        'gym_area_id': gymAreaId,
        'time_slot_id': timeSlotId,
        'reservation_date': reservationDate,
        'notes': notes,
      });

      if (response['success'] == true) {
        return ReservationModel.fromJson(response['data']);
      } else {
        throw ServerException(
          response['message'] ?? 'Error al crear reservación',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> cancelReservation(int reservationId) async {
    try {
      final response = await apiClient.put(
        '/reservations/$reservationId/cancel',
        {},
      );

      if (response['success'] != true) {
        throw ServerException(
          response['message'] ?? 'Error al cancelar reservación',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}