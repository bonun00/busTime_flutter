class BusFavorite {
  final String id; // 고유 식별자
  final String departure;
  final String arrival;
  final String routeType; // chilwon 또는 masan
  final String busNumber; // 선택적
  final DateTime addedAt;

  BusFavorite({
    required this.id,
    required this.departure,
    required this.arrival,
    required this.routeType,
    this.busNumber = '',
    DateTime? addedAt,
  }) : this.addedAt = addedAt ?? DateTime.now();

  // JSON 직렬화/역직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'departure': departure,
    'arrival': arrival,
    'routeType': routeType,
    'busNumber': busNumber,
    'addedAt': addedAt.toIso8601String(),
  };

  factory BusFavorite.fromJson(Map<String, dynamic> json) => BusFavorite(
    id: json['id'],
    departure: json['departure'],
    arrival: json['arrival'],
    routeType: json['routeType'],
    busNumber: json['busNumber'] ?? '',
    addedAt: DateTime.parse(json['addedAt']),
  );
}