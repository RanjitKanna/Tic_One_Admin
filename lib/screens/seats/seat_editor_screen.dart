import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/visual_seat_matrix.dart';

class SeatEditorScreen extends StatefulWidget {
  const SeatEditorScreen({super.key});

  @override
  State<SeatEditorScreen> createState() => _SeatEditorScreenState();
}

class _SeatEditorScreenState extends State<SeatEditorScreen> {
  int? _selectedTheaterId;
  int? _selectedScreenId;
  int? _selectedShowId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = context.read<NavigationProvider>();
      final extra = nav.extraParams;

      context.read<TheaterProvider>().fetchInitial();
      context.read<ShowProvider>().fetchShows();

      if (extra != null) {
        if (extra.containsKey('screenId')) {
          _selectedScreenId = extra['screenId'] as int;
        }
        if (extra.containsKey('showId')) {
          _selectedShowId = extra['showId'] as int;
        }
      }

      final theaters = context.read<TheaterProvider>().theaters;
      if (theaters.isNotEmpty && _selectedTheaterId == null) {
        _selectedTheaterId = theaters.first.id;
        _loadScreens(theaters.first.id);
      } else if (_selectedScreenId != null) {
        context.read<SeatProvider>().fetchSeats(screenId: _selectedScreenId, showId: _selectedShowId);
      }
    });
  }

  void _loadScreens(int theaterId) async {
    await context.read<TheaterProvider>().fetchScreens(theaterId: theaterId);
    final screens = context.read<TheaterProvider>().screens.where((s) => s.theaterId == theaterId).toList();
    if (screens.isNotEmpty && mounted) {
      setState(() => _selectedScreenId = screens.first.id);
      context.read<SeatProvider>().fetchSeats(screenId: screens.first.id, showId: _selectedShowId);
    }
  }

  void _openBatchGenerator() {
    if (_selectedScreenId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => _BatchLayoutGeneratorDialog(screenId: _selectedScreenId!),
    );
  }

  void _openAddSeatDialog() {
    if (_selectedScreenId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => _AddSeatDialog(screenId: _selectedScreenId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = context.watch<SeatProvider>();
    final theaterProvider = context.watch<TheaterProvider>();
    final showProvider = context.watch<ShowProvider>();
    final screens = theaterProvider.screens.where((s) => s.theaterId == _selectedTheaterId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTableCard(
            title: 'Visual Seating Matrix & Layout Editor',
            subtitle: 'Real-time interactive seating design: customize tiers (Recliner/Platinum/Gold/Silver), multipliers, and availability',
            isLoading: seatProvider.isLoading,
            trailingAction: Wrap(
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondary,
                    side: const BorderSide(color: AppTheme.secondary),
                  ),
                  onPressed: _selectedScreenId != null ? _openAddSeatDialog : null,
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add Single Seat'),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedScreenId != null ? _openBatchGenerator : null,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Generate Layout Matrix'),
                ),
              ],
            ),
            searchAndFilters: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedTheaterId,
                    dropdownColor: AppTheme.bgCard,
                    decoration: const InputDecoration(labelText: 'Select Theater Venue'),
                    items: theaterProvider.theaters.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedTheaterId = v;
                        _selectedShowId = null;
                        if (v != null) _loadScreens(v);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedScreenId,
                    dropdownColor: AppTheme.bgCard,
                    decoration: const InputDecoration(labelText: 'Select Screen'),
                    items: screens.map((s) => DropdownMenuItem(value: s.id, child: Text(s.screenName))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedScreenId = v;
                        _selectedShowId = null;
                        if (v != null) seatProvider.fetchSeats(screenId: v);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedShowId,
                    dropdownColor: AppTheme.bgCard,
                    decoration: const InputDecoration(labelText: 'Live Show Occupancy (Optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Design Mode (No live locks)')),
                      ...showProvider.shows
                          .where((s) => _selectedScreenId == null || s.screenId == _selectedScreenId)
                          .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.movieTitle} (${s.showTimeFormatted})', overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedShowId = v);
                      if (_selectedScreenId != null) {
                        seatProvider.fetchSeats(screenId: _selectedScreenId, showId: v);
                      }
                    },
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: VisualSeatMatrix(
                seats: seatProvider.seats,
                basePrice: 250.0,
                onUpdateTier: (seat, newTier, newMultiplier) {
                  seatProvider.updateSeatTier(seat.id, newTier, newMultiplier);
                },
                onToggleActive: (seat, isActive) {
                  seatProvider.toggleSeatActive(seat.id, isActive);
                },
                onDeleteSeat: (seat) async {
                  final conf = await ConfirmationDialog.show(
                    context,
                    title: 'Remove Seat ${seat.seatIdentifier}?',
                    message: 'Are you sure you want to remove this seat from the auditorium layout?',
                  );
                  if (conf == true) {
                    await seatProvider.deleteSeat(seat.id);
                  }
                },
                onAddSeat: (rowLabel, seatNum, tier) async {
                  final mult = tier.toLowerCase() == 'recliner' ? 1.6 : (tier.toLowerCase() == 'platinum' ? 1.25 : 1.0);
                  await seatProvider.addSeat({
                    'screenId': _selectedScreenId,
                    'rowLabel': rowLabel,
                    'seatNumber': seatNum,
                    'tierName': tier,
                    'multiplier': mult,
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchLayoutGeneratorDialog extends StatefulWidget {
  final int screenId;
  const _BatchLayoutGeneratorDialog({required this.screenId});

  @override
  State<_BatchLayoutGeneratorDialog> createState() => _BatchLayoutGeneratorDialogState();
}

class _BatchLayoutGeneratorDialogState extends State<_BatchLayoutGeneratorDialog> {
  final _rowsCtrl = TextEditingController(text: '8');
  final _seatsPerRowCtrl = TextEditingController(text: '12');

  void _generate() async {
    final rows = int.tryParse(_rowsCtrl.text.trim()) ?? 8;
    final seats = int.tryParse(_seatsPerRowCtrl.text.trim()) ?? 12;

    Navigator.of(context).pop();
    final provider = context.read<SeatProvider>();
    final success = await provider.generateLayout(widget.screenId, rows, seats);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated ${rows * seats} seats successfully!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch Layout Matrix Generator', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'This will configure standard cinema rows A through H with tiered Recliner/Platinum/Gold pricing.',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rowsCtrl,
                    decoration: const InputDecoration(labelText: 'Number of Rows (e.g. 8)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _seatsPerRowCtrl,
                    decoration: const InputDecoration(labelText: 'Seats Per Row (e.g. 12)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _generate, child: const Text('Generate Matrix')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSeatDialog extends StatefulWidget {
  final int screenId;
  const _AddSeatDialog({required this.screenId});

  @override
  State<_AddSeatDialog> createState() => _AddSeatDialogState();
}

class _AddSeatDialogState extends State<_AddSeatDialog> {
  final _rowCtrl = TextEditingController(text: 'A');
  final _numberCtrl = TextEditingController(text: '1');
  String _tier = 'Gold';

  void _add() async {
    final row = _rowCtrl.text.trim().toUpperCase();
    final num = int.tryParse(_numberCtrl.text.trim()) ?? 1;
    final mult = _tier == 'Recliner' ? 1.6 : (_tier == 'Platinum' ? 1.25 : 1.0);

    Navigator.of(context).pop();
    await context.read<SeatProvider>().addSeat({
      'screenId': widget.screenId,
      'rowLabel': row,
      'seatNumber': num,
      'tierName': _tier,
      'multiplier': mult,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Single Seat', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rowCtrl,
                    decoration: const InputDecoration(labelText: 'Row Label (e.g. A)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _numberCtrl,
                    decoration: const InputDecoration(labelText: 'Seat Number (e.g. 1)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tier,
              dropdownColor: AppTheme.bgCard,
              decoration: const InputDecoration(labelText: 'Tier'),
              items: const [
                DropdownMenuItem(value: 'Recliner', child: Text('Recliner (1.6x)')),
                DropdownMenuItem(value: 'Platinum', child: Text('Platinum (1.25x)')),
                DropdownMenuItem(value: 'Gold', child: Text('Gold (1.0x)')),
                DropdownMenuItem(value: 'Silver', child: Text('Silver (0.8x)')),
              ],
              onChanged: (v) => setState(() => _tier = v!),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _add, child: const Text('Add Seat')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
