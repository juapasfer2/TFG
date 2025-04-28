class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String medicalRecordNumber;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.medicalRecordNumber,
  });

  String get fullName => '$firstName $lastName';

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      medicalRecordNumber: json['medical_record_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'medical_record_number': medicalRecordNumber,
    };
  }
} 