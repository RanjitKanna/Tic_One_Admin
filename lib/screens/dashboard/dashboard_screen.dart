import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final nav = context.watch<NavigationProvider>();
    final stats = provider.stats;

    if (provider.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load dashboard', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchStats(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () => provider.fetchStats(),
      color: AppTheme.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Welcome Banner & Quick Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview & Analytics',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time operations monitor for Movies, Theaters & Bus Fleets',
                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => provider.fetchStats(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh Data'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => nav.setTab(AdminNavTab.shows),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Movie Show'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentIndigo),
                      onPressed: () => nav.setTab(AdminNavTab.busTrips),
                      icon: const Icon(Icons.directions_bus_rounded, size: 16),
                      label: const Text('Schedule Bus Trip'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top KPI Cards Grid (4x2 responsive)
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    // Fixed card height so cards don't grow tall on wide screens.
                    mainAxisExtent: 124,
                  ),
                  children: [
                    StatCard(
                      title: 'Total Revenue',
                      value: currencyFmt.format(stats.totalRevenue),
                      icon: Icons.monetization_on_rounded,
                      accentColor: AppTheme.success,
                      subtitle: 'Movie: ${currencyFmt.format(stats.movieRevenue)} | Bus: ${currencyFmt.format(stats.busRevenue)}',
                      trend: '+18.4%',
                      isPositive: true,
                    ),
                    StatCard(
                      title: "Today's Bookings",
                      value: '${stats.todayBookings}',
                      icon: Icons.today_rounded,
                      accentColor: AppTheme.primary,
                      subtitle: 'Active real-time tickets issued',
                      trend: '+12.5%',
                      isPositive: true,
                    ),
                    StatCard(
                      title: 'Total Movie Bookings',
                      value: '${stats.totalMovieBookings}',
                      icon: Icons.movie_filter_rounded,
                      accentColor: AppTheme.secondary,
                      subtitle: '${stats.upcomingShows} upcoming shows active',
                    ),
                    StatCard(
                      title: 'Total Bus Bookings',
                      value: '${stats.totalBusBookings}',
                      icon: Icons.directions_bus_rounded,
                      accentColor: AppTheme.accentIndigo,
                      subtitle: '${stats.upcomingBusTrips} trips scheduled',
                    ),
                    StatCard(
                      title: 'Active Users',
                      value: '${stats.activeUsers}',
                      icon: Icons.people_alt_rounded,
                      accentColor: AppTheme.info,
                      subtitle: 'Total registered: ${stats.totalUsers}',
                    ),
                    StatCard(
                      title: 'Cancelled Bookings',
                      value: '${stats.cancelledBookings}',
                      icon: Icons.cancel_outlined,
                      accentColor: AppTheme.error,
                      subtitle: 'Refunds processed cleanly',
                      trend: '-2.1%',
                      isPositive: true,
                    ),
                    StatCard(
                      title: 'Active Seat Holds',
                      value: '${stats.activeSeatHolds}',
                      icon: Icons.lock_clock_rounded,
                      accentColor: AppTheme.warning,
                      subtitle: '10-minute checkout locks',
                    ),
                    StatCard(
                      title: 'Pending Payments',
                      value: '${stats.pendingPayments}',
                      icon: Icons.payment_rounded,
                      accentColor: AppTheme.textSecondary,
                      subtitle: 'Awaiting webhook verification',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Middle Section: Revenue Trend Line Chart & Booking Share Donut Chart
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line Chart (Revenue Trend)
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Revenue Trend (Last 7 Days)',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Daily combined movie and bus ticket earnings',
                                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _chartLegend('Movies', AppTheme.primary),
                                    const SizedBox(width: 12),
                                    _chartLegend('Buses', AppTheme.accentIndigo),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 220,
                              child: stats.revenueTrend.isEmpty
                                  ? const Center(child: Text('No trend data available'))
                                  : LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          getDrawingHorizontalLine: (val) => FlLine(
                                            color: AppTheme.border.withOpacity(0.5),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (val, meta) {
                                                final idx = val.toInt();
                                                if (idx >= 0 && idx < stats.revenueTrend.length) {
                                                  final dateStr = stats.revenueTrend[idx]['date'].toString();
                                                  final parts = dateStr.split('-');
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      parts.length >= 3 ? '${parts[2]}/${parts[1]}' : dateStr,
                                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          // Movie Revenue line
                                          LineChartBarData(
                                            spots: stats.revenueTrend.asMap().entries.map((e) {
                                              return FlSpot(e.key.toDouble(), double.parse(e.value['movieRevenue'].toString()));
                                            }).toList(),
                                            isCurved: true,
                                            color: AppTheme.primary,
                                            barWidth: 3,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppTheme.primary.withOpacity(0.1),
                                            ),
                                          ),
                                          // Bus Revenue line
                                          LineChartBarData(
                                            spots: stats.revenueTrend.asMap().entries.map((e) {
                                              return FlSpot(e.key.toDouble(), double.parse(e.value['busRevenue'].toString()));
                                            }).toList(),
                                            isCurved: true,
                                            color: AppTheme.accentIndigo,
                                            barWidth: 3,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppTheme.accentIndigo.withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),
                    // Platform Category Share Card
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform Distribution',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Bookings Ratio',
                              style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 160,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      color: AppTheme.primary,
                                      value: stats.totalMovieBookings.toDouble() > 0 ? stats.totalMovieBookings.toDouble() : 1,
                                      title: '${stats.totalMovieBookings}',
                                      radius: 40,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: AppTheme.accentIndigo,
                                      value: stats.totalBusBookings.toDouble() > 0 ? stats.totalBusBookings.toDouble() : 1,
                                      title: '${stats.totalBusBookings}',
                                      radius: 40,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _shareRow('Movies Box Office', '${stats.totalMovieBookings} bookings', AppTheme.primary),
                            const SizedBox(height: 8),
                            _shareRow('Bus Fleet Tickets', '${stats.totalBusBookings} bookings', AppTheme.accentIndigo),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Bottom Section: Live Activity Feed Table
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Recent Activity Feed',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latest tickets, reservations and cancellations',
                              style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => nav.setTab(AdminNavTab.bookings),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: const Text('View All Bookings'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  if (stats.recentActivity.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No recent activity recorded')),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppTheme.bgSurface),
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        columns: const [
                          DataColumn(label: Text('BOOKING CODE')),
                          DataColumn(label: Text('TYPE')),
                          DataColumn(label: Text('USER')),
                          DataColumn(label: Text('TITLE / ROUTE')),
                          DataColumn(label: Text('SEATS')),
                          DataColumn(label: Text('AMOUNT')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('TIME')),
                        ],
                        rows: stats.recentActivity.map((act) {
                          final isMovie = act['type'] == 'movie';
                          final timeStr = DateFormat('hh:mm a, dd MMM').format(DateTime.parse(act['createdAt']).toLocal());
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  act['bookingCode'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.secondary,
                                    
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isMovie ? AppTheme.primary : AppTheme.accentIndigo).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMovie ? Icons.movie_outlined : Icons.directions_bus_outlined,
                                        size: 14,
                                        color: isMovie ? AppTheme.primary : AppTheme.accentIndigo,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isMovie ? 'MOVIE' : 'BUS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isMovie ? AppTheme.primary : AppTheme.accentIndigo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(act['userName'] ?? '')),
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 200),
                                  child: Text(act['itemTitle'] ?? '', overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              DataCell(Text('${act['seats']} seats')),
                              DataCell(
                                Text(
                                  '₹${double.parse(act['amount'].toString()).toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(StatusBadge(status: act['status'] ?? 'confirmed')),
                              DataCell(Text(timeStr, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _shareRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        Text(value, style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
