

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

class JournalEntry {
  final String id;
  final String countryCode;
  final String? city;
  final DateTime date;
  final String? title;
  final String note;
  final List<String> photoUrls;

  JournalEntry({
    required this.id,
    required this.countryCode,
    this.city,
    required this.date,
    this.title,
    this.note = '',
    this.photoUrls = const [],
  });

  JournalEntry copyWith({
    String? id,
    String? countryCode,
    String? city,
    DateTime? date,
    String? title,
    String? note,
    List<String>? photoUrls,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      date: date ?? this.date,
      title: title ?? this.title,
      note: note ?? this.note,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'city': city,
      'date': date.millisecondsSinceEpoch,
      'title': title,
      'note': note,
      'photoUrls': photoUrls,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      countryCode: json['countryCode'] as String,
      city: json['city'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      title: json['title'] as String?,
      note: json['note'] as String? ?? '',
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
