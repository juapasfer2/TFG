class VitalReading {
  final int id;
  final int patientId;
  final int typeId;
  final double value;
  final DateTime timestamp;

  VitalReading({
    required this.id,
    required this.patientId,
    required this.typeId,
    required this.value,
    required this.timestamp,
  });

  factory VitalReading.fromJson(Map<String, dynamic> json) {
    return VitalReading(
      id: json['id'],
      patientId: json['patient_id'],
      typeId: json['type_id'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'type_id': typeId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 