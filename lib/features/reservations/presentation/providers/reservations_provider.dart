import 'package:flutter/material.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/usecases/get_my_reservations_usecase.dart';
import '../../domain/usecases/create_reservation_usecase.dart';
import '../../domain/usecases/cancel_reservation_usecase.dart';

/// Estados del provider
enum ReservationsStatus { initial, loading, success, error }

enum CreateReservationStatus { initial, loading, success, error }

/// Provider para gestión de estado de reservaciones
class ReservationsProvider with ChangeNotifier {
  final GetMyReservationsUseCase getMyReservationsUseCase;
  final CreateReservationUseCase createReservationUseCase;
  final CancelReservationUseCase cancelReservationUseCase;

  ReservationsProvider({
    required this.getMyReservationsUseCase,
    required this.createReservationUseCase,
    required this.cancelReservationUseCase,
  });

  // Estado de lista de reservaciones
  List<Reservation> _reservations = [];
  ReservationsStatus _status = ReservationsStatus.initial;
  String? _errorMessage;
  String? _statusFilter;

  // Estado de creación de reservación
  CreateReservationStatus _createStatus = CreateReservationStatus.initial;
  String? _createErrorMessage;

  // Getters
  List<Reservation> get reservations => _reservations;
  ReservationsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;

  CreateReservationStatus get createStatus => _createStatus;
  String? get createErrorMessage => _createErrorMessage;

  bool get isLoading => _status == ReservationsStatus.loading;
  bool get isCreating => _createStatus == CreateReservationStatus.loading;

  // Reservaciones por estado
  List<Reservation> get upcomingReservations => _reservations
      .where((r) => r.status == 'confirmed' || r.status == 'pending')
      .toList();

  List<Reservation> get pastReservations => _reservations
      .where((r) => r.status == 'completed' || r.status == 'cancelled')
      .toList();

  /// Cargar mis reservaciones
  Future<void> loadMyReservations({String? status}) async {
    _status = ReservationsStatus.loading;
    _errorMessage = null;
    _statusFilter = status;
    notifyListeners();

    final result = await getMyReservationsUseCase(status: status);

    result.fold(
          (failure) {
        _status = ReservationsStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (reservations) {
        _reservations = reservations;
        _status = ReservationsStatus.success;
        notifyListeners();
      },
    );
  }

  /// Crear nueva reservación
  Future<bool> createReservation({
    required int gymAreaId,
    required int timeSlotId,
    required DateTime reservationDate,
    String? notes,
  }) async {
    _createStatus = CreateReservationStatus.loading;
    _createErrorMessage = null;
    notifyListeners();

    final result = await createReservationUseCase(
      gymAreaId: gymAreaId,
      timeSlotId: timeSlotId,
      reservationDate: reservationDate,
      notes: notes,
    );

    return result.fold(
          (failure) {
        _createStatus = CreateReservationStatus.error;
        _createErrorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (reservation) {
        _createStatus = CreateReservationStatus.success;
        // Agregar la nueva reservación a la lista
        _reservations.insert(0, reservation);
        notifyListeners();
        return true;
      },
    );
  }

  /// Cancelar reservación
  Future<bool> cancelReservation(int reservationId) async {
    final result = await cancelReservationUseCase(reservationId);

    return result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (_) {
        // Actualizar el estado local de la reservación
        final index = _reservations.indexWhere((r) => r.id == reservationId);
        if (index != -1) {
          // Crear una nueva reservación con estado cancelado
          final cancelledReservation = Reservation(
            id: _reservations[index].id,
            userId: _reservations[index].userId,
            gymAreaId: _reservations[index].gymAreaId,
            timeSlotId: _reservations[index].timeSlotId,
            reservationDate: _reservations[index].reservationDate,
            status: 'cancelled',
            notes: _reservations[index].notes,
            gymAreaName: _reservations[index].gymAreaName,
            gymAreaImage: _reservations[index].gymAreaImage,
            startTime: _reservations[index].startTime,
            endTime: _reservations[index].endTime,
            dayOfWeek: _reservations[index].dayOfWeek,
          );

          _reservations[index] = cancelledReservation;
          notifyListeners();
        }
        return true;
      },
    );
  }

  /// Filtrar reservaciones por estado
  void filterByStatus(String? status) {
    loadMyReservations(status: status);
  }

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCreateError() {
    _createErrorMessage = null;
    notifyListeners();
  }

  /// Reset
  void reset() {
    _reservations = [];
    _status = ReservationsStatus.initial;
    _errorMessage = null;
    _statusFilter = null;
    _createStatus = CreateReservationStatus.initial;
    _createErrorMessage = null;
    notifyListeners();
  }

  /// Refrescar reservaciones
  Future<void> refresh() async {
    await loadMyReservations(status: _statusFilter);
  }
}