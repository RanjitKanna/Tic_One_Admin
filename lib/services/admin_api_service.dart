import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

class AdminApiService {
  final ApiClient _client = ApiClient();

  // ==========================================
  // AUTH
  // ==========================================
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    final res = await _client.post(ApiConfig.login, body: {'email': email, 'password': password});
    if (res.isSuccess && res.data is Map) {
      final token = res.data['accessToken']?.toString();
      if (token != null) {
        _client.setToken(token);
      }
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: (res.data as Map).cast<String, dynamic>());
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<UserModel>> getMe() async {
    final res = await _client.get(ApiConfig.me);
    if (res.isSuccess && res.data is Map && (res.data as Map).containsKey('user')) {
      final user = UserModel.fromJson((res.data as Map)['user']);
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: user);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<void> logout() async {
    await _client.post(ApiConfig.logout);
    _client.setToken(null);
  }

  // ==========================================
  // DASHBOARD
  // ==========================================
  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    final res = await _client.get(ApiConfig.dashboard);
    if (res.isSuccess && res.data is Map) {
      final stats = DashboardStatsModel.fromJson((res.data as Map).cast<String, dynamic>());
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: stats);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // USERS
  // ==========================================
  Future<ApiResponse<List<UserModel>>> getUsers({String search = '', String role = '', String status = '', int page = 1}) async {
    final q = '?search=$search&role=$role&status=$status&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.users}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['users'] is List) {
      final list = ((res.data as Map)['users'] as List).map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserDetails(int id) async {
    final res = await _client.get('${ApiConfig.users}/$id');
    if (res.isSuccess && res.data is Map) {
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: (res.data as Map).cast<String, dynamic>());
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateUser(int id, {bool? isActive, String? role}) async {
    final body = <String, dynamic>{};
    if (isActive != null) body['isActive'] = isActive;
    if (role != null) body['role'] = role;
    final res = await _client.put('${ApiConfig.users}/$id', body: body);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    final res = await _client.delete('${ApiConfig.users}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // MOVIES
  // ==========================================
  Future<ApiResponse<List<MovieModel>>> getMovies({String search = '', String status = '', String genre = '', int page = 1}) async {
    final q = '?search=$search&status=$status&genre=$genre&page=$page&limit=30';
    final res = await _client.get('${ApiConfig.movies}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['movies'] is List) {
      final list = ((res.data as Map)['movies'] as List).map((m) => MovieModel.fromJson(m as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createMovie(Map<String, dynamic> movieData) async {
    final res = await _client.post(ApiConfig.movies, body: movieData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateMovie(int id, Map<String, dynamic> movieData) async {
    final res = await _client.put('${ApiConfig.movies}/$id', body: movieData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteMovie(int id) async {
    final res = await _client.delete('${ApiConfig.movies}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // CITIES, THEATERS & SCREENS
  // ==========================================
  Future<ApiResponse<List<CityModel>>> getCities() async {
    final res = await _client.get(ApiConfig.cities);
    if (res.isSuccess && res.data is Map && (res.data as Map)['cities'] is List) {
      final list = ((res.data as Map)['cities'] as List).map((c) => CityModel.fromJson(c as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<TheaterModel>>> getTheaters({String search = '', int? cityId, int page = 1}) async {
    final q = '?search=$search&cityId=${cityId ?? ''}&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.theaters}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['theaters'] is List) {
      final list = ((res.data as Map)['theaters'] as List).map((t) => TheaterModel.fromJson(t as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<TheaterModel>> getTheater(int id) async {
    final res = await _client.get('${ApiConfig.theaters}/$id');
    if (res.isSuccess && res.data is Map && (res.data as Map)['theater'] != null) {
      final t = TheaterModel.fromJson((res.data as Map)['theater']);
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: t);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createTheater(Map<String, dynamic> theaterData) async {
    final res = await _client.post(ApiConfig.theaters, body: theaterData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateTheater(int id, Map<String, dynamic> theaterData) async {
    final res = await _client.put('${ApiConfig.theaters}/$id', body: theaterData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteTheater(int id) async {
    final res = await _client.delete('${ApiConfig.theaters}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<ScreenModel>>> getScreens({int? theaterId}) async {
    final q = theaterId != null ? '?theaterId=$theaterId' : '';
    final res = await _client.get('${ApiConfig.screens}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['screens'] is List) {
      final list = ((res.data as Map)['screens'] as List).map((s) => ScreenModel.fromJson(s as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createScreen(Map<String, dynamic> screenData) async {
    final res = await _client.post(ApiConfig.screens, body: screenData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateScreen(int id, Map<String, dynamic> screenData) async {
    final res = await _client.put('${ApiConfig.screens}/$id', body: screenData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteScreen(int id) async {
    final res = await _client.delete('${ApiConfig.screens}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // SHOWS
  // ==========================================
  Future<ApiResponse<List<ShowModel>>> getShows({String search = '', int? movieId, int? theaterId, int? screenId, String date = '', String status = '', int page = 1}) async {
    final q = '?search=$search&movieId=${movieId ?? ''}&theaterId=${theaterId ?? ''}&screenId=${screenId ?? ''}&date=$date&status=$status&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.shows}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['shows'] is List) {
      final list = ((res.data as Map)['shows'] as List).map((s) => ShowModel.fromJson(s as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createShow(Map<String, dynamic> showData) async {
    final res = await _client.post(ApiConfig.shows, body: showData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateShow(int id, Map<String, dynamic> showData) async {
    final res = await _client.put('${ApiConfig.shows}/$id', body: showData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteShow(int id) async {
    final res = await _client.delete('${ApiConfig.shows}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // SEATS MANAGEMENT
  // ==========================================
  Future<ApiResponse<List<SeatModel>>> getSeats({int? screenId, int? showId}) async {
    final q = screenId != null ? '?screenId=$screenId' : '?showId=$showId';
    final res = await _client.get('${ApiConfig.seats}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['seats'] is List) {
      final list = ((res.data as Map)['seats'] as List).map((s) => SeatModel.fromJson(s as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> addSeat(Map<String, dynamic> seatData) async {
    final res = await _client.post(ApiConfig.seats, body: seatData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateSeat(int id, Map<String, dynamic> seatData) async {
    final res = await _client.put('${ApiConfig.seats}/$id', body: seatData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteSeat(int id) async {
    final res = await _client.delete('${ApiConfig.seats}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> batchGenerateSeats(int screenId, int rows, int seatsPerRow, {bool clearExisting = true}) async {
    final res = await _client.post(ApiConfig.seatBatch, body: {
      'screenId': screenId,
      'rows': rows,
      'seatsPerRow': seatsPerRow,
      'clearExisting': clearExisting,
    });
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // BUS MANAGEMENT
  // ==========================================
  Future<ApiResponse<List<BusOperatorModel>>> getBusOperators({String search = ''}) async {
    final res = await _client.get('${ApiConfig.busOperators}?search=$search');
    if (res.isSuccess && res.data is Map && (res.data as Map)['operators'] is List) {
      final list = ((res.data as Map)['operators'] as List).map((o) => BusOperatorModel.fromJson(o as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createBusOperator(Map<String, dynamic> opData) async {
    final res = await _client.post(ApiConfig.busOperators, body: opData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateBusOperator(int id, Map<String, dynamic> opData) async {
    final res = await _client.put('${ApiConfig.busOperators}/$id', body: opData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteBusOperator(int id) async {
    final res = await _client.delete('${ApiConfig.busOperators}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<BusModel>>> getBuses({String search = '', int? operatorId, int page = 1}) async {
    final q = '?search=$search&operatorId=${operatorId ?? ''}&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.buses}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['buses'] is List) {
      final list = ((res.data as Map)['buses'] as List).map((b) => BusModel.fromJson(b as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createBus(Map<String, dynamic> busData) async {
    final res = await _client.post(ApiConfig.buses, body: busData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateBus(int id, Map<String, dynamic> busData) async {
    final res = await _client.put('${ApiConfig.buses}/$id', body: busData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteBus(int id) async {
    final res = await _client.delete('${ApiConfig.buses}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<BusSeatModel>>> getBusSeats(int busId) async {
    final res = await _client.get('${ApiConfig.buses}/$busId/seats');
    if (res.isSuccess && res.data is Map && (res.data as Map)['seats'] is List) {
      final list = ((res.data as Map)['seats'] as List).map((s) => BusSeatModel.fromJson(s as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // BUS ROUTES & TRIPS
  // ==========================================
  Future<ApiResponse<List<BusRouteModel>>> getBusRoutes({String search = ''}) async {
    final res = await _client.get('${ApiConfig.busRoutes}?search=$search');
    if (res.isSuccess && res.data is Map && (res.data as Map)['routes'] is List) {
      final list = ((res.data as Map)['routes'] as List).map((r) => BusRouteModel.fromJson(r as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createBusRoute(Map<String, dynamic> routeData) async {
    final res = await _client.post(ApiConfig.busRoutes, body: routeData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateBusRoute(int id, Map<String, dynamic> routeData) async {
    final res = await _client.put('${ApiConfig.busRoutes}/$id', body: routeData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteBusRoute(int id) async {
    final res = await _client.delete('${ApiConfig.busRoutes}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<BusTripModel>>> getBusTrips({String search = '', int? routeId, int? busId, String date = '', String status = '', int page = 1}) async {
    final q = '?search=$search&routeId=${routeId ?? ''}&busId=${busId ?? ''}&date=$date&status=$status&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.busTrips}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['trips'] is List) {
      final list = ((res.data as Map)['trips'] as List).map((t) => BusTripModel.fromJson(t as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<BusTripModel>> getBusTrip(int id) async {
    final res = await _client.get('${ApiConfig.busTrips}/$id');
    if (res.isSuccess && res.data is Map && (res.data as Map)['trip'] != null) {
      final trip = BusTripModel.fromJson((res.data as Map)['trip']);
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: trip);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> createBusTrip(Map<String, dynamic> tripData) async {
    final res = await _client.post(ApiConfig.busTrips, body: tripData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> updateBusTrip(int id, Map<String, dynamic> tripData) async {
    final res = await _client.put('${ApiConfig.busTrips}/$id', body: tripData);
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> deleteBusTrip(int id) async {
    final res = await _client.delete('${ApiConfig.busTrips}/$id');
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // BOOKINGS (MOVIE & BUS)
  // ==========================================
  Future<ApiResponse<List<MovieBookingModel>>> getMovieBookings({String search = '', String status = '', String date = '', int page = 1}) async {
    final q = '?search=$search&status=$status&date=$date&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.movieBookings}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['bookings'] is List) {
      final list = ((res.data as Map)['bookings'] as List).map((b) => MovieBookingModel.fromJson(b as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<MovieBookingModel>> getMovieBookingDetails(int id) async {
    final res = await _client.get('${ApiConfig.movieBookings}/$id');
    if (res.isSuccess && res.data is Map && (res.data as Map)['booking'] != null) {
      final b = MovieBookingModel.fromJson((res.data as Map)['booking']);
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: b);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> cancelMovieBooking(int id, {String reason = 'Cancelled by Admin', double refundPercentage = 100}) async {
    final res = await _client.post('${ApiConfig.movieBookings}/$id/cancel', body: {'reason': reason, 'refundPercentage': refundPercentage});
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<BusBookingModel>>> getBusBookings({String search = '', String status = '', String date = '', int page = 1}) async {
    final q = '?search=$search&status=$status&date=$date&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.busBookings}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['bookings'] is List) {
      final list = ((res.data as Map)['bookings'] as List).map((b) => BusBookingModel.fromJson(b as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<BusBookingModel>> getBusBookingDetails(int id) async {
    final res = await _client.get('${ApiConfig.busBookings}/$id');
    if (res.isSuccess && res.data is Map && (res.data as Map)['booking'] != null) {
      final b = BusBookingModel.fromJson((res.data as Map)['booking']);
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: b);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<void>> cancelBusBooking(int id, {String reason = 'Cancelled by Admin', double refundPercentage = 90}) async {
    final res = await _client.post('${ApiConfig.busBookings}/$id/cancel', body: {'reason': reason, 'refundPercentage': refundPercentage});
    return ApiResponse(isSuccess: res.isSuccess, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // PAYMENTS & REFUNDS
  // ==========================================
  Future<ApiResponse<List<PaymentModel>>> getPayments({String search = '', String type = 'all', String status = '', int page = 1}) async {
    final q = '?search=$search&type=$type&status=$status&page=$page&limit=25';
    final res = await _client.get('${ApiConfig.payments}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['payments'] is List) {
      final list = ((res.data as Map)['payments'] as List).map((p) => PaymentModel.fromJson(p as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  Future<ApiResponse<List<RefundModel>>> getRefunds({int page = 1}) async {
    final res = await _client.get('${ApiConfig.refunds}?page=$page&limit=25');
    if (res.isSuccess && res.data is Map && (res.data as Map)['refunds'] is List) {
      final list = ((res.data as Map)['refunds'] as List).map((r) => RefundModel.fromJson(r as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }

  // ==========================================
  // AUDIT LOGS
  // ==========================================
  Future<ApiResponse<List<AuditLogModel>>> getAuditLogs({String action = '', String entityType = '', int page = 1}) async {
    final q = '?action=$action&entityType=$entityType&page=$page&limit=30';
    final res = await _client.get('${ApiConfig.auditLogs}$q');
    if (res.isSuccess && res.data is Map && (res.data as Map)['logs'] is List) {
      final list = ((res.data as Map)['logs'] as List).map((l) => AuditLogModel.fromJson(l as Map<String, dynamic>)).toList();
      return ApiResponse(isSuccess: true, statusCode: res.statusCode, data: list);
    }
    return ApiResponse(isSuccess: false, statusCode: res.statusCode, error: res.error);
  }
}
