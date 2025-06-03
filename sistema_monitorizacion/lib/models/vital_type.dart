class VitalType {
  final int id;
  final String name;
  final String unit;
  final double normalMin;
  final double normalMax;

  VitalType({
    required this.id,
    required this.name,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
  });

  factory VitalType.fromJson(Map<String, dynamic> json) {
    return VitalType(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      normalMin: json['normalMin'].toDouble(),
      normalMax: json['normalMax'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'normalMin': normalMin,
      'normalMax': normalMax,
    };
  }
}

class VitalTypeRequest {
  final String name;
  final String unit;
  final double normalMin;
  final double normalMax;

  VitalTypeRequest({
    required this.name,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'normalMin': normalMin,
      'normalMax': normalMax,
    };
  }
} 