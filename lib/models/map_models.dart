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
  
  UserCountryData({
    required this.code,
    this.status = CountryStatus.none,
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status.index,
      'date': date?.millisecondsSinceEpoch,
    };
  }

  factory UserCountryData.fromJson(Map<String, dynamic> json) {
    return UserCountryData(
      code: json['code'] as String,
      status: CountryStatus.values[json['status'] as int? ?? 0],
      date: json['date'] != null ? DateTime.fromMillisecondsSinceEpoch(json['date'] as int) : null,
    );
  }
}

