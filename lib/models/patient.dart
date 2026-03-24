import 'package:uuid/uuid.dart';

/// Patient model represents a dental clinic patient
class Patient {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String gender; // Male, Female, Other
  final String medicalHistory;
  final double? totalAmount;
  final double? paidAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;
  final String? email;
  final String? emergencyContact;

  Patient({
    String? id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    this.totalAmount,
    this.paidAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.address,
    this.email,
    this.emergencyContact,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get dentalIssue => medicalHistory;
  double get remainingAmount =>
      (totalAmount ?? 0) - (paidAmount ?? 0);

  /// Create a copy of patient with modified fields
  Patient copyWith({
    String? id,
    String? name,
    String? phone,
    int? age,
    String? gender,
    String? medicalHistory,
    double? totalAmount,
    double? paidAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    String? email,
    String? emergencyContact,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, phone: $phone, age: $age, gender: $gender)';
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      age: (json['age'] ?? 0) as int,
      gender: (json['gender'] ?? 'Other') as String,
      medicalHistory: (json['medicalHistory'] ?? json['dentalIssue'] ?? '') as String,
        totalAmount: (json['totalAmount'] as num?)?.toDouble(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      address: json['address'] as String?,
      email: json['email'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'medicalHistory': medicalHistory,
      'dentalIssue': medicalHistory,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'address': address,
      'email': email,
      'emergencyContact': emergencyContact,
    };
  }
}
