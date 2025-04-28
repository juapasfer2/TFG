class Threshold {
  final int id;
  final int typeId;
  final double minValue;
  final double maxValue;

  Threshold({
    required this.id,
    required this.typeId,
    required this.minValue,
    required this.maxValue,
  });

  factory Threshold.fromJson(Map<String, dynamic> json) {
    return Threshold(
      id: json['id'],
      typeId: json['type_id'],
      minValue: json['min_value'].toDouble(),
      maxValue: json['max_value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_id': typeId,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }
} 