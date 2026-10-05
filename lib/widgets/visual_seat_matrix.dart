import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/models.dart';

class VisualSeatMatrix extends StatefulWidget {
  final List<SeatModel> seats;
  final double basePrice;
  final Function(SeatModel seat, String newTier, double newMultiplier) onUpdateTier;
  final Function(SeatModel seat, bool isActive) onToggleActive;
  final Function(SeatModel seat) onDeleteSeat;
  final Function(String rowLabel, int seatNumber, String tier) onAddSeat;

  const VisualSeatMatrix({
    super.key,
    required this.seats,
    this.basePrice = 250.0,
    required this.onUpdateTier,
    required this.onToggleActive,
    required this.onDeleteSeat,
    required this.onAddSeat,
  });

  @override
  State<VisualSeatMatrix> createState() => _VisualSeatMatrixState();
}

class _VisualSeatMatrixState extends State<VisualSeatMatrix> {
  SeatModel? _selectedSeat;

  Color _getTierColor(String tier, String status) {
    if (status == 'booked') return AppTheme.error;
    if (status == 'locked') return AppTheme.warning;
    if (status == 'unavailable') return AppTheme.borderLight;

    final t = tier.toLowerCase();
    if (t.contains('recliner')) return const Color(0xFF00E5FF);
    if (t.contains('platinum')) return const Color(0xFFA855F7);
    if (t.contains('gold')) return const Color(0xFFF59E0B);
    return const Color(0xFF94A3B8); // Silver / Standard
  }

  Map<String, List<SeatModel>> get _groupedSeats {
    final map = <String, List<SeatModel>>{};
    for (final s in widget.seats) {
      map.putIfAbsent(s.rowLabel, () => []).add(s);
    }
    map.forEach((k, list) {
      list.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    });
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedSeats;
    final sortedRows = grouped.keys.toList()..sort();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen & Seat Grid Canvas
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                // Screen representation
                Container(
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.0),
                        AppTheme.primary.withOpacity(0.4),
                        AppTheme.primary.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
                    border: const Border(
                      top: BorderSide(color: AppTheme.primary, width: 3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'CINEMA SCREEN / STAGE THIS WAY',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _legendItem('Recliner', const Color(0xFF00E5FF)),
                    _legendItem('Platinum', const Color(0xFFA855F7)),
                    _legendItem('Gold', const Color(0xFFF59E0B)),
                    _legendItem('Silver', const Color(0xFF94A3B8)),
                    _legendItem('Booked', AppTheme.error),
                    _legendItem('Disabled', AppTheme.borderLight),
                  ],
                ),
                const SizedBox(height: 24),

                // Seating Rows
                if (widget.seats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No seats configured for this screen.\nClick "Generate Layout" to create rows automatically.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, height: 1.5),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: sortedRows.map((rowLabel) {
                        final rowSeats = grouped[rowLabel]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Row Label Header
                              Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: Text(
                                  rowLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Seats Bubbles
                              ...rowSeats.map((seat) {
                                final isSelected = _selectedSeat?.id == seat.id;
                                final color = _getTierColor(seat.tierName, seat.status);

                                return Tooltip(
                                  message: '${seat.seatIdentifier} • ${seat.tierName} (₹${seat.price.toInt()}) [${seat.status}]',
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedSeat = seat;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected ? color : color.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? Colors.white : color,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        seat.seatNumber.toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              // Quick Add Seat button at end of row
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.textMuted),
                                tooltip: 'Add seat to row $rowLabel',
                                onPressed: () {
                                  final nextNum = (rowSeats.isNotEmpty ? rowSeats.last.seatNumber : 0) + 1;
                                  widget.onAddSeat(rowLabel, nextNum, rowSeats.isNotEmpty ? rowSeats.first.tierName : 'Gold');
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Selected Seat Inspector & Editor Panel
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: _selectedSeat == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app_outlined, size: 40, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Select a seat to inspect & edit properties',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SEAT ${_selectedSeat!.seatIdentifier}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getTierColor(_selectedSeat!.tierName, _selectedSeat!.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedSeat!.status.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: _getTierColor(_selectedSeat!.tierName, _selectedSeat!.status),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _detailRow('Calculated Price', '₹${_selectedSeat!.price.toInt()}'),
                      _detailRow('Multiplier', '${_selectedSeat!.multiplier}x'),
                      _detailRow('Active Status', _selectedSeat!.isActive ? 'Enabled' : 'Disabled'),
                      const SizedBox(height: 20),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      Text(
                        'CHANGE TIER',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _tierChip('Recliner', 1.6, const Color(0xFF00E5FF)),
                          _tierChip('Platinum', 1.25, const Color(0xFFA855F7)),
                          _tierChip('Gold', 1.0, const Color(0xFFF59E0B)),
                          _tierChip('Silver', 0.8, const Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedSeat!.isActive ? AppTheme.warning.withOpacity(0.15) : AppTheme.success.withOpacity(0.15),
                          foregroundColor: _selectedSeat!.isActive ? AppTheme.warning : AppTheme.success,
                          elevation: 0,
                        ),
                        onPressed: () {
                          widget.onToggleActive(_selectedSeat!, !_selectedSeat!.isActive);
                        },
                        icon: Icon(_selectedSeat!.isActive ? Icons.block : Icons.check_circle, size: 16),
                        label: Text(_selectedSeat!.isActive ? 'Disable Seat' : 'Enable Seat'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        onPressed: () {
                          widget.onDeleteSeat(_selectedSeat!);
                          setState(() {
                            _selectedSeat = null;
                          });
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Remove Seat'),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12)),
          Text(value, style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _tierChip(String tier, double mult, Color color) {
    final isCurrent = _selectedSeat?.tierName.toLowerCase() == tier.toLowerCase();
    return InkWell(
      onTap: () {
        if (_selectedSeat != null) {
          widget.onUpdateTier(_selectedSeat!, tier, mult);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrent ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          tier,
          style: GoogleFonts.plusJakartaSans(
            color: isCurrent ? Colors.black : color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
