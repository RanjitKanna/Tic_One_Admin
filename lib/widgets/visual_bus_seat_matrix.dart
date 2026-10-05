import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/data_providers.dart';

class VisualBusSeatMatrix extends StatefulWidget {
  final List<BusSeatModel>? seats;
  final int? busId;
  final String? deckType;
  final double baseFare;

  const VisualBusSeatMatrix({
    super.key,
    this.seats,
    this.busId,
    this.deckType,
    this.baseFare = 850.0,
  });

  @override
  State<VisualBusSeatMatrix> createState() => _VisualBusSeatMatrixState();
}

class _VisualBusSeatMatrixState extends State<VisualBusSeatMatrix> {
  String _selectedDeck = 'lower';
  BusSeatModel? _selectedSeat;

  @override
  void initState() {
    super.initState();
    if (widget.seats == null && widget.busId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BusProvider>().fetchBusSeats(widget.busId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BusSeatModel> seatList = [];
    if (widget.seats != null) {
      seatList = widget.seats!;
    } else {
      seatList = context.watch<BusProvider>().busSeats;
    }

    final filteredSeats = seatList.where((s) => s.deck.toLowerCase() == _selectedDeck).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bus Matrix Layout
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deck Selector Tabs
                Row(
                  children: [
                    _deckTab('lower', 'LOWER DECK'),
                    const SizedBox(width: 12),
                    _deckTab('upper', 'UPPER DECK'),
                  ],
                ),
                const SizedBox(height: 20),

                // Bus Cabin Shell
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Driver Cabin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ENTRY', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                          ),
                          const Icon(Icons.sports_esports_rounded, color: AppTheme.textSecondary, size: 24), // steering wheel
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: 16),

                      // Bus Seats Grid (2 + 1 sleeper/seater)
                      if (filteredSeats.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('No seats configured for this deck', style: TextStyle(color: AppTheme.textMuted)),
                        )
                      else
                        _buildBusGrid(filteredSeats),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Inspector
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
                      const Icon(Icons.airline_seat_recline_extra_rounded, size: 40, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Select a bus seat to inspect fare & berth details',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEAT ${_selectedSeat!.seatNumber}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _detail('Deck', _selectedSeat!.deck.toUpperCase()),
                      _detail('Berth Type', _selectedSeat!.berthType.toUpperCase()),
                      _detail('Seat Type', _selectedSeat!.seatType.toUpperCase()),
                      _detail('Position', _selectedSeat!.isWindow ? 'Window' : (_selectedSeat!.isAisle ? 'Aisle' : 'Middle')),
                      _detail('Fare', '₹${_selectedSeat!.price.toInt()}'),
                      _detail('Status', _selectedSeat!.status.toUpperCase()),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _deckTab(String deck, String label) {
    final isSelected = _selectedDeck == deck;
    return InkWell(
      onTap: () => setState(() => _selectedDeck = deck),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBusGrid(List<BusSeatModel> seats) {
    // Group seats by rowNum
    final rowsMap = <int, List<BusSeatModel>>{};
    for (final s in seats) {
      rowsMap.putIfAbsent(s.rowNum, () => []).add(s);
    }

    final sortedRowKeys = rowsMap.keys.toList()..sort();

    return Column(
      children: sortedRowKeys.map((rNum) {
        final rowSeats = rowsMap[rNum]!;
        final singleBerth = rowSeats.where((s) => s.columnNum == 1).firstOrNull;
        final doubleBerth1 = rowSeats.where((s) => s.columnNum == 2).firstOrNull;
        final doubleBerth2 = rowSeats.where((s) => s.columnNum == 3).firstOrNull;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Single Berth (Left)
              if (singleBerth != null) _seatBox(singleBerth, isSingle: true) else const SizedBox(width: 50),
              // Aisle
              Container(width: 30, alignment: Alignment.center, child: Text('$rNum', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted))),
              // Double Berth (Right)
              Row(
                children: [
                  if (doubleBerth1 != null) _seatBox(doubleBerth1, isSingle: false) else const SizedBox(width: 44),
                  const SizedBox(width: 6),
                  if (doubleBerth2 != null) _seatBox(doubleBerth2, isSingle: false) else const SizedBox(width: 44),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _seatBox(BusSeatModel seat, {required bool isSingle}) {
    final isSelected = _selectedSeat?.id == seat.id;
    final isBooked = seat.status == 'booked';

    Color color = isBooked ? AppTheme.error : (seat.berthType == 'single' ? AppTheme.secondary : AppTheme.warning);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSeat = seat;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: isSingle ? 54 : 44,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? Colors.white : color, width: isSelected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed_rounded, size: 14, color: isSelected ? Colors.black : color),
            const SizedBox(height: 2),
            Text(
              seat.seatNumber,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
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
}
