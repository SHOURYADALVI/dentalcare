import '../core/config/doctor_profile_config.dart';
import '../models/doctor_profile.dart';

class DoctorService {
  static final DoctorService _instance = DoctorService._internal();

  factory DoctorService() {
    return _instance;
  }

  DoctorService._internal();

  Future<DoctorProfile> getDoctorProfile() async {
    // Async wrapper keeps this integration-ready for Supabase APIs.
    await Future.delayed(const Duration(milliseconds: 300));
    return doctorProfileConfig;
  }
}
