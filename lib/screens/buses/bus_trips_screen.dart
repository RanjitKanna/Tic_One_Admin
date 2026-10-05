import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class BusTripsScreen extends StatefulWidget {
  const BusTripsScreen({super.key});

  @override
  State<BusTripsScreen> createState() => _BusTripsScreenState();
}

class _BusTripsScreenState extends State<BusTripsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int? _selectedRouteId;
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final busProvider = context.read<BusProvider>();
      busProvider.fetchRoutes();
      busProvider.fetchBuses();
      busProvider.fetchTrips();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = context.watch<BusProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          AdminHeader(
            title: 'Bus Trips & Scheduling',
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: Text('Schedule Trip', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              onPressed: () => _showTripScheduleDialog(context, busProvider: busProvider),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchCtrl,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search trips by operator, bus name or trip code...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        busProvider.fetchTrips(search: '', routeId: _selectedRouteId, date: _selectedDate);
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              filled: true,
                              fillColor: AppTheme.bgCard,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            ),
                            onSubmitted: (val) {
                              busProvider.fetchTrips(search: val, routeId: _selectedRouteId, date: _selectedDate);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int?>(
                            value: _selectedRouteId,
                            dropdownColor: AppTheme.bgCard,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: AppTheme.bgCard,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            ),
                            hint: Text('All Routes', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13)),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('All Routes')),
                              ...busProvider.routes.map((r) => DropdownMenuItem<int?>(
                                    value: r.id,
                                    child: Text('${r.sourceCity} → ${r.destinationCity}', overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedRouteId = val);
                              busProvider.fetchTrips(search: _searchCtrl.text, routeId: val, date: _selectedDate);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Reload trips',
                          onPressed: () => busProvider.fetchTrips(search: _searchCtrl.text, routeId: _selectedRouteId, date: _selectedDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trips Table
                  DataTableCard(
                    title: 'Active Trip Schedules (${busProvider.trips.length})',
                    isLoading: busProvider.isLoading,
                    columns: const [
                      DataColumn(label: Text('TRIP CODE')),
                      DataColumn(label: Text('ROUTE CORRIDOR')),
                      DataColumn(label: Text('BUS & OPERATOR')),
                      DataColumn(label: Text('DEPARTURE / ARRIVAL')),
                      DataColumn(label: Text('TRAVEL DATE')),
                      DataColumn(label: Text('FARE')),
                      DataColumn(label: Text('BOOKED / TOTAL')),
                      DataColumn(label: Text('POINTS & ACTIONS')),
                    ],
                    rows: busProvider.trips.map((trip) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.bgDark,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                trip.tripCode,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.accentTeal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Text(trip.sourceCity, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 14),
                                ),
                                Text(trip.destinationCity, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(trip.busName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                Text('${trip.operatorName} • ${trip.busType}', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.flight_takeoff_rounded, size: 13, color: AppTheme.success),
                                    const SizedBox(width: 4),
                                    Text(trip.departureTimeFormatted.isNotEmpty ? trip.departureTimeFormatted : DateFormat('hh:mm a').format(trip.departureTime), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.flight_land_rounded, size: 13, color: AppTheme.accentPurple),
                                    const SizedBox(width: 4),
                                    Text(trip.arrivalTimeFormatted.isNotEmpty ? trip.arrivalTimeFormatted : DateFormat('hh:mm a').format(trip.arrivalTime), style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              trip.travelDate,
                              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${trip.baseFare.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (trip.bookingCount >= trip.totalSeats ? AppTheme.error : AppTheme.primary).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${trip.bookingCount} / ${trip.totalSeats}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: trip.bookingCount >= trip.totalSeats ? AppTheme.error : AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.accentTeal),
                                  tooltip: 'Boarding/Dropping Points',
                                  onPressed: () => _showPointsDialog(context, trip),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                                  tooltip: 'Cancel & Delete Trip',
                                  onPressed: () => _confirmDeleteTrip(context, trip),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointsDialog(BuildContext context, BusTripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          title: Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text('Points for Trip ${trip.tripCode}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Boarding Points (${trip.boardingPoints.length})', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentTeal, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (trip.boardingPoints.isEmpty)
                    Text('Default origin terminal pickup.', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12))
                  else
                    ...trip.boardingPoints.map((bp) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.place, color: AppTheme.accentTeal, size: 18),
                          title: Text(bp.pointName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text('${bp.landmark ?? ""} (${bp.timeFormatted})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        )),
                  const Divider(color: AppTheme.border, height: 24),
                  Text('Dropping Points (${trip.droppingPoints.length})', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentPurple, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (trip.droppingPoints.isEmpty)
                    Text('Default destination central drop.', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12))
                  else
                    ...trip.droppingPoints.map((dp) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.flag_rounded, color: AppTheme.accentPurple, size: 18),
                          title: Text(dp.pointName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text('${dp.landmark ?? ""} (${dp.timeFormatted})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        );
      },
    );
  }

  void _showTripScheduleDialog(BuildContext context, {required BusProvider busProvider}) {
    if (busProvider.routes.isEmpty || busProvider.buses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure both Routes and Buses exist before scheduling a trip.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int routeId = busProvider.routes.first.id;
    int busId = busProvider.buses.first.id;
    DateTime travelDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay depTime = const TimeOfDay(hour: 21, minute: 30);
    TimeOfDay arrTime = const TimeOfDay(hour: 6, minute: 0);
    final fareCtrl = TextEditingController(text: '850');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
              title: Row(
                children: [
                  const Icon(Icons.add_task_rounded, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text('Schedule Bus Trip', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Route Selector
                        DropdownButtonFormField<int>(
                          value: routeId,
                          dropdownColor: AppTheme.bgDark,
                          decoration: InputDecoration(
                            labelText: 'Corridor Route *',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: busProvider.routes.map((r) {
                            return DropdownMenuItem<int>(
                              value: r.id,
                              child: Text('${r.sourceCity} → ${r.destinationCity} (${r.distanceKm.toStringAsFixed(0)}km)', style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => routeId = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Bus Selector
                        DropdownButtonFormField<int>(
                          value: busId,
                          dropdownColor: AppTheme.bgDark,
                          decoration: InputDecoration(
                            labelText: 'Assigned Bus *',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: busProvider.buses.map((b) {
                            return DropdownMenuItem<int>(
                              value: b.id,
                              child: Text('${b.busName} (${b.busNumber}) - ${b.operatorName}', style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => busId = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Travel Date Picker
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: travelDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setModalState(() => travelDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Travel Date *',
                              labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.bgDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primary, size: 18),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd (EEEE)').format(travelDate),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Departure and Arrival Time
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(context: context, initialTime: depTime);
                                  if (t != null) setModalState(() => depTime = t);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Departure *',
                                    labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                    filled: true,
                                    fillColor: AppTheme.bgDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    suffixIcon: const Icon(Icons.access_time, color: AppTheme.accentTeal, size: 18),
                                  ),
                                  child: Text(depTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(context: context, initialTime: arrTime);
                                  if (t != null) setModalState(() => arrTime = t);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Arrival *',
                                    labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                    filled: true,
                                    fillColor: AppTheme.bgDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    suffixIcon: const Icon(Icons.access_time, color: AppTheme.accentPurple, size: 18),
                                  ),
                                  child: Text(arrTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Base Fare
                        TextFormField(
                          controller: fareCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Base Seat Fare (₹) *',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid fare' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Publish Trip', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.pop(ctx);

                    final dateStr = DateFormat('yyyy-MM-dd').format(travelDate);
                    final depDateTime = DateTime(travelDate.year, travelDate.month, travelDate.day, depTime.hour, depTime.minute);
                    var arrDateTime = DateTime(travelDate.year, travelDate.month, travelDate.day, arrTime.hour, arrTime.minute);
                    if (arrDateTime.isBefore(depDateTime)) {
                      arrDateTime = arrDateTime.add(const Duration(days: 1));
                    }

                    final data = {
                      'routeId': routeId,
                      'busId': busId,
                      'travelDate': dateStr,
                      'departureTime': depDateTime.toIso8601String(),
                      'arrivalTime': arrDateTime.toIso8601String(),
                      'baseFare': double.tryParse(fareCtrl.text.trim()) ?? 850.0,
                    };

                    final success = await context.read<BusProvider>().createTrip(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                          content: Text(success ? 'Trip scheduled successfully!' : 'Failed to schedule trip.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTrip(BuildContext context, BusTripModel trip) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Trip ${trip.tripCode}?',
      message: 'Are you sure you want to cancel and delete this trip (${trip.sourceCity} → ${trip.destinationCity} on ${trip.travelDate})?',
      confirmLabel: 'Cancel Trip',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<BusProvider>().deleteTrip(trip.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? AppTheme.success : AppTheme.error,
            content: Text(success ? 'Trip cancelled.' : 'Failed to delete trip.'),
          ),
        );
      }
    }
  }
}
