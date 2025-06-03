class VitalReading {
  final int id;
  final int patientId;
  final int typeId;
  final double value;
  final DateTime timestamp;
  final String? typeName;
  final String? unit;

  VitalReading({
    required this.id,
    required this.patientId,
    required this.typeId,
    required this.value,
    required this.timestamp,
    this.typeName,
    this.unit,
  });

  factory VitalReading.fromJson(Map<String, dynamic> json) {
    return VitalReading(
      id: json['id'],
      patientId: json['patientId'],
      typeId: json['typeId'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      typeName: json['typeName'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'typeId': typeId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      if (typeName != null) 'typeName': typeName,
      if (unit != null) 'unit': unit,
    };
  }
}

class VitalReadingRequest {
  final int patientId;
  final int typeId;
  final double value;
  final DateTime? timestamp;

  VitalReadingRequest({
    required this.patientId,
    required this.typeId,
    required this.value,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'typeId': typeId,
      'value': value,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    };
  }
} 