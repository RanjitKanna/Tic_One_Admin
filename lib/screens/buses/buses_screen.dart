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
import '../../widgets/visual_bus_seat_matrix.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int? _selectedOperatorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final busProvider = context.read<BusProvider>();
      busProvider.fetchOperators();
      busProvider.fetchBuses();
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
            title: 'Buses Fleet Management',
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Bus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              onPressed: () => _showBusFormDialog(context, operators: busProvider.operators),
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
                              hintText: 'Search by bus name, registration number, or type...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        busProvider.fetchBuses(search: '', operatorId: _selectedOperatorId);
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
                              busProvider.fetchBuses(search: val, operatorId: _selectedOperatorId);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int?>(
                            value: _selectedOperatorId,
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
                            hint: Text('All Operators', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13)),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Operators'),
                              ),
                              ...busProvider.operators.map((op) => DropdownMenuItem<int?>(
                                    value: op.id,
                                    child: Text(op.name, overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedOperatorId = val);
                              busProvider.fetchBuses(search: _searchCtrl.text, operatorId: val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Reload fleet',
                          onPressed: () => busProvider.fetchBuses(search: _searchCtrl.text, operatorId: _selectedOperatorId),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buses Table
                  DataTableCard(
                    title: 'Fleet Inventory (${busProvider.buses.length})',
                    isLoading: busProvider.isLoading,
                    columns: const [
                      DataColumn(label: Text('BUS / CODE')),
                      DataColumn(label: Text('OPERATOR')),
                      DataColumn(label: Text('REG NUMBER')),
                      DataColumn(label: Text('TYPE & CATEGORY')),
                      DataColumn(label: Text('DECK')),
                      DataColumn(label: Text('CAPACITY')),
                      DataColumn(label: Text('AMENITIES')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: busProvider.buses.map((bus) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_bus_rounded, color: AppTheme.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      bus.busName,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      bus.busCode,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              bus.operatorName,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.accentTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                bus.busNumber,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  bus.busType,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      bus.category,
                                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                    const SizedBox(width: 6),
                                    if (bus.isAc)
                                      StatusBadge(status: 'AC', type: StatusBadgeType.success)
                                    else
                                      StatusBadge(status: 'NON-AC', type: StatusBadgeType.neutral),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              bus.deckType.toUpperCase(),
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
                                const Icon(Icons.airline_seat_recline_extra_rounded, size: 16, color: AppTheme.accentPurple),
                                const SizedBox(width: 6),
                                Text(
                                  '${bus.totalSeats} Seats',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Wrap(
                              spacing: 4,
                              children: (bus.amenities).take(2).map((a) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgDark,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Text(
                                    a.toString(),
                                    style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 10),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.grid_view_rounded, size: 18, color: AppTheme.accentTeal),
                                  tooltip: 'View Cabin Layout',
                                  onPressed: () => _showBusSeatLayoutDialog(context, bus),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                                  tooltip: 'Edit Bus',
                                  onPressed: () => _showBusFormDialog(context, operators: context.read<BusProvider>().operators, bus: bus),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                                  tooltip: 'Delete Bus',
                                  onPressed: () => _confirmDeleteBus(context, bus),
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

  void _showBusFormDialog(BuildContext context, {required List<BusOperatorModel> operators, BusModel? bus}) {
    if (operators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one Bus Operator first!')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final isEdit = bus != null;
    final nameCtrl = TextEditingController(text: bus?.busName ?? '');
    final numberCtrl = TextEditingController(text: bus?.busNumber ?? '');
    int operatorId = operators.any((o) => o.id == bus?.operatorId) ? bus!.operatorId : operators.first.id;
    String busType = bus?.busType.isNotEmpty == true ? bus!.busType : 'AC Sleeper 2+1';
    String category = bus?.category.isNotEmpty == true ? bus!.category : 'Premium';
    String deckType = bus?.deckType.isNotEmpty == true ? bus!.deckType : 'single';
    bool isAc = bus?.isAc ?? true;
    bool liveTracking = bus?.liveTrackingAvailable ?? true;
    int totalSeats = bus?.totalSeats ?? 30;
    final List<String> selectedAmenities = bus != null
        ? bus.amenities.map((a) => a.toString()).toList()
        : ['WiFi', 'Charging Point', 'Water Bottle', 'Blanket'];

    final availableAmenities = {
      'WiFi', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light', 'Emergency Exit', 'Pillow', 'CCTV',
      ...selectedAmenities,
    }.toList();
    final busTypes = {
      'AC Sleeper 2+1', 'Volvo Multi-Axle Semi-Sleeper', 'Bharat Benz AC Sleeper', 'Non-AC Sleeper (2+1)', 'Luxury Seater (2+2)', busType,
    }.toList();
    final categories = {'Premium', 'Executive', 'Royal Class', 'Economy', category}.toList();

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  const Icon(Icons.directions_bus_rounded, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(isEdit ? 'Edit Bus' : 'Add New Bus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Operator Dropdown
                        DropdownButtonFormField<int>(
                          value: operatorId,
                          dropdownColor: AppTheme.bgDark,
                          decoration: InputDecoration(
                            labelText: 'Bus Operator *',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: operators.map((op) {
                            return DropdownMenuItem<int>(
                              value: op.id,
                              child: Text(op.name, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => operatorId = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Bus Name & Number
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: nameCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Bus Model / Name *',
                                  hintText: 'e.g. Scania Multi-Axle Diamond',
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
                              flex: 2,
                              child: TextFormField(
                                controller: numberCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Registration No *',
                                  hintText: 'e.g. KA-01-F-9988',
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

                        // Bus Type & Category
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: busType,
                                dropdownColor: AppTheme.bgDark,
                                decoration: InputDecoration(
                                  labelText: 'Bus Type *',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: busTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => busType = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: category,
                                dropdownColor: AppTheme.bgDark,
                                decoration: InputDecoration(
                                  labelText: 'Category *',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => category = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Deck type & Total seats
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: deckType,
                                dropdownColor: AppTheme.bgDark,
                                decoration: InputDecoration(
                                  labelText: 'Deck Type *',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'single', child: Text('Single Deck')),
                                  DropdownMenuItem(value: 'double', child: Text('Double Deck (Lower/Upper)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setModalState(() => deckType = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: totalSeats.toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Total Seats *',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (v) => totalSeats = int.tryParse(v) ?? 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Toggles
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text('Air Conditioned (AC)', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                                value: isAc,
                                activeColor: AppTheme.primary,
                                onChanged: (v) => setModalState(() => isAc = v),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                title: Text('Live GPS Tracking', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                                value: liveTracking,
                                activeColor: AppTheme.accentTeal,
                                onChanged: (v) => setModalState(() => liveTracking = v),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Amenities Selection
                        Text('Amenities Offered:', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableAmenities.map((amenity) {
                            final isSelected = selectedAmenities.contains(amenity);
                            return FilterChip(
                              label: Text(amenity),
                              selected: isSelected,
                              selectedColor: AppTheme.primary.withOpacity(0.25),
                              checkmarkColor: AppTheme.primary,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              backgroundColor: AppTheme.bgDark,
                              side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedAmenities.add(amenity);
                                  } else {
                                    selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                            );
                          }).toList(),
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
                  child: Text(isEdit ? 'Save Changes' : 'Create Bus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.pop(ctx);

                    final data = {
                      'operatorId': operatorId,
                      'busName': nameCtrl.text.trim(),
                      'busNumber': numberCtrl.text.trim().toUpperCase(),
                      'busType': busType,
                      'category': category,
                      'isAc': isAc,
                      'deckType': deckType,
                      'totalSeats': totalSeats,
                      'amenities': selectedAmenities,
                      'liveTrackingAvailable': liveTracking,
                    };

                    final provider = context.read<BusProvider>();
                    final success = isEdit ? await provider.updateBus(bus.id, data) : await provider.createBus(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                          content: Text(success
                              ? (isEdit ? 'Bus updated successfully!' : 'Bus added successfully!')
                              : (isEdit ? 'Failed to update bus.' : 'Failed to add bus.')),
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

  void _showBusSeatLayoutDialog(BuildContext context, BusModel bus) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          child: Container(
            width: 850,
            height: 620,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.directions_bus_rounded, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${bus.busName} (${bus.busNumber})', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('${bus.operatorName} • ${bus.busType} • ${bus.deckType.toUpperCase()} DECK', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.border, height: 28),
                Expanded(
                  child: VisualBusSeatMatrix(
                    busId: bus.id,
                    deckType: bus.deckType,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteBus(BuildContext context, BusModel bus) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Bus ${bus.busNumber}?',
      message: 'Are you sure you want to remove "${bus.busName}" from the active fleet? Associated scheduled trips will be archived.',
      confirmLabel: 'Delete Bus',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<BusProvider>().deleteBus(bus.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? AppTheme.success : AppTheme.error,
            content: Text(success ? 'Bus successfully deleted.' : 'Failed to delete bus.'),
          ),
        );
      }
    }
  }
}
