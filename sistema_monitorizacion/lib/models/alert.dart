class Alert {
  final int id;
  final int readingId;
  final String level;
  final DateTime timestamp;
  final bool acknowledged;
  final int? acknowledgedBy;

  Alert({
    required this.id,
    required this.readingId,
    required this.level,
    required this.timestamp,
    required this.acknowledged,
    this.acknowledgedBy,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      readingId: json['reading_id'],
      level: json['level'],
      timestamp: DateTime.parse(json['timestamp']),
      acknowledged: json['acknowledged'],
      acknowledgedBy: json['acknowledged_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reading_id': readingId,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'acknowledged': acknowledged,
      'acknowledged_by': acknowledgedBy,
    };
  }
} 