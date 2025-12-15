import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectolibre/features/gym_areas/domain/usecases/create_gym_area_usecase.dart';
import 'package:proyectolibre/features/gym_areas/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'core/network/api_client.dart';
import 'core/utils/constants.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

// Gym Areas
import 'features/gym_areas/data/datasources/gym_areas_remote_datasource.dart';
import 'features/gym_areas/data/repositories/gym_areas_repository_impl.dart';
import 'features/gym_areas/domain/usecases/create_time_slot_usecase.dart';
import 'features/gym_areas/domain/usecases/get_gym_areas_usecase.dart';
import 'features/gym_areas/domain/usecases/get_available_time_slots_usecase.dart';
import 'features/gym_areas/presentation/providers/gym_areas_provider.dart';
import 'features/gym_areas/presentation/pages/gym_areas_page.dart';
import 'features/gym_areas/presentation/pages/gym_area_detail_page.dart';

// Reservations
import 'features/reservations/data/datasources/reservations_remote_datasource.dart';
import 'features/reservations/data/repositories/reservations_repository_impl.dart';
import 'features/reservations/domain/usecases/get_my_reservations_usecase.dart';
import 'features/reservations/domain/usecases/create_reservation_usecase.dart';
import 'features/reservations/domain/usecases/cancel_reservation_usecase.dart';
import 'features/reservations/presentation/providers/reservations_provider.dart';
import 'features/reservations/presentation/pages/reservations_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locales para fechas en español
  await initializeDateFormatting('es', null);

  // Inicializar dependencias
  final sharedPreferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient(
    client: http.Client(),
    baseUrl: AppConstants.apiBaseUrl,
  );

  // Configurar token si existe
  final token = sharedPreferences.getString(AppConstants.tokenKey);
  if (token != null) {
    apiClient.setToken(token);
  }

  runApp(MyApp(
    sharedPreferences: sharedPreferences,
    apiClient: apiClient,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
    required this.apiClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ============================================
    // AUTH - Repositorios y Use Cases
    // ============================================
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: apiClient,
      sharedPreferences: sharedPreferences,
    );

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      sharedPreferences: sharedPreferences,
    );

    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);

    // ============================================
    // GYM AREAS - Repositorios y Use Cases
    // ============================================
    final gymAreasRemoteDataSource = GymAreasRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    final gymAreasRepository = GymAreasRepositoryImpl(
      remoteDataSource: gymAreasRemoteDataSource,
    );

    final getGymAreasUseCase = GetGymAreasUseCase(gymAreasRepository);
    final getAvailableTimeSlotsUseCase = GetAvailableTimeSlotsUseCase(gymAreasRepository);
    final createGymAreaUseCase=CreateGymAreaUseCase(gymAreasRepository);
    final createTimeSlotUseCase=CreateTimeSlotUseCase(gymAreasRepository);

    // ============================================
    // RESERVATIONS - Repositorios y Use Cases
    // ============================================
    final reservationsRemoteDataSource = ReservationsRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    final reservationsRepository = ReservationsRepositoryImpl(
      remoteDataSource: reservationsRemoteDataSource,
    );

    final getMyReservationsUseCase = GetMyReservationsUseCase(reservationsRepository);
    final createReservationUseCase = CreateReservationUseCase(reservationsRepository);
    final cancelReservationUseCase = CancelReservationUseCase(reservationsRepository);

    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
          ),
        ),

        // Gym Areas Provider
        ChangeNotifierProvider(
          create: (_) => GymAreasProvider(
            getGymAreasUseCase: getGymAreasUseCase,
            getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
            createGymAreaUseCase: createGymAreaUseCase,
            createTimeSlotUseCase: createTimeSlotUseCase,
          ),
        ),

        // Reservations Provider
        ChangeNotifierProvider(
          create: (_) => ReservationsProvider(
            getMyReservationsUseCase: getMyReservationsUseCase,
            createReservationUseCase: createReservationUseCase,
            cancelReservationUseCase: cancelReservationUseCase,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Gym Reservation',
        debugShowCheckedModeBanner: false,

        // Configuración de localización
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''), // Español
          Locale('en', ''), // Inglés
        ],
        locale: const Locale('es', ''),

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}

// Configuración de GoRouter
final router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // AUTH
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),

    // HOME
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    // GYM AREAS LIST
    GoRoute(
      path: AppRoutes.gymAreas,
      builder: (context, state) => const GymAreasPage(),
    ),

    // GYM AREA DETAIL (RECIBE EXTRA)
    GoRoute(
      path: '${AppRoutes.gymAreas}/:areaId',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;

        final gymArea = data?['gymArea'];
        final isAdmin = data?['isAdmin'] ?? false;

        if (gymArea == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: No se recibió la información del área.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        }

        return GymAreaDetailPage(
          gymArea: gymArea,
          isAdmin: isAdmin,
        );
      },
    ),

    // RESERVATIONS
    GoRoute(
      path: AppRoutes.reservations,
      builder: (context, state) => const ReservationsPage(),
    ),
  ],
);