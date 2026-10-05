import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/navigation_provider.dart';
import '../widgets/admin_sidebar.dart';
import 'bookings/bookings_screen.dart';
import 'buses/bus_trips_screen.dart';
import 'buses/buses_screen.dart';
import 'buses/operators_screen.dart';
import 'buses/routes_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'movies/movies_screen.dart';
import 'payments/payments_screen.dart';
import 'seats/seat_editor_screen.dart';
import 'settings/settings_screen.dart';
import 'shows/shows_screen.dart';
import 'theaters/theaters_screen.dart';
import 'users/users_screen.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          // Collapsible Left Admin Sidebar
          const AdminSidebar(),

          // Main View Router
          Expanded(
            child: _buildCurrentTab(nav.currentTab),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(AdminNavTab tab) {
    switch (tab) {
      case AdminNavTab.dashboard:
        return const DashboardScreen();
      case AdminNavTab.users:
        return const UsersScreen();
      case AdminNavTab.movies:
        return const MoviesScreen();
      case AdminNavTab.theaters:
        return const TheatersScreen();
      case AdminNavTab.shows:
        return const ShowsScreen();
      case AdminNavTab.seatEditor:
        return const SeatEditorScreen();
      case AdminNavTab.busTrips:
        return const BusTripsScreen();
      case AdminNavTab.buses:
        return const BusesScreen();
      case AdminNavTab.routes:
        return const RoutesScreen();
      case AdminNavTab.operators:
        return const OperatorsScreen();
      case AdminNavTab.bookings:
        return const BookingsScreen();
      case AdminNavTab.payments:
        return const PaymentsScreen();
      case AdminNavTab.auditLogs:
      case AdminNavTab.settings:
        return const SettingsScreen();
    }
  }
}
