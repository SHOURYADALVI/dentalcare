class DoctorProfile {
  final String id;
  final String name;
  final String qualification;
  final String specialization;
  final String phone;
  final String email;
  final String clinicAddress;
  final String? avatarAsset;

  const DoctorProfile({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.phone,
    required this.email,
    required this.clinicAddress,
    this.avatarAsset,
  });

  DoctorProfile copyWith({
    String? id,
    String? name,
    String? qualification,
    String? specialization,
    String? phone,
    String? email,
    String? clinicAddress,
    String? avatarAsset,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      qualification: (json['qualification'] ?? '') as String,
      specialization: (json['specialization'] ?? 'Dentist') as String,
      phone: (json['phone'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      clinicAddress: (json['clinicAddress'] ?? '') as String,
      avatarAsset: json['avatarAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qualification': qualification,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'clinicAddress': clinicAddress,
      'avatarAsset': avatarAsset,
    };
  }
}
