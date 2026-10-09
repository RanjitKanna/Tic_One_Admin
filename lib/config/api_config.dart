class ApiConfig {
  static const String productionServerUrl =
      'https://ticonemiddleware-production.up.railway.app';

  static String baseUrl = '$productionServerUrl/api/admin';

  // Endpoints
  static String login = '$baseUrl/auth/login';
  static String me = '$baseUrl/auth/me';
  static String logout = '$baseUrl/auth/logout';

  static String dashboard = '$baseUrl/dashboard';
  static String users = '$baseUrl/users';
  static String movies = '$baseUrl/movies';
  static String cities = '$baseUrl/cities';
  static String theaters = '$baseUrl/theaters';
  static String screens = '$baseUrl/screens';
  static String shows = '$baseUrl/shows';
  static String seats = '$baseUrl/seats';
  static String seatBatch = '$baseUrl/seats/batch';

  static String busOperators = '$baseUrl/bus-operators';
  static String buses = '$baseUrl/buses';
  static String busRoutes = '$baseUrl/routes';
  static String busTrips = '$baseUrl/trips';
  static String boardingPoints = '$baseUrl/boarding-points';
  static String droppingPoints = '$baseUrl/dropping-points';

  static String movieBookings = '$baseUrl/movie-bookings';
  static String busBookings = '$baseUrl/bus-bookings';

  static String payments = '$baseUrl/payments';
  static String refunds = '$baseUrl/refunds';
  static String auditLogs = '$baseUrl/audit-logs';
}
