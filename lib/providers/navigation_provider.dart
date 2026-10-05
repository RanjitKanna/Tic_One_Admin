import 'package:flutter/material.dart';

enum AdminNavTab {
  dashboard,
  users,
  movies,
  theaters,
  shows,
  seatEditor,
  busTrips,
  buses,
  routes,
  operators,
  bookings,
  payments,
  auditLogs,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  AdminNavTab _currentTab = AdminNavTab.dashboard;
  bool _isSidebarCollapsed = false;

  // Contextual data passing for direct editing
  dynamic _selectedItemForEdit;
  Map<String, dynamic>? _extraParams;

  AdminNavTab get currentTab => _currentTab;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  dynamic get selectedItemForEdit => _selectedItemForEdit;
  Map<String, dynamic>? get extraParams => _extraParams;

  void setTab(AdminNavTab tab, {dynamic item, Map<String, dynamic>? params}) {
    _currentTab = tab;
    _selectedItemForEdit = item;
    _extraParams = params;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }
}
