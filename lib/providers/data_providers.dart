import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/admin_api_service.dart';

// ==========================================
// USER PROVIDER
// ==========================================
class UserProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _roleFilter = '';
  String _statusFilter = '';

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers({String? search, String? role, String? status}) async {
    if (search != null) _search = search;
    if (role != null) _roleFilter = role;
    if (status != null) _statusFilter = status;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getUsers(search: _search, role: _roleFilter, status: _statusFilter);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _users = res.data!;
    } else {
      _error = res.error ?? 'Failed to fetch users';
    }
    notifyListeners();
  }

  Future<bool> toggleUserStatus(int id, bool newStatus) async {
    final res = await _apiService.updateUser(id, isActive: newStatus);
    if (res.isSuccess) {
      await fetchUsers();
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(int id) async {
    final res = await _apiService.deleteUser(id);
    if (res.isSuccess) {
      await fetchUsers();
      return true;
    }
    return false;
  }
}

// ==========================================
// MOVIE PROVIDER
// ==========================================
class MovieProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<MovieModel> _movies = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _statusFilter = '';
  String _genreFilter = '';

  List<MovieModel> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMovies({String? search, String? status, String? genre}) async {
    if (search != null) _search = search;
    if (status != null) _statusFilter = status;
    if (genre != null) _genreFilter = genre;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getMovies(search: _search, status: _statusFilter, genre: _genreFilter);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _movies = res.data!;
    } else {
      _error = res.error ?? 'Failed to load movies';
    }
    notifyListeners();
  }

  Future<bool> createMovie(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.createMovie(data);
    _isLoading = false;
    if (res.isSuccess) {
      await fetchMovies();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> updateMovie(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.updateMovie(id, data);
    _isLoading = false;
    if (res.isSuccess) {
      await fetchMovies();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteMovie(int id) async {
    final res = await _apiService.deleteMovie(id);
    if (res.isSuccess) {
      await fetchMovies();
      return true;
    }
    return false;
  }
}

// ==========================================
// THEATER PROVIDER
// ==========================================
class TheaterProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<TheaterModel> _theaters = [];
  List<CityModel> _cities = [];
  List<ScreenModel> _screens = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  int? _cityIdFilter;

  List<TheaterModel> get theaters => _theaters;
  List<CityModel> get cities => _cities;
  List<ScreenModel> get screens => _screens;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInitial() async {
    await Future.wait([fetchCities(), fetchTheaters(), fetchScreens()]);
  }

  Future<void> fetchCities() async {
    final res = await _apiService.getCities();
    if (res.isSuccess && res.data != null) {
      _cities = res.data!;
      notifyListeners();
    }
  }

  Future<void> fetchTheaters({String? search, int? cityId}) async {
    if (search != null) _search = search;
    if (cityId != null) _cityIdFilter = cityId;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getTheaters(search: _search, cityId: _cityIdFilter);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _theaters = res.data!;
    } else {
      _error = res.error ?? 'Failed to load theaters';
    }
    notifyListeners();
  }

  Future<void> fetchScreens({int? theaterId}) async {
    final res = await _apiService.getScreens(theaterId: theaterId);
    if (res.isSuccess && res.data != null) {
      _screens = res.data!;
      notifyListeners();
    }
  }

  Future<bool> createTheater(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.createTheater(data);
    _isLoading = false;
    if (res.isSuccess) {
      await fetchTheaters();
      await fetchScreens();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> updateTheater(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.updateTheater(id, data);
    _isLoading = false;
    if (res.isSuccess) {
      await fetchTheaters();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteTheater(int id) async {
    final res = await _apiService.deleteTheater(id);
    if (res.isSuccess) {
      await fetchTheaters();
      return true;
    }
    return false;
  }

  Future<bool> createScreen(Map<String, dynamic> data) async {
    final res = await _apiService.createScreen(data);
    if (res.isSuccess) {
      await fetchTheaters();
      await fetchScreens();
      return true;
    }
    return false;
  }

  Future<bool> deleteScreen(int id) async {
    final res = await _apiService.deleteScreen(id);
    if (res.isSuccess) {
      await fetchScreens();
      await fetchTheaters();
      return true;
    }
    return false;
  }
}

// ==========================================
// SHOW PROVIDER
// ==========================================
class ShowProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<ShowModel> _shows = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  int? _movieIdFilter;
  int? _theaterIdFilter;
  String _dateFilter = '';

  List<ShowModel> get shows => _shows;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShows({String? search, int? movieId, int? theaterId, String? date}) async {
    if (search != null) _search = search;
    if (movieId != null) _movieIdFilter = movieId;
    if (theaterId != null) _theaterIdFilter = theaterId;
    if (date != null) _dateFilter = date;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getShows(
      search: _search,
      movieId: _movieIdFilter,
      theaterId: _theaterIdFilter,
      date: _dateFilter,
    );
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _shows = res.data!;
    } else {
      _error = res.error ?? 'Failed to load shows';
    }
    notifyListeners();
  }

  Future<String?> createShow(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.createShow(data);
    _isLoading = false;

    if (res.isSuccess) {
      await fetchShows();
      return null; // Success, no error
    } else {
      _error = res.error;
      notifyListeners();
      return res.error ?? 'Conflict or invalid parameters';
    }
  }

  Future<bool> updateShow(int id, Map<String, dynamic> data) async {
    final res = await _apiService.updateShow(id, data);
    if (res.isSuccess) {
      await fetchShows();
      return true;
    }
    return false;
  }

  Future<bool> deleteShow(int id) async {
    final res = await _apiService.deleteShow(id);
    if (res.isSuccess) {
      await fetchShows();
      return true;
    }
    return false;
  }
}

// ==========================================
// SEAT PROVIDER (Visual Seat Matrix)
// ==========================================
class SeatProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<SeatModel> _seats = [];
  int? _activeScreenId;
  int? _activeShowId;
  bool _isLoading = false;
  String? _error;

  List<SeatModel> get seats => _seats;
  int? get activeScreenId => _activeScreenId;
  int? get activeShowId => _activeShowId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Group seats by row
  Map<String, List<SeatModel>> get seatsByRow {
    final map = <String, List<SeatModel>>{};
    for (final s in _seats) {
      map.putIfAbsent(s.rowLabel, () => []).add(s);
    }
    map.forEach((key, list) {
      list.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    });
    return map;
  }

  Future<void> fetchSeats({int? screenId, int? showId}) async {
    _activeScreenId = screenId;
    _activeShowId = showId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getSeats(screenId: screenId, showId: showId);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _seats = res.data!;
    } else {
      _error = res.error ?? 'Failed to load seats layout';
    }
    notifyListeners();
  }

  Future<bool> updateSeatTier(int id, String tierName, double multiplier) async {
    final res = await _apiService.updateSeat(id, {'tierName': tierName, 'multiplier': multiplier});
    if (res.isSuccess) {
      await fetchSeats(screenId: _activeScreenId, showId: _activeShowId);
      return true;
    }
    return false;
  }

  Future<bool> toggleSeatActive(int id, bool isActive) async {
    final res = await _apiService.updateSeat(id, {'isActive': isActive});
    if (res.isSuccess) {
      await fetchSeats(screenId: _activeScreenId, showId: _activeShowId);
      return true;
    }
    return false;
  }

  Future<bool> deleteSeat(int id) async {
    final res = await _apiService.deleteSeat(id);
    if (res.isSuccess) {
      await fetchSeats(screenId: _activeScreenId, showId: _activeShowId);
      return true;
    }
    return false;
  }

  Future<bool> addSeat(Map<String, dynamic> data) async {
    final res = await _apiService.addSeat(data);
    if (res.isSuccess) {
      await fetchSeats(screenId: _activeScreenId, showId: _activeShowId);
      return true;
    }
    return false;
  }

  Future<bool> generateLayout(int screenId, int rows, int seatsPerRow) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.batchGenerateSeats(screenId, rows, seatsPerRow);
    _isLoading = false;
    if (res.isSuccess) {
      await fetchSeats(screenId: screenId);
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }
}

// ==========================================
// BUS PROVIDER
// ==========================================
class BusProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<BusOperatorModel> _operators = [];
  List<BusModel> _buses = [];
  List<BusRouteModel> _routes = [];
  List<BusTripModel> _trips = [];
  List<BusSeatModel> _busSeats = [];
  bool _isLoading = false;
  String? _error;

  List<BusOperatorModel> get operators => _operators;
  List<BusModel> get buses => _buses;
  List<BusRouteModel> get routes => _routes;
  List<BusTripModel> get trips => _trips;
  List<BusSeatModel> get busSeats => _busSeats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    await Future.wait([fetchOperators(), fetchBuses(), fetchRoutes(), fetchTrips()]);
  }

  Future<void> fetchOperators({String search = ''}) async {
    final res = await _apiService.getBusOperators(search: search);
    if (res.isSuccess && res.data != null) {
      _operators = res.data!;
      notifyListeners();
    }
  }

  Future<void> fetchBuses({String search = '', int? operatorId}) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.getBuses(search: search, operatorId: operatorId);
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _buses = res.data!;
    }
    notifyListeners();
  }

  Future<void> fetchBusSeats(int busId) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.getBusSeats(busId);
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _busSeats = res.data!;
    }
    notifyListeners();
  }

  Future<void> fetchRoutes({String search = ''}) async {
    final res = await _apiService.getBusRoutes(search: search);
    if (res.isSuccess && res.data != null) {
      _routes = res.data!;
      notifyListeners();
    }
  }

  Future<void> fetchTrips({String search = '', int? routeId, int? busId, String date = ''}) async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.getBusTrips(search: search, routeId: routeId, busId: busId, date: date);
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _trips = res.data!;
    }
    notifyListeners();
  }

  Future<bool> createOperator(Map<String, dynamic> data) async {
    final res = await _apiService.createBusOperator(data);
    if (res.isSuccess) {
      await fetchOperators();
      return true;
    }
    return false;
  }

  Future<bool> updateOperator(int id, Map<String, dynamic> data) async {
    final res = await _apiService.updateBusOperator(id, data);
    if (res.isSuccess) {
      await fetchOperators();
      return true;
    }
    return false;
  }

  Future<bool> deleteOperator(int id) async {
    final res = await _apiService.deleteBusOperator(id);
    if (res.isSuccess) {
      await fetchOperators();
      return true;
    }
    return false;
  }

  Future<bool> createBus(Map<String, dynamic> data) async {
    final res = await _apiService.createBus(data);
    if (res.isSuccess) {
      await fetchBuses();
      return true;
    }
    return false;
  }

  Future<bool> updateBus(int id, Map<String, dynamic> data) async {
    final res = await _apiService.updateBus(id, data);
    if (res.isSuccess) {
      await fetchBuses();
      return true;
    }
    return false;
  }

  Future<bool> deleteBus(int id) async {
    final res = await _apiService.deleteBus(id);
    if (res.isSuccess) {
      await fetchBuses();
      return true;
    }
    return false;
  }

  Future<bool> createRoute(Map<String, dynamic> data) async {
    final res = await _apiService.createBusRoute(data);
    if (res.isSuccess) {
      await fetchRoutes();
      return true;
    }
    return false;
  }

  Future<bool> updateRoute(int id, Map<String, dynamic> data) async {
    final res = await _apiService.updateBusRoute(id, data);
    if (res.isSuccess) {
      await fetchRoutes();
      return true;
    }
    return false;
  }

  Future<bool> deleteRoute(int id) async {
    final res = await _apiService.deleteBusRoute(id);
    if (res.isSuccess) {
      await fetchRoutes();
      return true;
    }
    return false;
  }

  Future<bool> createTrip(Map<String, dynamic> data) async {
    final res = await _apiService.createBusTrip(data);
    if (res.isSuccess) {
      await fetchTrips();
      return true;
    }
    return false;
  }

  Future<bool> updateTrip(int id, Map<String, dynamic> data) async {
    final res = await _apiService.updateBusTrip(id, data);
    if (res.isSuccess) {
      await fetchTrips();
      return true;
    }
    return false;
  }

  Future<bool> deleteTrip(int id) async {
    final res = await _apiService.deleteBusTrip(id);
    if (res.isSuccess) {
      await fetchTrips();
      return true;
    }
    return false;
  }
}

// ==========================================
// BOOKING PROVIDER
// ==========================================
class BookingProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<MovieBookingModel> _movieBookings = [];
  List<BusBookingModel> _busBookings = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _status = '';
  String _date = '';

  List<MovieBookingModel> get movieBookings => _movieBookings;
  List<BusBookingModel> get busBookings => _busBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMovieBookings({String? search, String? status, String? date}) async {
    if (search != null) _search = search;
    if (status != null) _status = status;
    if (date != null) _date = date;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getMovieBookings(search: _search, status: _status, date: _date);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _movieBookings = res.data!;
    } else {
      _error = res.error;
    }
    notifyListeners();
  }

  Future<void> fetchBusBookings({String? search, String? status, String? date}) async {
    if (search != null) _search = search;
    if (status != null) _status = status;
    if (date != null) _date = date;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getBusBookings(search: _search, status: _status, date: _date);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _busBookings = res.data!;
    } else {
      _error = res.error;
    }
    notifyListeners();
  }

  Future<bool> cancelMovieBooking(int id, {String reason = 'Admin cancellation', double refundPct = 100}) async {
    final res = await _apiService.cancelMovieBooking(id, reason: reason, refundPercentage: refundPct);
    if (res.isSuccess) {
      await fetchMovieBookings();
      return true;
    }
    return false;
  }

  Future<bool> cancelBusBooking(int id, {String reason = 'Admin cancellation', double refundPct = 90}) async {
    final res = await _apiService.cancelBusBooking(id, reason: reason, refundPercentage: refundPct);
    if (res.isSuccess) {
      await fetchBusBookings();
      return true;
    }
    return false;
  }
}

// ==========================================
// PAYMENT PROVIDER
// ==========================================
class PaymentProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<PaymentModel> _payments = [];
  List<RefundModel> _refunds = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _typeFilter = 'all';

  List<PaymentModel> get payments => _payments;
  List<RefundModel> get refunds => _refunds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPayments({String? search, String? type}) async {
    if (search != null) _search = search;
    if (type != null) _typeFilter = type;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getPayments(search: _search, type: _typeFilter);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _payments = res.data!;
    } else {
      _error = res.error;
    }
    notifyListeners();
  }

  Future<void> fetchRefunds() async {
    _isLoading = true;
    notifyListeners();
    final res = await _apiService.getRefunds();
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _refunds = res.data!;
    }
    notifyListeners();
  }
}

// ==========================================
// AUDIT LOG PROVIDER
// ==========================================
class AuditProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  List<AuditLogModel> _logs = [];
  bool _isLoading = false;
  String? _error;

  List<AuditLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLogs({String action = '', String entityType = ''}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getAuditLogs(action: action, entityType: entityType);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _logs = res.data!;
    } else {
      _error = res.error;
    }
    notifyListeners();
  }
}
