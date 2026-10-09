import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusProvider>().fetchRoutes();
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
            title: 'Bus Routes Management',
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_road_rounded, size: 18),
              label: Text('Add Route', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              onPressed: () => _showRouteFormDialog(context),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
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
                          child: TextField(
                            controller: _searchCtrl,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search routes by source, destination or route code...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        busProvider.fetchRoutes(search: '');
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
                              busProvider.fetchRoutes(search: val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Reload routes',
                          onPressed: () => busProvider.fetchRoutes(search: _searchCtrl.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Routes Table
                  DataTableCard(
                    title: 'Connecting Corridors (${busProvider.routes.length})',
                    isLoading: busProvider.isLoading,
                    columns: const [
                      DataColumn(label: Text('ROUTE CODE')),
                      DataColumn(label: Text('ORIGIN & DESTINATION')),
                      DataColumn(label: Text('DISTANCE')),
                      DataColumn(label: Text('ESTIMATED DURATION')),
                      DataColumn(label: Text('POPULARITY')),
                      DataColumn(label: Text('SCHEDULED TRIPS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: busProvider.routes.map((route) {
                      final hours = route.estimatedDurationMins ~/ 60;
                      final mins = route.estimatedDurationMins % 60;
                      final durationStr = hours > 0 ? '${hours}h ${mins > 0 ? "${mins}m" : ""}' : '${mins}m';

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
                                route.routeCode,
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
                                Text(
                                  route.sourceCity,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 14),
                                ),
                                Text(
                                  route.destinationCity,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '${route.distanceKm.toStringAsFixed(0)} km',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  durationStr,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            route.isPopular
                                ? StatusBadge(status: 'HOT ROUTE', type: StatusBadgeType.warning)
                                : StatusBadge(status: 'REGULAR', type: StatusBadgeType.neutral),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${route.tripCount} Trips',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                                  tooltip: 'Edit Route',
                                  onPressed: () => _showRouteFormDialog(context, route: route),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                                  tooltip: 'Delete Route',
                                  onPressed: () => _confirmDeleteRoute(context, route),
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

  void _showRouteFormDialog(BuildContext context, {BusRouteModel? route}) {
    final formKey = GlobalKey<FormState>();
    final isEdit = route != null;
    final sourceCtrl = TextEditingController(text: route?.sourceCity ?? '');
    final destCtrl = TextEditingController(text: route?.destinationCity ?? '');
    final distCtrl = TextEditingController(text: route != null ? '${route.distanceKm}' : '350');
    final durCtrl = TextEditingController(text: route != null ? '${route.estimatedDurationMins}' : '360');
    bool isPopular = route?.isPopular ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.border),
              ),
              title: Row(
                children: [
                  const Icon(Icons.add_road_rounded, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(isEdit ? 'Edit Bus Corridor Route' : 'Create Bus Corridor Route', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: sourceCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Source City *',
                                  hintText: 'e.g. Bangalore',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: destCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Destination City *',
                                  hintText: 'e.g. Hyderabad',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: distCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Distance (km) *',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid km' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: durCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Duration (minutes) *',
                                  hintText: 'e.g. 360 (6 hours)',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid mins' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          title: Text('Mark as High-Demand Popular Route', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                          value: isPopular,
                          activeColor: AppTheme.accentGold,
                          onChanged: (v) => setModalState(() => isPopular = v),
                          contentPadding: EdgeInsets.zero,
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
                  child: Text('Save Route', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.pop(ctx);

                    final data = {
                      'sourceCity': sourceCtrl.text.trim(),
                      'destinationCity': destCtrl.text.trim(),
                      'distanceKm': double.tryParse(distCtrl.text.trim()) ?? 350.0,
                      'estimatedDurationMins': int.tryParse(durCtrl.text.trim()) ?? 360,
                      'isPopular': isPopular,
                    };

                    final provider = context.read<BusProvider>();
                    final success = isEdit ? await provider.updateRoute(route.id, data) : await provider.createRoute(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                          content: Text(success ? (isEdit ? 'Route updated successfully!' : 'Route registered successfully!') : (isEdit ? 'Failed to update route.' : 'Failed to register route.')),
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

  void _confirmDeleteRoute(BuildContext context, BusRouteModel route) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Route ${route.sourceCity} → ${route.destinationCity}?',
      message: 'Are you sure you want to remove this corridor route? Active trips on this route will be marked cancelled.',
      confirmLabel: 'Delete Route',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<BusProvider>().deleteRoute(route.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? AppTheme.success : AppTheme.error,
            content: Text(success ? 'Route deleted.' : 'Failed to delete route.'),
          ),
        );
      }
    }
  }
}
