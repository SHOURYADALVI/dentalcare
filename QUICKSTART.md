# Quick Start Guide - Dental Clinic App

## Initial Setup

### 1. Create Flutter Project (If Starting Fresh)
```bash
flutter create dental_clinic_app
cd dental_clinic_app
```

### 2. Add Dependencies
All dependencies are configured in `pubspec.yaml`:
```yaml
flutter_riverpod: ^2.4.0
go_router: ^13.0.0
fl_chart: ^0.64.0
table_calendar: ^3.0.9
intl: ^0.19.0
uuid: ^4.0.0
```

### 3. Get Packages
```bash
flutter pub get
```

## Running the App

### Development Mode
```bash
flutter run
```

### Web Platforms
```bash
flutter run -d chrome
flutter run -d web
```

### Android
```bash
flutter run -d emulator-5554
```

### iOS
```bash
flutter run -d iphone
```

## Login & Navigation

### Demo Credentials

#### Admin Login
- **Email**: admin@dental.com
- **Password**: any value
- **Access**: All features including dashboard analytics

#### Dentist Login
- **Email**: dentist@dental.com
- **Password**: any value
- **Access**: View appointments, treatments, patient details

#### Receptionist Login
- **Email**: receptionist@dental.com
- **Password**: any value
- **Access**: Patient management, appointment booking

## Feature Walkthrough

### 1. Patient Management
**Path**: `/patients`

**Features**:
- View all patients
- Search patients by name or phone
- Click patient card to view details
- Edit patient information
- Delete patient record
- Add new patient with form validation

**Key Pages**:
- `patients_list_page.dart` - Patient list with search
- `patient_detail_page.dart` - Detailed patient profile
- `add_edit_patient_page.dart` - Patient form

### 2. Appointments
**Path**: `/appointments`

**Features**:
- Calendar-based appointment view
- Select date to see appointments
- Create new appointment with form
- Automatic double-booking prevention
- Status management

**Key Pages**:
- `appointments_page.dart` - Calendar and appointment list

### 3. Treatments
**Path**: `/treatments`

**Features**:
- Record new treatments
- Track diagnosis and procedures
- Record treatment costs
- View all treatments

**Key Pages**:
- `treatments_page.dart` - Treatment list and form

### 4. Billing
**Path**: `/billing`

**Features**:
- View all invoices
- Track payment status
- Mark payments as paid
- See total revenue

**Key Pages**:
- `billing_page.dart` - Invoice list and revenue

### 5. Dashboard
**Path**: `/dashboard`

**Features**:
- Total patients count
- Today's appointments count
- Total revenue display
- Revenue visualization with chart
- Quick action buttons

**Key Pages**:
- `dashboard_page.dart` - Main dashboard

## Code Organization

### Adding a New Patient (Example Flow)

1. **Navigate to Add Patient**
   ```dart
   context.pushNamed('add-patient');
   ```

2. **Form Submission Triggers**
   ```dart
   // In AddEditPatientPage
   await ref.read(addPatientProvider(patient).future);
   ```

3. **Provider Invalidation**
   ```dart
   // Automatically refetch patient list
   ref.invalidate(patientsProvider);
   ```

4. **Navigate Back**
   ```dart
   if (mounted) context.pop();
   ```

### Accessing Patient Data (Example)

```dart
// In a ConsumerWidget
final patientsAsync = ref.watch(patientsProvider);

patientsAsync.when(
  data: (patients) => // Display patients
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## Customization Guide

### Changing Theme Colors

Edit `lib/core/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF0066CC); // Change this
static const Color accentColor = Color(0xFF00BCD4);
static const Color successColor = Color(0xFF27AE60);
```

### Adding New Routes

Edit `lib/core/router.dart`:
```dart
GoRoute(
  path: '/new-feature',
  name: 'new-feature',
  builder: (context, state) => const NewFeaturePage(),
),
```

### Creating New Provider

Create file: `lib/core/providers/new_providers.dart`:
```dart
final newDataProvider = FutureProvider<List<Data>>((ref) async {
  final service = ref.watch(newServiceProvider);
  return service.getData();
});
```

### Adding New Service

Create file: `lib/services/new_service.dart`:
```dart
class NewService {
  Future<List<Data>> getData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockData;
  }
}
```

## Common Tasks

### Access Current User Info
```dart
final currentUser = ref.watch(currentUserProvider);
print(currentUser?.role.displayName);
```

### Search Patients
```dart
final searchResults = ref.watch(searchPatientsProvider('John'));
```

### Get Patient Appointments
```dart
final appointments = ref.watch(getPatientAppointmentsProvider(patientId));
```

### Invalidate Cache
```dart
ref.invalidate(patientsProvider);
// or
ref.refresh(patientsProvider);
```

## Debugging Tips

### Enable Debug Logging
```dart
// In main.dart
void main() {
  runApp(
    ProviderContainer(
      observers: [MyObserver()],
      child: const DentalClinicApp(),
    ),
  );
}
```

### Check Provider State
```dart
// In ConsumerState or ConsumerWidget
debugPrint('Provider value: ${ref.watch(patientsProvider)}');
```

### Log Route Changes
```dart
// In router configuration
navigatorObservers: [
  GoRouterObserver(),
],
```

## Performance Tips

1. **Use `select()` to watch specific fields**
   ```dart
   final patientName = ref.watch(
     selectedPatientProvider.select((patient) => patient?.name)
   );
   ```

2. **Cache expensive operations**
   ```dart
   final cachedData = ref.watch(expensiveProvider);
   ```

3. **Avoid rebuilds with `.` operator**
   ```dart
   // Good - only rebuilds when patientsProvider changes
   final patients = ref.watch(patientsProvider);
   
   // Avoid - rebuilds on every watch
   ref.watch(patientsProvider).when(...)
   ```

## Troubleshooting

### Hot Reload Not Working
```bash
flutter clean
flutter pub get
flutter run
```

### Providers Not Updating
```dart
// Force refresh
ref.refresh(yourProvider);

// Instead of invalidate when you need immediate update
ref.invalidate(yourProvider);
```

### Build Errors
```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk  # or ios
```

### Package Version Conflicts
```bash
flutter pub get --no-offline
flutter pub upgrade
```

## File Size Reference

- `main.dart` - ~50 lines
- `models/` - ~400 lines total
- `services/` - ~500 lines total
- `core/providers/` - ~300 lines total
- `features/` - ~1500+ lines total
- `widgets/` - ~400 lines total

## Project Statistics

| Category | Count |
|----------|-------|
| Dart Files | 27 |
| Widget Classes | 15+ |
| Providers | 10+ |
| Models | 6 |
| Services | 4 |
| Features | 6 |
| Configuration Files | 3 |

## Next Steps

1. **Build the project**
   ```bash
   flutter build apk
   flutter build ios
   flutter build web
   ```

2. **Run tests** (when implemented)
   ```bash
   flutter test
   ```

3. **Connect backend API**
   - Update services to use HTTP instead of mock data
   - Implement proper authentication
   - Add real database integration

4. **Customize for your clinic**
   - Update colors and branding
   - Modify patient form fields
   - Add clinic-specific features

## Support Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Material Design](https://material.io/design)

---

**Happy Coding! 🚀**
