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
      normalMin: json['normal_min'].toDouble(),
      normalMax: json['normal_max'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'normal_min': normalMin,
      'normal_max': normalMax,
    };
  }
} 