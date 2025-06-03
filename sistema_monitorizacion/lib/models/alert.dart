class Alert {
  final int id;
  final int readingId;
  final String level;
  final DateTime timestamp;
  final bool acknowledged;
  final int? acknowledgedBy;
  final String? patientName;
  final String? vitalTypeName;
  final double? vitalValue;

  Alert({
    required this.id,
    required this.readingId,
    required this.level,
    required this.timestamp,
    required this.acknowledged,
    this.acknowledgedBy,
    this.patientName,
    this.vitalTypeName,
    this.vitalValue,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      readingId: json['readingId'],
      level: json['level'],
      timestamp: DateTime.parse(json['timestamp']),
      acknowledged: json['acknowledged'],
      acknowledgedBy: json['acknowledgedBy'],
      patientName: json['patientName'],
      vitalTypeName: json['vitalTypeName'],
      vitalValue: json['vitalValue']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'readingId': readingId,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'acknowledged': acknowledged,
      'acknowledgedBy': acknowledgedBy,
      if (patientName != null) 'patientName': patientName,
      if (vitalTypeName != null) 'vitalTypeName': vitalTypeName,
      if (vitalValue != null) 'vitalValue': vitalValue,
    };
  }
} 