import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../gym_areas/presentation/pages/gym_area_detail_page.dart';
import '../../../gym_areas/presentation/widgets/gym_areas_widgets.dart';
import '../providers/reservations_provider.dart';
import '../widgets/reservations_widgets.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Cargar reservaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationsProvider>().loadMyReservations();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentFilter = null;
            break;
          case 1:
            _currentFilter = 'confirmed';
            break;
          case 2:
            _currentFilter = 'cancelled';
            break;
        }
      });
      context.read<ReservationsProvider>().filterByStatus(_currentFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReservationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
            tooltip: 'Actualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Activas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationsList(provider, theme, null),
          _buildReservationsList(provider, theme, 'confirmed'),
          _buildReservationsList(provider, theme, 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildReservationsList(
      ReservationsProvider provider,
      ThemeData theme,
      String? filter,
      ) {

    // Estado de error
    if (provider.status == ReservationsStatus.error) {
      return ModernEmptyState(
        icon: Icons.error_outline,
        title: 'Ocurrió un error',
        subtitle: 'Por favor intenta de nuevo.',
      );
    }

    // Filtrar reservaciones según el filtro
    List<dynamic> filteredReservations;
    if (filter == null) {
      filteredReservations = provider.reservations;
    } else if (filter == 'confirmed') {
      filteredReservations = provider.upcomingReservations;
    } else {
      filteredReservations = provider.pastReservations
          .where((r) => r.status == 'cancelled')
          .toList();
    }

    // Estado vacío
    if (filteredReservations.isEmpty) {
      String message;
      if (filter == 'confirmed') {
        message = 'No tienes reservaciones activas';
      } else if (filter == 'cancelled') {
        message = 'No tienes reservaciones canceladas';
      } else {
        message = 'No tienes reservaciones aún';
      }

      return EmptyReservationsWidget(
        message: message,
        actionLabel: filter == null ? 'Explorar Áreas' : null,
        onAction: filter == null
            ? () {
          // Navegar a la página de áreas (implementar según tu routing)
          Navigator.pop(context);
        }
            : null,
      );
    }

    // Lista de reservaciones
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredReservations.length,
        itemBuilder: (context, index) {
          final reservation = filteredReservations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReservationCard(
              reservation: reservation,
              onTap: () => _showReservationDetails(context, reservation),
              onCancel: reservation.status == 'confirmed' ||
                  reservation.status == 'pending'
                  ? () => _showCancelDialog(context, reservation.id)
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showReservationDetails(BuildContext context, reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Detalles de la Reservación',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    context,
                    Icons.fitness_center,
                    'Área',
                    reservation.gymAreaName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Fecha',
                    '${reservation.reservationDate.day}/${reservation.reservationDate.month}/${reservation.reservationDate.year}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.access_time,
                    'Horario',
                    '${reservation.startTime} - ${reservation.endTime}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.info_outline,
                    'Estado',
                    _getStatusLabel(reservation.status),
                  ),
                  if (reservation.notes != null &&
                      reservation.notes!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(
                      'Notas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(reservation.notes!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }

  Future<void> _showCancelDialog(BuildContext context, int reservationId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CancelReservationDialog(),
    );

    if (result == true && mounted) {
      final provider = context.read<ReservationsProvider>();

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await provider.cancelReservation(reservationId);

      // Cerrar loading
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservación cancelada exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Recargar reservaciones
          provider.refresh();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cancelar la reservación'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}