

enum CountryStatus {
  none,
  visited,
  lived,
  wishlist,
  redlist,
}

class UserCountryData {
  final String code;
  final CountryStatus status;
  final DateTime? date;
  final List<String> cities;
  final String? notes;
  final List<String> photos;
  
  UserCountryData({
    required this.code,
    this.status = CountryStatus.none,
    this.date,
    this.cities = const [],
    this.notes,
    this.photos = const [],
  });

  UserCountryData copyWith({
    String? code,
    CountryStatus? status,
    DateTime? date,
    List<String>? cities,
    String? notes,
    List<String>? photos,
  }) {
    return UserCountryData(
      code: code ?? this.code,
      status: status ?? this.status,
      date: date ?? this.date,
      cities: cities ?? this.cities,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status.index,
      'date': date?.millisecondsSinceEpoch,
      'cities': cities,
      'notes': notes,
      'photos': photos,
    };
  }

  factory UserCountryData.fromJson(Map<String, dynamic> json) {
    return UserCountryData(
      code: json['code'] as String,
      status: CountryStatus.values[json['status'] as int? ?? 0],
      date: json['date'] != null ? DateTime.fromMillisecondsSinceEpoch(json['date'] as int) : null,
      cities: (json['cities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      notes: json['notes'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

