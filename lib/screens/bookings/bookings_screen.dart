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

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.fetchMovieBookings();
      bookingProvider.fetchBusBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final bookingProvider = context.read<BookingProvider>();
    if (_tabController.index == 0) {
      bookingProvider.fetchMovieBookings(search: query, status: _statusFilter);
    } else {
      bookingProvider.fetchBusBookings(search: query, status: _statusFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          AdminHeader(
            title: 'Bookings Management',
            trailing: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Movie Bookings'),
                  Tab(text: 'Bus Bookings'),
                ],
                onTap: (idx) {
                  setState(() {});
                  _onSearch(_searchCtrl.text);
                },
              ),
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
                              hintText: 'Search by booking code, user name, email, or theater/bus...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _onSearch('');
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
                            onSubmitted: _onSearch,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _statusFilter,
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
                            items: const [
                              DropdownMenuItem(value: '', child: Text('All Booking Statuses')),
                              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            ],
                            onChanged: (val) {
                              setState(() => _statusFilter = val ?? '');
                              _onSearch(_searchCtrl.text);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Reload bookings',
                          onPressed: () => _onSearch(_searchCtrl.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Views
                  if (_tabController.index == 0)
                    _buildMovieBookingsTable(bookingProvider)
                  else
                    _buildBusBookingsTable(bookingProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieBookingsTable(BookingProvider provider) {
    return DataTableCard(
      title: 'Movie Bookings (${provider.movieBookings.length})',
      isLoading: provider.isLoading,
      columns: const [
        DataColumn(label: Text('BOOKING CODE')),
        DataColumn(label: Text('CUSTOMER')),
        DataColumn(label: Text('MOVIE & THEATER')),
        DataColumn(label: Text('SHOWTIME')),
        DataColumn(label: Text('SEATS')),
        DataColumn(label: Text('AMOUNT')),
        DataColumn(label: Text('STATUS')),
        DataColumn(label: Text('ACTIONS')),
      ],
      rows: provider.movieBookings.map((b) {
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
                  b.bookingCode,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.accentTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b.userName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(b.userEmail, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b.movieTitle, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('${b.theaterName} • ${b.screenName}', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b.showDate, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(b.showTimeFormatted, style: GoogleFonts.plusJakartaSans(color: AppTheme.accentTeal, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Wrap(
                spacing: 4,
                children: b.seatNumbers.take(3).map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.border)),
                    child: Text(s.toString(), style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.w700)),
                  );
                }).toList(),
              ),
            ),
            DataCell(
              Text('₹${b.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            DataCell(
              StatusBadge(
                status: b.bookingStatus.toUpperCase(),
                type: b.bookingStatus == 'confirmed'
                    ? StatusBadgeType.success
                    : b.bookingStatus == 'cancelled'
                        ? StatusBadgeType.danger
                        : StatusBadgeType.warning,
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.accentTeal),
                    tooltip: 'Booking Details',
                    onPressed: () => _showMovieBookingDetails(context, b),
                  ),
                  if (b.bookingStatus == 'confirmed')
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                      tooltip: 'Cancel & Refund',
                      onPressed: () => _showCancelDialog(context, isMovie: true, id: b.id, code: b.bookingCode, amount: b.totalAmount),
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBusBookingsTable(BookingProvider provider) {
    return DataTableCard(
      title: 'Bus Bookings (${provider.busBookings.length})',
      isLoading: provider.isLoading,
      columns: const [
        DataColumn(label: Text('BOOKING CODE')),
        DataColumn(label: Text('PASSENGER / USER')),
        DataColumn(label: Text('ROUTE CORRIDOR')),
        DataColumn(label: Text('BUS & OPERATOR')),
        DataColumn(label: Text('TRAVEL DATE')),
        DataColumn(label: Text('SEATS')),
        DataColumn(label: Text('AMOUNT')),
        DataColumn(label: Text('STATUS')),
        DataColumn(label: Text('ACTIONS')),
      ],
      rows: provider.busBookings.map((b) {
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
                  b.bookingCode,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.accentTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b.userName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(b.userEmail, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Row(
                children: [
                  Text(b.sourceCity, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 12),
                  ),
                  Text(b.destinationCity, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b.busName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(b.operatorName, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Text(b.travelDate, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            DataCell(
              Text('${b.totalSeats} Seat(s)', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentPurple, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            DataCell(
              Text('₹${b.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            DataCell(
              StatusBadge(
                status: b.bookingStatus.toUpperCase(),
                type: b.bookingStatus == 'confirmed'
                    ? StatusBadgeType.success
                    : b.bookingStatus == 'cancelled'
                        ? StatusBadgeType.danger
                        : StatusBadgeType.warning,
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.accentTeal),
                    tooltip: 'Bus Ticket Details',
                    onPressed: () => _showBusBookingDetails(context, b),
                  ),
                  if (b.bookingStatus == 'confirmed')
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                      tooltip: 'Cancel & Refund',
                      onPressed: () => _showCancelDialog(context, isMovie: false, id: b.id, code: b.bookingCode, amount: b.totalAmount),
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showMovieBookingDetails(BuildContext context, MovieBookingModel b) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          title: Row(
            children: [
              const Icon(Icons.confirmation_number_rounded, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text('Ticket: ${b.bookingCode}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Movie', b.movieTitle),
                _detailRow('Theater', '${b.theaterName} (${b.screenName})'),
                _detailRow('Showtime', '${b.showDate} at ${b.showTimeFormatted}'),
                _detailRow('Booked By', '${b.userName} (${b.userEmail})'),
                _detailRow('Seats', b.seatNumbers.join(', ')),
                _detailRow('Base Price', '₹${b.basePrice.toStringAsFixed(2)}'),
                _detailRow('Convenience Fee', '₹${b.convenienceFee.toStringAsFixed(2)}'),
                _detailRow('Tax (GST)', '₹${b.taxAmount.toStringAsFixed(2)}'),
                const Divider(color: AppTheme.border, height: 20),
                _detailRow('Total Paid', '₹${b.totalAmount.toStringAsFixed(2)}', isBold: true, color: AppTheme.accentGold),
                _detailRow('Payment Status', b.paymentStatus.toUpperCase(), color: AppTheme.success),
                _detailRow('Booking Status', b.bookingStatus.toUpperCase(), color: b.bookingStatus == 'confirmed' ? AppTheme.success : AppTheme.error),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)), onPressed: () => Navigator.pop(ctx)),
          ],
        );
      },
    );
  }

  void _showBusBookingDetails(BuildContext context, BusBookingModel b) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          title: Row(
            children: [
              const Icon(Icons.directions_bus_rounded, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text('Bus Ticket: ${b.bookingCode}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Route', '${b.sourceCity} → ${b.destinationCity}'),
                _detailRow('Bus / Operator', '${b.busName} • ${b.operatorName}'),
                _detailRow('Travel Date', b.travelDate),
                _detailRow('Departure Time', b.departureTimeFormatted),
                _detailRow('Booked By', '${b.userName} (${b.userEmail})'),
                _detailRow('Seats Count', '${b.totalSeats} seats'),
                const Divider(color: AppTheme.border, height: 20),
                _detailRow('Total Paid', '₹${b.totalAmount.toStringAsFixed(2)}', isBold: true, color: AppTheme.accentGold),
                _detailRow('Booking Status', b.bookingStatus.toUpperCase(), color: b.bookingStatus == 'confirmed' ? AppTheme.success : AppTheme.error),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)), onPressed: () => Navigator.pop(ctx)),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12)),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: color ?? Colors.white,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, {required bool isMovie, required int id, required String code, required double amount}) {
    final reasonCtrl = TextEditingController(text: 'Customer requested cancellation via Admin Desk.');
    double refundPercentage = 100.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final refundVal = amount * (refundPercentage / 100.0);

            return AlertDialog(
              backgroundColor: AppTheme.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.error),
                  const SizedBox(width: 10),
                  Text('Cancel Booking & Issue Refund', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Are you sure you want to cancel booking $code? This will release the held seats back to inventory.', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reasonCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Reason for Cancellation *',
                        labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.bgDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Refund Percentage: ${refundPercentage.toStringAsFixed(0)}%', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('Refund: ₹${refundVal.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    Slider(
                      value: refundPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.bgDark,
                      label: '${refundPercentage.toStringAsFixed(0)}%',
                      onChanged: (v) => setModalState(() => refundPercentage = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)), onPressed: () => Navigator.pop(ctx)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                  child: Text('Confirm Cancellation', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final bookingProvider = context.read<BookingProvider>();
                    bool success = false;
                    if (isMovie) {
                      success = await bookingProvider.cancelMovieBooking(id, reason: reasonCtrl.text.trim(), refundPct: refundPercentage);
                    } else {
                      success = await bookingProvider.cancelBusBooking(id, reason: reasonCtrl.text.trim(), refundPct: refundPercentage);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                          content: Text(success ? 'Booking successfully cancelled and refund logged.' : 'Failed to cancel booking.'),
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
}
