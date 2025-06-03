class ThresholdResponse {
  final int id;
  final int typeId;
  final String typeName;
  final double minValue;
  final double maxValue;
  final String level;
  final String description;

  ThresholdResponse({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.minValue,
    required this.maxValue,
    required this.level,
    required this.description,
  });

  factory ThresholdResponse.fromJson(Map<String, dynamic> json) {
    return ThresholdResponse(
      id: json['id'],
      typeId: json['typeId'],
      typeName: json['typeName'],
      minValue: json['minValue'].toDouble(),
      maxValue: json['maxValue'].toDouble(),
      level: json['level'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeId': typeId,
      'typeName': typeName,
      'minValue': minValue,
      'maxValue': maxValue,
      'level': level,
      'description': description,
    };
  }
}

class ThresholdRequest {
  final int typeId;
  final double minValue;
  final double maxValue;
  final String level;
  final String description;

  ThresholdRequest({
    required this.typeId,
    required this.minValue,
    required this.maxValue,
    required this.level,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'typeId': typeId,
      'minValue': minValue,
      'maxValue': maxValue,
      'level': level,
      'description': description,
    };
  }
} 