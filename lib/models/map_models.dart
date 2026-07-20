import 'dart:ui';

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
  
  UserCountryData({
    required this.code,
    this.status = CountryStatus.none,
    this.date,
    this.cities = const [],
  });

  UserCountryData copyWith({
    String? code,
    CountryStatus? status,
    DateTime? date,
    List<String>? cities,
  }) {
    return UserCountryData(
      code: code ?? this.code,
      status: status ?? this.status,
      date: date ?? this.date,
      cities: cities ?? this.cities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status.index,
      'date': date?.millisecondsSinceEpoch,
      'cities': cities,
    };
  }

  factory UserCountryData.fromJson(Map<String, dynamic> json) {
    return UserCountryData(
      code: json['code'] as String,
      status: CountryStatus.values[json['status'] as int? ?? 0],
      date: json['date'] != null ? DateTime.fromMillisecondsSinceEpoch(json['date'] as int) : null,
      cities: (json['cities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

