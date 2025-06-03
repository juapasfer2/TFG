class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String medicalRecordNumber;
  final List<int>? nurseIds;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.medicalRecordNumber,
    this.nurseIds,
  });

  String get fullName => '$firstName $lastName';

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      medicalRecordNumber: json['medicalRecordNumber'],
      nurseIds: json['nurseIds'] != null ? List<int>.from(json['nurseIds']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'medicalRecordNumber': medicalRecordNumber,
      if (nurseIds != null) 'nurseIds': nurseIds,
    };
  }
}

class PatientResponse {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String medicalRecordNumber;
  final List<int>? nurseIds;

  PatientResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.medicalRecordNumber,
    this.nurseIds,
  });

  String get fullName => '$firstName $lastName';

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      medicalRecordNumber: json['medicalRecordNumber'],
      nurseIds: json['nurseIds'] != null ? List<int>.from(json['nurseIds']) : null,
    );
  }

  Patient toPatient() {
    return Patient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      medicalRecordNumber: medicalRecordNumber,
      nurseIds: nurseIds,
    );
  }
}

class PatientRequest {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String medicalRecordNumber;

  PatientRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.medicalRecordNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'medicalRecordNumber': medicalRecordNumber,
    };
  }
} 