import '../models/patient.dart';

/// Mock patient data repository service
class PatientService {
  static final PatientService _instance = PatientService._internal();

  factory PatientService() {
    return _instance;
  }

  PatientService._internal();

  // In-memory storage for mock data
  final List<Patient> _patients = [
    Patient(
      id: 'patient-001',
      name: 'John Doe',
      phone: '+1-234-567-8900',
      age: 35,
      gender: 'Male',
      medicalHistory: 'No major allergies, previous cavities treated',
      address: '123 Main St, New York, NY 10001',
      email: 'john.doe@email.com',
      emergencyContact: '+1-234-567-8901',
    ),
    Patient(
      id: 'patient-002',
      name: 'Jane Smith',
      phone: '+1-234-567-8902',
      age: 28,
      gender: 'Female',
      medicalHistory: 'Sensitive teeth, regular checkups',
      address: '456 Oak Ave, Brooklyn, NY 11201',
      email: 'jane.smith@email.com',
      emergencyContact: '+1-234-567-8903',
    ),
    Patient(
      id: 'patient-003',
      name: 'Michael Johnson',
      phone: '+1-234-567-8904',
      age: 45,
      gender: 'Male',
      medicalHistory: 'Hypertension, takes blood pressure medication',
      address: '789 Pine Rd, Queens, NY 11375',
      email: 'michael.johnson@email.com',
      emergencyContact: '+1-234-567-8905',
    ),
  ];

  /// Get all patients
  Future<List<Patient>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _patients;
  }

  /// Get patient by ID
  Future<Patient?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get patients by name (search)
  Future<List<Patient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _patients;
    return _patients
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.phone.contains(query))
        .toList();
  }

  /// Add new patient
  Future<Patient> addPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _patients.add(patient);
    return patient;
  }

  /// Update patient
  Future<Patient> updatePatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient.copyWith(updatedAt: DateTime.now());
      return _patients[index];
    }
    throw Exception('Patient not found');
  }

  /// Delete patient
  Future<void> deletePatient(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _patients.removeWhere((p) => p.id == id);
  }

  /// Get total patient count
  Future<int> getPatientCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _patients.length;
  }
}
