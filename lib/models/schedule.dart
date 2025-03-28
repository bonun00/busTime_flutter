class Schedule {
  final String departureTime;
  final String arrivalTime;
  final String busNumber;

  Schedule({
    required this.departureTime,
    required this.arrivalTime,
    required this.busNumber,
  });

  // JSON 변환 메서드
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      departureTime: json['departureTime'] ?? '--:--',
      arrivalTime: json['arrivalTime'] ?? '--:--',
      busNumber: json['busNumber'] ?? '-',
    );
  }

  // Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'busNumber': busNumber,
    };
  }
}