import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final auth = context.watch<AuthProvider>();
    final collapsed = nav.isSidebarCollapsed;

    return Container(
      width: collapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: const Border(
          right: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGradientStart, AppTheme.primaryGradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'T1',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TIC',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'ONE',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'SUPER ADMIN',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              children: [
                _navItem(
                  context,
                  tab: AdminNavTab.dashboard,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  collapsed: collapsed,
                ),
                _sectionHeader('MOVIES & THEATERS', collapsed),
                _navItem(
                  context,
                  tab: AdminNavTab.movies,
                  icon: Icons.movie_filter_rounded,
                  label: 'Movies',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.theaters,
                  icon: Icons.theater_comedy_rounded,
                  label: 'Theaters & Screens',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.shows,
                  icon: Icons.access_time_filled_rounded,
                  label: 'Shows & Schedule',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.seatEditor,
                  icon: Icons.event_seat_rounded,
                  label: 'Visual Seat Matrix',
                  collapsed: collapsed,
                ),
                _sectionHeader('BUS FLEET & TRIPS', collapsed),
                _navItem(
                  context,
                  tab: AdminNavTab.busTrips,
                  icon: Icons.alt_route_rounded,
                  label: 'Bus Trips',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.buses,
                  icon: Icons.directions_bus_rounded,
                  label: 'Buses Fleet',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.routes,
                  icon: Icons.map_rounded,
                  label: 'Bus Routes',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.operators,
                  icon: Icons.business_rounded,
                  label: 'Bus Operators',
                  collapsed: collapsed,
                ),
                _sectionHeader('MANAGEMENT & OPS', collapsed),
                _navItem(
                  context,
                  tab: AdminNavTab.users,
                  icon: Icons.people_alt_rounded,
                  label: 'Users',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.bookings,
                  icon: Icons.confirmation_number_rounded,
                  label: 'Bookings',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.payments,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Payments & Refunds',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.auditLogs,
                  icon: Icons.history_rounded,
                  label: 'Audit Logs',
                  collapsed: collapsed,
                ),
                _navItem(
                  context,
                  tab: AdminNavTab.settings,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  collapsed: collapsed,
                ),
              ],
            ),
          ),

          // User Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                  child: Text(
                    auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : 'A',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? 'Admin',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.user?.email ?? 'admin@ticone.com',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary, size: 20),
                    tooltip: 'Logout',
                    onPressed: () => auth.logout(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool collapsed) {
    if (collapsed) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required AdminNavTab tab,
    required IconData icon,
    required String label,
    required bool collapsed,
  }) {
    final nav = context.watch<NavigationProvider>();
    final isSelected = nav.currentTab == tab;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => nav.setTab(tab),
          hoverColor: AppTheme.bgCardHover,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 14 : 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppTheme.primary.withOpacity(0.4)) : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
