import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.fetchPayments();
      paymentProvider.fetchRefunds();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final p = context.read<PaymentProvider>();
    p.fetchPayments(search: query, type: _typeFilter);
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          AdminHeader(
            title: 'Payments & Settlement Ledger',
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
                  Tab(text: 'Incoming Payments'),
                  Tab(text: 'Processed Refunds'),
                ],
                onTap: (idx) => setState(() {}),
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
                              hintText: 'Search by payment ID, transaction reference, booking code or user...',
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
                            value: _typeFilter,
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
                              DropdownMenuItem(value: 'all', child: Text('All Booking Types')),
                              DropdownMenuItem(value: 'movie', child: Text('Movie Payments Only')),
                              DropdownMenuItem(value: 'bus', child: Text('Bus Payments Only')),
                            ],
                            onChanged: (val) {
                              setState(() => _typeFilter = val ?? 'all');
                              paymentProvider.fetchPayments(search: _searchCtrl.text, type: _typeFilter);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Reload payments',
                          onPressed: () {
                            paymentProvider.fetchPayments(search: _searchCtrl.text, type: _typeFilter);
                            paymentProvider.fetchRefunds();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Views
                  if (_tabController.index == 0)
                    _buildPaymentsTable(paymentProvider)
                  else
                    _buildRefundsTable(paymentProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable(PaymentProvider provider) {
    return DataTableCard(
      title: 'Settled Transactions (${provider.payments.length})',
      isLoading: provider.isLoading,
      columns: const [
        DataColumn(label: Text('PAYMENT ID')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('BOOKING REF')),
        DataColumn(label: Text('CUSTOMER')),
        DataColumn(label: Text('AMOUNT')),
        DataColumn(label: Text('METHOD')),
        DataColumn(label: Text('TX REFERENCE')),
        DataColumn(label: Text('DATE & TIME')),
        DataColumn(label: Text('STATUS')),
      ],
      rows: provider.payments.map((p) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                p.paymentId,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            DataCell(
              StatusBadge(
                status: p.bookingType.toUpperCase(),
                type: p.bookingType == 'movie' ? StatusBadgeType.primary : StatusBadgeType.warning,
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.border)),
                child: Text(
                  p.bookingCode ?? 'ID #${p.bookingId}',
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.userName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(p.userEmail, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Text(
                '₹${p.amount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            DataCell(
              Row(
                children: [
                  const Icon(Icons.payment_rounded, size: 14, color: AppTheme.accentPurple),
                  const SizedBox(width: 6),
                  Text(p.paymentMethod, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            DataCell(
              Text(
                p.transactionReference,
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
            DataCell(
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt),
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11),
              ),
            ),
            DataCell(
              StatusBadge(
                status: p.status.toUpperCase(),
                type: p.status == 'completed' || p.status == 'paid' || p.status == 'success'
                    ? StatusBadgeType.success
                    : StatusBadgeType.warning,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRefundsTable(PaymentProvider provider) {
    return DataTableCard(
      title: 'Disbursed Refunds (${provider.refunds.length})',
      isLoading: provider.isLoading,
      columns: const [
        DataColumn(label: Text('REFUND ID')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('BOOKING REF')),
        DataColumn(label: Text('CUSTOMER')),
        DataColumn(label: Text('REFUND AMOUNT')),
        DataColumn(label: Text('METHOD')),
        DataColumn(label: Text('TIMESTAMP')),
        DataColumn(label: Text('STATUS')),
      ],
      rows: provider.refunds.map((r) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                r.refundId,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            DataCell(
              StatusBadge(
                status: r.bookingType.toUpperCase(),
                type: r.bookingType == 'movie' ? StatusBadgeType.primary : StatusBadgeType.warning,
              ),
            ),
            DataCell(
              Text(
                r.bookingCode ?? 'ID #${r.bookingId}',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(r.userName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(r.userEmail, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            DataCell(
              Text(
                '₹${r.refundAmount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.error, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            DataCell(
              Text(r.refundMethod, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 12)),
            ),
            DataCell(
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(r.createdAt),
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11),
              ),
            ),
            DataCell(
              StatusBadge(
                status: r.refundStatus.toUpperCase(),
                type: StatusBadgeType.success,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
