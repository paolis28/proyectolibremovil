import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/gym_area.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/usecases/get_gym_areas_usecase.dart';
import '../../domain/usecases/get_available_time_slots_usecase.dart';
import '../../domain/usecases/create_gym_area_usecase.dart';
import '../../domain/usecases/create_time_slot_usecase.dart';
import '../../../../core/services/cloudinary_service.dart';

/// Estados del provider
enum GymAreasStatus { initial, loading, success, error }
enum TimeSlotsStatus { initial, loading, success, error }
enum CreateStatus { initial, loading, success, error }
enum CreateTimeSlotStatus { initial, loading, success, error }

/// Provider para gestión de estado de áreas del gimnasio
class GymAreasProvider with ChangeNotifier {
  final GetGymAreasUseCase getGymAreasUseCase;
  final GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase;
  final CreateGymAreaUseCase createGymAreaUseCase;
  final CreateTimeSlotUseCase createTimeSlotUseCase;

  GymAreasProvider({
    required this.getGymAreasUseCase,
    required this.getAvailableTimeSlotsUseCase,
    required this.createGymAreaUseCase,
    required this.createTimeSlotUseCase,
  });

  // Estado de áreas
  List<GymArea> _gymAreas = [];
  GymAreasStatus _status = GymAreasStatus.initial;
  String? _errorMessage;

  // Estado de horarios
  List<TimeSlot> _timeSlots = [];
  TimeSlotsStatus _timeSlotsStatus = TimeSlotsStatus.initial;
  String? _timeSlotsErrorMessage;
  DateTime? _selectedDate;
  GymArea? _selectedGymArea;

  // Estado de creación de área
  CreateStatus _createStatus = CreateStatus.initial;
  String? _createErrorMessage;

  // Estado de creación de horario
  CreateTimeSlotStatus _createTimeSlotStatus = CreateTimeSlotStatus.initial;
  String? _createTimeSlotErrorMessage;

  // Getters
  List<GymArea> get gymAreas => _gymAreas;
  GymAreasStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<TimeSlot> get timeSlots => _timeSlots;
  TimeSlotsStatus get timeSlotsStatus => _timeSlotsStatus;
  String? get timeSlotsErrorMessage => _timeSlotsErrorMessage;
  DateTime? get selectedDate => _selectedDate;
  GymArea? get selectedGymArea => _selectedGymArea;

  CreateStatus get createStatus => _createStatus;
  String? get createErrorMessage => _createErrorMessage;

  CreateTimeSlotStatus get createTimeSlotStatus => _createTimeSlotStatus;
  String? get createTimeSlotErrorMessage => _createTimeSlotErrorMessage;

  bool get isLoading => _status == GymAreasStatus.loading;
  bool get isTimeSlotsLoading => _timeSlotsStatus == TimeSlotsStatus.loading;
  bool get isCreating => _createStatus == CreateStatus.loading;
  bool get isCreatingTimeSlot => _createTimeSlotStatus == CreateTimeSlotStatus.loading;

  /// Cargar todas las áreas del gimnasio
  Future<void> loadGymAreas() async {
    _status = GymAreasStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getGymAreasUseCase();

    result.fold(
          (failure) {
        _status = GymAreasStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (areas) {
        _gymAreas = areas;
        _status = GymAreasStatus.success;
        notifyListeners();
      },
    );
  }

  /// Crear nueva área del gimnasio
  Future<bool> createGymArea({
    required String name,
    required String description,
    required int capacity,
    File? imageFile,
  }) async {
    _createStatus = CreateStatus.loading;
    _createErrorMessage = null;
    notifyListeners();

    try {
      // Subir imagen a Cloudinary si existe
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await CloudinaryService.uploadImage(imageFile);
        if (imageUrl == null) {
          _createStatus = CreateStatus.error;
          _createErrorMessage = 'Error al subir la imagen';
          notifyListeners();
          return false;
        }
      }

      // Crear área
      final result = await createGymAreaUseCase(
        name: name,
        description: description,
        capacity: capacity,
        imageUrl: imageUrl,
      );

      return result.fold(
            (failure) {
          _createStatus = CreateStatus.error;
          _createErrorMessage = failure.message;
          notifyListeners();
          return false;
        },
            (area) {
          _createStatus = CreateStatus.success;
          // Agregar el área a la lista local
          _gymAreas.add(area);
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _createStatus = CreateStatus.error;
      _createErrorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  /// Crear nuevo horario (Time Slot)
  Future<bool> createTimeSlot({
    required int gymAreaId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    _createTimeSlotStatus = CreateTimeSlotStatus.loading;
    _createTimeSlotErrorMessage = null;
    notifyListeners();

    final result = await createTimeSlotUseCase(
      gymAreaId: gymAreaId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );

    return result.fold(
          (failure) {
        _createTimeSlotStatus = CreateTimeSlotStatus.error;
        _createTimeSlotErrorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (timeSlot) {
        _createTimeSlotStatus = CreateTimeSlotStatus.success;
        // Si estamos viendo los horarios del área, agregarlos a la lista
        if (_selectedGymArea?.id == gymAreaId) {
          _timeSlots.add(timeSlot);
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Seleccionar un área del gimnasio
  void selectGymArea(GymArea area) {
    _selectedGymArea = area;
    _timeSlots = [];
    _timeSlotsStatus = TimeSlotsStatus.initial;
    notifyListeners();
  }

  /// Seleccionar fecha para ver horarios disponibles
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();

    if (_selectedGymArea != null) {
      loadAvailableTimeSlots();
    }
  }

  /// Cargar horarios disponibles para la fecha y área seleccionadas
  Future<void> loadAvailableTimeSlots() async {
    if (_selectedGymArea == null || _selectedDate == null) {
      _timeSlotsErrorMessage = 'Selecciona un área y una fecha';
      return;
    }

    _timeSlotsStatus = TimeSlotsStatus.loading;
    _timeSlotsErrorMessage = null;
    notifyListeners();

    final result = await getAvailableTimeSlotsUseCase(
      gymAreaId: _selectedGymArea!.id,
      date: _selectedDate!,
    );

    result.fold(
          (failure) {
        _timeSlotsStatus = TimeSlotsStatus.error;
        _timeSlotsErrorMessage = failure.message;
        notifyListeners();
      },
          (slots) {
        _timeSlots = slots;
        _timeSlotsStatus = TimeSlotsStatus.success;
        notifyListeners();
      },
    );
  }

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearTimeSlotsError() {
    _timeSlotsErrorMessage = null;
    notifyListeners();
  }

  void clearCreateError() {
    _createErrorMessage = null;
    _createStatus = CreateStatus.initial;
    notifyListeners();
  }

  void clearCreateTimeSlotError() {
    _createTimeSlotErrorMessage = null;
    _createTimeSlotStatus = CreateTimeSlotStatus.initial;
    notifyListeners();
  }

  /// Reset
  void reset() {
    _gymAreas = [];
    _status = GymAreasStatus.initial;
    _errorMessage = null;
    _timeSlots = [];
    _timeSlotsStatus = TimeSlotsStatus.initial;
    _timeSlotsErrorMessage = null;
    _selectedDate = null;
    _selectedGymArea = null;
    _createStatus = CreateStatus.initial;
    _createErrorMessage = null;
    _createTimeSlotStatus = CreateTimeSlotStatus.initial;
    _createTimeSlotErrorMessage = null;
    notifyListeners();
  }
}