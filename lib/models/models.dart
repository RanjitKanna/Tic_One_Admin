// ==========================================
// USER MODEL
// ==========================================
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'user',
      isActive: json['isActive'] == true || json['is_active'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

// ==========================================
// MOVIE MODEL
// ==========================================
class MovieModel {
  final int id;
  final String movieCode;
  final String slug;
  final String title;
  final String? subtitle;
  final String? synopsis;
  final String genre;
  final String language;
  final int durationMins;
  final String certificate;
  final double rating;
  final String ratingCount;
  final String imageUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String status;
  final String releaseDate;
  final String format;
  final String? badgeText;
  final String? matchPercent;
  final bool isTrending;
  final bool isFillingFast;
  final bool isAdvanceBookingOpen;
  final String? cast;
  final String? director;
  final DateTime? createdAt;

  MovieModel({
    required this.id,
    required this.movieCode,
    required this.slug,
    required this.title,
    this.subtitle,
    this.synopsis,
    required this.genre,
    required this.language,
    required this.durationMins,
    required this.certificate,
    required this.rating,
    required this.ratingCount,
    required this.imageUrl,
    this.bannerUrl,
    this.trailerUrl,
    required this.status,
    required this.releaseDate,
    required this.format,
    this.badgeText,
    this.matchPercent,
    required this.isTrending,
    required this.isFillingFast,
    required this.isAdvanceBookingOpen,
    this.cast,
    this.director,
    this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      movieCode: json['movieCode']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      synopsis: json['synopsis']?.toString(),
      genre: json['genre']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      durationMins: json['durationMins'] is int ? json['durationMins'] : int.tryParse(json['durationMins']?.toString() ?? '120') ?? 120,
      certificate: json['certificate']?.toString() ?? 'UA',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      ratingCount: json['ratingCount']?.toString() ?? '0',
      imageUrl: json['imageUrl']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString(),
      trailerUrl: json['trailerUrl']?.toString(),
      status: json['status']?.toString() ?? 'now_showing',
      releaseDate: json['releaseDate']?.toString() ?? '',
      format: json['format']?.toString() ?? '2D',
      badgeText: json['badgeText']?.toString(),
      matchPercent: json['matchPercent']?.toString(),
      isTrending: json['isTrending'] == true,
      isFillingFast: json['isFillingFast'] == true,
      isAdvanceBookingOpen: json['isAdvanceBookingOpen'] == true,
      cast: json['cast']?.toString(),
      director: json['director']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

// ==========================================
// THEATER & SCREEN MODEL
// ==========================================
class CityModel {
  final int id;
  final String name;
  final bool isPopular;

  CityModel({required this.id, required this.name, required this.isPopular});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      isPopular: json['isPopular'] == true,
    );
  }
}

class TheaterModel {
  final int id;
  final String theaterCode;
  final String name;
  final int cityId;
  final String cityName;
  final String? distanceInfo;
  final String? landmark;
  final String? address;
  final String? formats;
  final double? latitude;
  final double? longitude;
  final bool isFastFilling;
  final int screenCount;
  final List<ScreenModel> screens;

  TheaterModel({
    required this.id,
    required this.theaterCode,
    required this.name,
    required this.cityId,
    required this.cityName,
    this.distanceInfo,
    this.landmark,
    this.address,
    this.formats,
    this.latitude,
    this.longitude,
    required this.isFastFilling,
    required this.screenCount,
    this.screens = const [],
  });

  factory TheaterModel.fromJson(Map<String, dynamic> json) {
    var rawScreens = <ScreenModel>[];
    if (json['screens'] is List) {
      rawScreens = (json['screens'] as List).map((s) => ScreenModel.fromJson(s as Map<String, dynamic>)).toList();
    }
    return TheaterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      theaterCode: json['theaterCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cityId: json['cityId'] is int ? json['cityId'] : int.tryParse(json['cityId'].toString()) ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      distanceInfo: json['distanceInfo']?.toString(),
      landmark: json['landmark']?.toString(),
      address: json['address']?.toString(),
      formats: json['formats']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      isFastFilling: json['isFastFilling'] == true,
      screenCount: json['screenCount'] is int ? json['screenCount'] : int.tryParse(json['screenCount']?.toString() ?? '0') ?? rawScreens.length,
      screens: rawScreens,
    );
  }
}

class ScreenModel {
  final int id;
  final int theaterId;
  final String screenName;
  final int totalSeats;
  final String? theaterName;
  final int actualSeats;

  ScreenModel({
    required this.id,
    required this.theaterId,
    required this.screenName,
    required this.totalSeats,
    this.theaterName,
    this.actualSeats = 0,
  });

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    return ScreenModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      theaterId: json['theaterId'] is int ? json['theaterId'] : int.tryParse(json['theaterId']?.toString() ?? '0') ?? 0,
      screenName: json['screenName']?.toString() ?? '',
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '80') ?? 80,
      theaterName: json['theaterName']?.toString(),
      actualSeats: json['actualSeats'] is int ? json['actualSeats'] : int.tryParse(json['actualSeats']?.toString() ?? '0') ?? 0,
    );
  }
}

// ==========================================
// SHOW MODEL
// ==========================================
class ShowModel {
  final int id;
  final int movieId;
  final String movieTitle;
  final String? movieImage;
  final int durationMins;
  final int screenId;
  final String screenName;
  final int theaterId;
  final String theaterName;
  final DateTime showTime;
  final String showTimeFormatted;
  final String language;
  final String format;
  final double basePrice;
  final String status;
  final bool isFastFilling;
  final int bookingCount;
  final int totalSeats;

  ShowModel({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    this.movieImage,
    required this.durationMins,
    required this.screenId,
    required this.screenName,
    required this.theaterId,
    required this.theaterName,
    required this.showTime,
    required this.showTimeFormatted,
    required this.language,
    required this.format,
    required this.basePrice,
    required this.status,
    required this.isFastFilling,
    this.bookingCount = 0,
    this.totalSeats = 100,
  });

  factory ShowModel.fromJson(Map<String, dynamic> json) {
    return ShowModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      movieId: json['movieId'] is int ? json['movieId'] : int.tryParse(json['movieId']?.toString() ?? '0') ?? 0,
      movieTitle: json['movieTitle']?.toString() ?? '',
      movieImage: json['movieImage']?.toString(),
      durationMins: json['durationMins'] is int ? json['durationMins'] : int.tryParse(json['durationMins']?.toString() ?? '120') ?? 120,
      screenId: json['screenId'] is int ? json['screenId'] : int.tryParse(json['screenId']?.toString() ?? '0') ?? 0,
      screenName: json['screenName']?.toString() ?? '',
      theaterId: json['theaterId'] is int ? json['theaterId'] : int.tryParse(json['theaterId']?.toString() ?? '0') ?? 0,
      theaterName: json['theaterName']?.toString() ?? '',
      showTime: DateTime.tryParse(json['showTime']?.toString() ?? '') ?? DateTime.now(),
      showTimeFormatted: json['showTimeFormatted']?.toString() ?? '',
      language: json['language']?.toString() ?? 'English',
      format: json['format']?.toString() ?? '2D',
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '250') ?? 250.0,
      status: json['status']?.toString() ?? 'active',
      isFastFilling: json['isFastFilling'] == true,
      bookingCount: json['bookingCount'] is int ? json['bookingCount'] : int.tryParse(json['bookingCount']?.toString() ?? '0') ?? 0,
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '100') ?? 100,
    );
  }
}

// ==========================================
// SEAT MODEL
// ==========================================
class SeatModel {
  final int id;
  final String rowLabel;
  final int seatNumber;
  final String seatIdentifier;
  final String tierName;
  final String seatType;
  final double multiplier;
  final double price;
  final bool isActive;
  final String status; // 'available', 'booked', 'locked', 'unavailable'

  SeatModel({
    required this.id,
    required this.rowLabel,
    required this.seatNumber,
    required this.seatIdentifier,
    required this.tierName,
    required this.seatType,
    required this.multiplier,
    required this.price,
    required this.isActive,
    required this.status,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      rowLabel: json['rowLabel']?.toString() ?? 'A',
      seatNumber: json['seatNumber'] is int ? json['seatNumber'] : int.tryParse(json['seatNumber']?.toString() ?? '1') ?? 1,
      seatIdentifier: json['seatIdentifier']?.toString() ?? '',
      tierName: json['tierName']?.toString() ?? 'Gold',
      seatType: json['seatType']?.toString() ?? 'normal',
      multiplier: double.tryParse(json['multiplier']?.toString() ?? '1.0') ?? 1.0,
      price: double.tryParse(json['price']?.toString() ?? '250') ?? 250.0,
      isActive: json['isActive'] != false,
      status: json['status']?.toString() ?? 'available',
    );
  }
}

// ==========================================
// BUS OPERATOR & BUS MODELS
// ==========================================
class BusOperatorModel {
  final int id;
  final String operatorCode;
  final String name;
  final String? logoUrl;
  final double rating;
  final int totalReviews;
  final String? contactNumber;
  final String? email;
  final String? cancellationPolicy;
  final int busCount;

  BusOperatorModel({
    required this.id,
    required this.operatorCode,
    required this.name,
    this.logoUrl,
    required this.rating,
    required this.totalReviews,
    this.contactNumber,
    this.email,
    this.cancellationPolicy,
    required this.busCount,
  });

  factory BusOperatorModel.fromJson(Map<String, dynamic> json) {
    return BusOperatorModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      operatorCode: json['operatorCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '4.5') ?? 4.5,
      totalReviews: json['totalReviews'] is int ? json['totalReviews'] : int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      contactNumber: json['contactNumber']?.toString(),
      email: json['email']?.toString(),
      cancellationPolicy: json['cancellationPolicy']?.toString(),
      busCount: json['busCount'] is int ? json['busCount'] : int.tryParse(json['busCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class BusModel {
  final int id;
  final String busCode;
  final int operatorId;
  final String operatorName;
  final String? operatorLogo;
  final String busName;
  final String busNumber;
  final String busType;
  final String category;
  final bool isAc;
  final String deckType;
  final int totalSeats;
  final List<dynamic> amenities;
  final bool liveTrackingAvailable;
  final int configuredSeats;

  BusModel({
    required this.id,
    required this.busCode,
    required this.operatorId,
    required this.operatorName,
    this.operatorLogo,
    required this.busName,
    required this.busNumber,
    required this.busType,
    required this.category,
    required this.isAc,
    required this.deckType,
    required this.totalSeats,
    required this.amenities,
    required this.liveTrackingAvailable,
    this.configuredSeats = 0,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      busCode: json['busCode']?.toString() ?? '',
      operatorId: json['operatorId'] is int ? json['operatorId'] : int.tryParse(json['operatorId']?.toString() ?? '0') ?? 0,
      operatorName: json['operatorName']?.toString() ?? '',
      operatorLogo: json['operatorLogo']?.toString(),
      busName: json['busName']?.toString() ?? '',
      busNumber: json['busNumber']?.toString() ?? '',
      busType: json['busType']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Premium',
      isAc: json['isAc'] == true,
      deckType: json['deckType']?.toString() ?? 'single',
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '30') ?? 30,
      amenities: (json['amenities'] is List) ? json['amenities'] as List : ['WiFi', 'Charging Point'],
      liveTrackingAvailable: json['liveTrackingAvailable'] == true,
      configuredSeats: json['configuredSeats'] is int ? json['configuredSeats'] : int.tryParse(json['configuredSeats']?.toString() ?? '0') ?? 0,
    );
  }
}

class BusSeatModel {
  final int id;
  final String seatNumber;
  final String deck;
  final int rowNum;
  final int columnNum;
  final String seatType;
  final String berthType;
  final bool isWindow;
  final bool isAisle;
  final String seatTier;
  final double price;
  final bool isActive;
  final String status;

  BusSeatModel({
    required this.id,
    required this.seatNumber,
    required this.deck,
    required this.rowNum,
    required this.columnNum,
    required this.seatType,
    required this.berthType,
    required this.isWindow,
    required this.isAisle,
    required this.seatTier,
    required this.price,
    required this.isActive,
    required this.status,
  });

  factory BusSeatModel.fromJson(Map<String, dynamic> json) {
    return BusSeatModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seatNumber: json['seatNumber']?.toString() ?? '',
      deck: json['deck']?.toString() ?? 'lower',
      rowNum: json['rowNum'] is int ? json['rowNum'] : int.tryParse(json['rowNum']?.toString() ?? '1') ?? 1,
      columnNum: json['columnNum'] is int ? json['columnNum'] : int.tryParse(json['columnNum']?.toString() ?? '1') ?? 1,
      seatType: json['seatType']?.toString() ?? 'sleeper',
      berthType: json['berthType']?.toString() ?? 'single',
      isWindow: json['isWindow'] == true,
      isAisle: json['isAisle'] == true,
      seatTier: json['seatTier']?.toString() ?? 'Standard',
      price: double.tryParse(json['price']?.toString() ?? '850') ?? 850.0,
      isActive: json['isActive'] != false,
      status: json['status']?.toString() ?? 'available',
    );
  }
}

// ==========================================
// BUS ROUTE & TRIP MODELS
// ==========================================
class BusRouteModel {
  final int id;
  final String routeCode;
  final String sourceCity;
  final String destinationCity;
  final String? sourceState;
  final String? destinationState;
  final double distanceKm;
  final int estimatedDurationMins;
  final bool isPopular;
  final int tripCount;

  BusRouteModel({
    required this.id,
    required this.routeCode,
    required this.sourceCity,
    required this.destinationCity,
    this.sourceState,
    this.destinationState,
    required this.distanceKm,
    required this.estimatedDurationMins,
    required this.isPopular,
    this.tripCount = 0,
  });

  factory BusRouteModel.fromJson(Map<String, dynamic> json) {
    return BusRouteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      routeCode: json['routeCode']?.toString() ?? '',
      sourceCity: json['sourceCity']?.toString() ?? '',
      destinationCity: json['destinationCity']?.toString() ?? '',
      sourceState: json['sourceState']?.toString(),
      destinationState: json['destinationState']?.toString(),
      distanceKm: double.tryParse(json['distanceKm']?.toString() ?? '0') ?? 0.0,
      estimatedDurationMins: json['estimatedDurationMins'] is int ? json['estimatedDurationMins'] : int.tryParse(json['estimatedDurationMins']?.toString() ?? '0') ?? 0,
      isPopular: json['isPopular'] == true,
      tripCount: json['tripCount'] is int ? json['tripCount'] : int.tryParse(json['tripCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class BusTripModel {
  final int id;
  final String tripCode;
  final int busId;
  final String busName;
  final String busNumber;
  final String busType;
  final int operatorId;
  final String operatorName;
  final String? operatorLogo;
  final int routeId;
  final String sourceCity;
  final String destinationCity;
  final String travelDate;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String departureTimeFormatted;
  final String arrivalTimeFormatted;
  final String durationFormatted;
  final double baseFare;
  final String status;
  final int totalSeats;
  final int bookingCount;
  final List<BoardingPointModel> boardingPoints;
  final List<DroppingPointModel> droppingPoints;
  final List<BusSeatModel> seats;

  BusTripModel({
    required this.id,
    required this.tripCode,
    required this.busId,
    required this.busName,
    required this.busNumber,
    required this.busType,
    required this.operatorId,
    required this.operatorName,
    this.operatorLogo,
    required this.routeId,
    required this.sourceCity,
    required this.destinationCity,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureTimeFormatted,
    required this.arrivalTimeFormatted,
    required this.durationFormatted,
    required this.baseFare,
    required this.status,
    required this.totalSeats,
    this.bookingCount = 0,
    this.boardingPoints = const [],
    this.droppingPoints = const [],
    this.seats = const [],
  });

  factory BusTripModel.fromJson(Map<String, dynamic> json) {
    var rawBp = <BoardingPointModel>[];
    if (json['boardingPoints'] is List) {
      rawBp = (json['boardingPoints'] as List).map((p) => BoardingPointModel.fromJson(p as Map<String, dynamic>)).toList();
    }
    var rawDp = <DroppingPointModel>[];
    if (json['droppingPoints'] is List) {
      rawDp = (json['droppingPoints'] as List).map((p) => DroppingPointModel.fromJson(p as Map<String, dynamic>)).toList();
    }
    var rawSeats = <BusSeatModel>[];
    if (json['seats'] is List) {
      rawSeats = (json['seats'] as List).map((s) => BusSeatModel.fromJson(s as Map<String, dynamic>)).toList();
    }

    return BusTripModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tripCode: json['tripCode']?.toString() ?? '',
      busId: json['busId'] is int ? json['busId'] : int.tryParse(json['busId']?.toString() ?? '0') ?? 0,
      busName: json['busName']?.toString() ?? '',
      busNumber: json['busNumber']?.toString() ?? '',
      busType: json['busType']?.toString() ?? '',
      operatorId: json['operatorId'] is int ? json['operatorId'] : int.tryParse(json['operatorId']?.toString() ?? '0') ?? 0,
      operatorName: json['operatorName']?.toString() ?? '',
      operatorLogo: json['operatorLogo']?.toString(),
      routeId: json['routeId'] is int ? json['routeId'] : int.tryParse(json['routeId']?.toString() ?? '0') ?? 0,
      sourceCity: json['sourceCity']?.toString() ?? '',
      destinationCity: json['destinationCity']?.toString() ?? '',
      travelDate: json['travelDate']?.toString() ?? '',
      departureTime: DateTime.tryParse(json['departureTime']?.toString() ?? '') ?? DateTime.now(),
      arrivalTime: DateTime.tryParse(json['arrivalTime']?.toString() ?? '') ?? DateTime.now(),
      departureTimeFormatted: json['departureTimeFormatted']?.toString() ?? '',
      arrivalTimeFormatted: json['arrivalTimeFormatted']?.toString() ?? '',
      durationFormatted: json['durationFormatted']?.toString() ?? '',
      baseFare: double.tryParse(json['baseFare']?.toString() ?? '850') ?? 850.0,
      status: json['status']?.toString() ?? 'scheduled',
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '30') ?? 30,
      bookingCount: json['bookingCount'] is int ? json['bookingCount'] : int.tryParse(json['bookingCount']?.toString() ?? '0') ?? 0,
      boardingPoints: rawBp,
      droppingPoints: rawDp,
      seats: rawSeats,
    );
  }
}

class BoardingPointModel {
  final int id;
  final String pointName;
  final String? landmark;
  final String? address;
  final String? contactNumber;
  final String departureTime;
  final String timeFormatted;
  final int displayOrder;

  BoardingPointModel({
    required this.id,
    required this.pointName,
    this.landmark,
    this.address,
    this.contactNumber,
    required this.departureTime,
    required this.timeFormatted,
    required this.displayOrder,
  });

  factory BoardingPointModel.fromJson(Map<String, dynamic> json) {
    return BoardingPointModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      pointName: json['pointName']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      address: json['address']?.toString(),
      contactNumber: json['contactNumber']?.toString(),
      departureTime: json['departureTime']?.toString() ?? '',
      timeFormatted: json['timeFormatted']?.toString() ?? '',
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : int.tryParse(json['displayOrder']?.toString() ?? '1') ?? 1,
    );
  }
}

class DroppingPointModel {
  final int id;
  final String pointName;
  final String? landmark;
  final String? address;
  final String? contactNumber;
  final String arrivalTime;
  final String timeFormatted;
  final int displayOrder;

  DroppingPointModel({
    required this.id,
    required this.pointName,
    this.landmark,
    this.address,
    this.contactNumber,
    required this.arrivalTime,
    required this.timeFormatted,
    required this.displayOrder,
  });

  factory DroppingPointModel.fromJson(Map<String, dynamic> json) {
    return DroppingPointModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      pointName: json['pointName']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      address: json['address']?.toString(),
      contactNumber: json['contactNumber']?.toString(),
      arrivalTime: json['arrivalTime']?.toString() ?? '',
      timeFormatted: json['timeFormatted']?.toString() ?? '',
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : int.tryParse(json['displayOrder']?.toString() ?? '1') ?? 1,
    );
  }
}

// ==========================================
// BOOKING MODELS
// ==========================================
class MovieBookingModel {
  final int id;
  final String bookingCode;
  final int userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final int showId;
  final String movieTitle;
  final String? movieImage;
  final String theaterName;
  final String screenName;
  final String showTimeFormatted;
  final int totalSeats;
  final double ticketAmount;
  final double convenienceFee;
  final double totalAmount;
  final String paymentStatus;
  final String bookingStatus;
  final String? qrCodeData;
  final DateTime createdAt;
  final List<dynamic> seats;

  MovieBookingModel({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.showId,
    required this.movieTitle,
    this.movieImage,
    required this.theaterName,
    required this.screenName,
    required this.showTimeFormatted,
    required this.totalSeats,
    required this.ticketAmount,
    required this.convenienceFee,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    this.qrCodeData,
    required this.createdAt,
    this.seats = const [],
  });

  List<String> get seatNumbers {
    return seats.map((s) {
      if (s is Map) return (s['seatIdentifier'] ?? s['seatNumber'] ?? '').toString();
      return s.toString();
    }).toList();
  }

  double get basePrice => ticketAmount;
  double get taxAmount => (totalAmount - ticketAmount - convenienceFee > 0) ? (totalAmount - ticketAmount - convenienceFee) : 0.0;
  String get showDate => showTimeFormatted.contains(',') ? showTimeFormatted.split(',').first : showTimeFormatted;

  factory MovieBookingModel.fromJson(Map<String, dynamic> json) {
    return MovieBookingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      bookingCode: json['bookingCode']?.toString() ?? '',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      userPhone: json['userPhone']?.toString(),
      showId: json['showId'] is int ? json['showId'] : int.tryParse(json['showId']?.toString() ?? '0') ?? 0,
      movieTitle: json['movieTitle']?.toString() ?? '',
      movieImage: json['movieImage']?.toString(),
      theaterName: json['theaterName']?.toString() ?? '',
      screenName: json['screenName']?.toString() ?? '',
      showTimeFormatted: json['showTimeFormatted']?.toString() ?? '',
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '1') ?? 1,
      ticketAmount: double.tryParse(json['ticketAmount']?.toString() ?? '0') ?? 0.0,
      convenienceFee: double.tryParse(json['convenienceFee']?.toString() ?? '35.4') ?? 35.4,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'completed',
      bookingStatus: json['bookingStatus']?.toString() ?? 'confirmed',
      qrCodeData: json['qrCodeData']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      seats: (json['seats'] is List) ? json['seats'] as List : [],
    );
  }
}

class BusBookingModel {
  final int id;
  final String bookingCode;
  final String pnrNumber;
  final int userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final int tripId;
  final String busName;
  final String busNumber;
  final String busType;
  final String operatorName;
  final String sourceCity;
  final String destinationCity;
  final String travelDate;
  final String departureTimeFormatted;
  final String arrivalTimeFormatted;
  final int totalSeats;
  final double baseFare;
  final double convenienceFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime createdAt;
  final List<dynamic> passengers;

  BusBookingModel({
    required this.id,
    required this.bookingCode,
    required this.pnrNumber,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.tripId,
    required this.busName,
    required this.busNumber,
    required this.busType,
    this.operatorName = 'InterCity Bus',
    required this.sourceCity,
    required this.destinationCity,
    required this.travelDate,
    required this.departureTimeFormatted,
    required this.arrivalTimeFormatted,
    required this.totalSeats,
    required this.baseFare,
    required this.convenienceFee,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
    this.passengers = const [],
  });

  factory BusBookingModel.fromJson(Map<String, dynamic> json) {
    return BusBookingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      bookingCode: json['bookingCode']?.toString() ?? '',
      pnrNumber: json['pnrNumber']?.toString() ?? '',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      userPhone: json['userPhone']?.toString(),
      tripId: json['tripId'] is int ? json['tripId'] : int.tryParse(json['tripId']?.toString() ?? '0') ?? 0,
      busName: json['busName']?.toString() ?? '',
      busNumber: json['busNumber']?.toString() ?? '',
      busType: json['busType']?.toString() ?? '',
      operatorName: json['operatorName']?.toString() ?? 'InterCity Bus',
      sourceCity: json['sourceCity']?.toString() ?? '',
      destinationCity: json['destinationCity']?.toString() ?? '',
      travelDate: json['travelDate']?.toString() ?? '',
      departureTimeFormatted: json['departureTimeFormatted']?.toString() ?? '',
      arrivalTimeFormatted: json['arrivalTimeFormatted']?.toString() ?? '',
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '1') ?? 1,
      baseFare: double.tryParse(json['baseFare']?.toString() ?? '0') ?? 0.0,
      convenienceFee: double.tryParse(json['convenienceFee']?.toString() ?? '25') ?? 25.0,
      taxAmount: double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'completed',
      bookingStatus: json['bookingStatus']?.toString() ?? 'confirmed',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      passengers: (json['passengers'] is List) ? json['passengers'] as List : [],
    );
  }
}

// ==========================================
// PAYMENT & REFUND MODELS
// ==========================================
class PaymentModel {
  final String paymentId;
  final String? bookingCode;
  final int? bookingId;
  final int userId;
  final String userName;
  final String userEmail;
  final double amount;
  final String paymentMethod;
  final String status;
  final String transactionReference;
  final DateTime createdAt;
  final String bookingType; // 'movie' or 'bus'

  PaymentModel({
    required this.paymentId,
    this.bookingCode,
    this.bookingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionReference,
    required this.createdAt,
    required this.bookingType,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString(),
      bookingId: json['bookingId'] is int ? json['bookingId'] : int.tryParse(json['bookingId']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'UPI',
      status: json['status']?.toString() ?? 'completed',
      transactionReference: json['transactionReference']?.toString() ?? 'N/A',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      bookingType: json['bookingType']?.toString() ?? 'movie',
    );
  }
}

class RefundModel {
  final String refundId;
  final String? bookingCode;
  final int? bookingId;
  final int userId;
  final String userName;
  final String userEmail;
  final double refundAmount;
  final String refundMethod;
  final String refundStatus;
  final DateTime createdAt;
  final String bookingType;

  RefundModel({
    required this.refundId,
    this.bookingCode,
    this.bookingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.refundAmount,
    required this.refundMethod,
    required this.refundStatus,
    required this.createdAt,
    required this.bookingType,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      refundId: json['refundId']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString(),
      bookingId: json['bookingId'] is int ? json['bookingId'] : int.tryParse(json['bookingId']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      refundAmount: double.tryParse(json['refundAmount']?.toString() ?? '0') ?? 0.0,
      refundMethod: json['refundMethod']?.toString() ?? 'original_source',
      refundStatus: json['refundStatus']?.toString() ?? 'completed',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      bookingType: json['bookingType']?.toString() ?? 'movie',
    );
  }
}

// ==========================================
// AUDIT LOG MODEL
// ==========================================
class AuditLogModel {
  final int id;
  final int? adminId;
  final String? adminEmail;
  final String action;
  final String entityType;
  final String? entityId;
  final dynamic details;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    this.adminId,
    this.adminEmail,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      adminId: json['adminId'] is int ? json['adminId'] : int.tryParse(json['adminId']?.toString() ?? ''),
      adminEmail: json['adminEmail']?.toString(),
      action: json['action']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString(),
      details: json['details'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================
// DASHBOARD STATS MODEL
// ==========================================
class DashboardStatsModel {
  final int totalUsers;
  final int activeUsers;
  final int totalMovieBookings;
  final int totalBusBookings;
  final int todayBookings;
  final int upcomingShows;
  final int upcomingBusTrips;
  final double totalRevenue;
  final double movieRevenue;
  final double busRevenue;
  final int cancelledBookings;
  final int pendingPayments;
  final int activeSeatHolds;
  final List<dynamic> revenueTrend;
  final List<dynamic> recentActivity;

  DashboardStatsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalMovieBookings,
    required this.totalBusBookings,
    required this.todayBookings,
    required this.upcomingShows,
    required this.upcomingBusTrips,
    required this.totalRevenue,
    required this.movieRevenue,
    required this.busRevenue,
    required this.cancelledBookings,
    required this.pendingPayments,
    required this.activeSeatHolds,
    required this.revenueTrend,
    required this.recentActivity,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final kpis = (json['kpis'] as Map<String, dynamic>?) ?? {};
    return DashboardStatsModel(
      totalUsers: kpis['totalUsers'] ?? 0,
      activeUsers: kpis['activeUsers'] ?? 0,
      totalMovieBookings: kpis['totalMovieBookings'] ?? 0,
      totalBusBookings: kpis['totalBusBookings'] ?? 0,
      todayBookings: kpis['todayBookings'] ?? 0,
      upcomingShows: kpis['upcomingShows'] ?? 0,
      upcomingBusTrips: kpis['upcomingBusTrips'] ?? 0,
      totalRevenue: double.tryParse(kpis['totalRevenue']?.toString() ?? '0') ?? 0.0,
      movieRevenue: double.tryParse(kpis['movieRevenue']?.toString() ?? '0') ?? 0.0,
      busRevenue: double.tryParse(kpis['busRevenue']?.toString() ?? '0') ?? 0.0,
      cancelledBookings: kpis['cancelledBookings'] ?? 0,
      pendingPayments: kpis['pendingPayments'] ?? 0,
      activeSeatHolds: kpis['activeSeatHolds'] ?? 0,
      revenueTrend: (json['revenueTrend'] is List) ? json['revenueTrend'] as List : [],
      recentActivity: (json['recentActivity'] is List) ? json['recentActivity'] as List : [],
    );
  }
}
