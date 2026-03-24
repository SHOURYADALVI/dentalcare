# Smart Dental Clinic Management App

A production-level Flutter application for managing dental clinic operations with clean architecture, featuring patient management, appointment scheduling, treatment records, and billing.

## Features

### 🔐 Authentication
- Role-based login (Admin, Dentist, Receptionist)
- Mock authentication with demo credentials
- Role-based navigation and access control

### 👥 Patient Management
- Complete CRUD operations for patients
- Search and filter functionality
- Detailed patient profiles with medical history
- Emergency contact information
- Patient-specific appointments and treatments

### 📅 Appointment System
- Calendar-based appointment booking
- Available time slot detection
- Prevent double booking
- Appointment status tracking (Scheduled, Completed, Cancelled)
- Today's appointment overview

### 🏥 Treatment Records
- Record treatment procedures and diagnosis
- Cost tracking per treatment
- Treatment notes and dentist assignment
- Treatment history per patient

### 💰 Billing & Revenue
- Invoice generation
- Payment status tracking (Pending, Paid, Overdue)
- Total revenue calculation
- Revenue reports and analytics

### 📊 Dashboard
- Key metrics overview (Total patients, Today's appointments, Revenue)
- Revenue visualization with charts
- Quick action buttons
- Role-based dashboard view

## Architecture

### Clean Architecture Principles
```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── router.dart                   # Go Router configuration
│   ├── theme.dart                    # Theme and styling
│   └── providers/                    # Riverpod providers
│       ├── auth_providers.dart
│       ├── patient_providers.dart
│       ├── appointment_providers.dart
│       └── treatment_providers.dart
├── models/                            # Data models
│   ├── patient.dart
│   ├── appointment.dart
│   ├── treatment.dart
│   ├── invoice.dart
│   ├── user.dart
│   └── user_role.dart
├── services/                          # Business logic (Mock data)
│   ├── auth_service.dart
│   ├── patient_service.dart
│   ├── appointment_service.dart
│   └── treatment_service.dart
├── features/                          # Feature modules
│   ├── auth/
│   │   └── presentation/pages/
│   │       └── login_page.dart
│   ├── patients/
│   │   └── presentation/pages/
│   │       ├── patients_list_page.dart
│   │       ├── patient_detail_page.dart
│   │       └── add_edit_patient_page.dart
│   ├── appointments/
│   │   └── presentation/pages/
│   │       └── appointments_page.dart
│   ├── treatments/
│   │   └── presentation/pages/
│   │       └── treatments_page.dart
│   ├── billing/
│   │   └── presentation/pages/
│   │       └── billing_page.dart
│   └── dashboard/
│       └── presentation/pages/
│           └── dashboard_page.dart
└── widgets/                           # Reusable components
    ├── buttons.dart
    ├── cards.dart
    └── form_fields.dart
```

## State Management

- **Riverpod** for reactive state management
- Provider-based data fetching
- Automatic invalidation and refetching
- Clear separation of concerns

## UI/UX

- **Material 3** design system
- Professional medical theme (Blue + White)
- Responsive layouts
- Consistent styling across the app
- Form validation and error handling

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DentalCare
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Demo Credentials

### Login with these test credentials:
- **Admin**
  - Email: `admin@dental.com`
  - Password: Any value

- **Dentist**
  - Email: `dentist@dental.com`
  - Password: Any value

- **Receptionist**
  - Email: `receptionist@dental.com`
  - Password: Any value

## Project Structure Details

### Models
- **Patient**: Full patient information with contact details
- **Appointment**: Appointment scheduling with conflict detection
- **Treatment**: Treatment records with diagnosis and cost
- **Invoice**: Billing with payment status tracking
- **User**: User information with role assignment

### Services (Mock Data)
- **AuthService**: Handles authentication logic
- **PatientService**: Patient data management
- **AppointmentService**: Appointment scheduling and management
- **TreatmentService**: Treatment record management

### Providers (Riverpod)
- Async providers for data fetching
- State providers for UI state
- Family modifiers for parameterized queries
- Automatic cache invalidation

### Features

#### Authentication
- Login page with role selection
- Session management
- Logout functionality

#### Patient Management
- Patient list with search
- Add/edit patient forms
- Patient details with appointments and treatments
- Delete functionality

#### Appointment Booking
- Calendar view
- Time slot selection
- Conflict detection
- Status management

#### Treatments
- Treatment record creation
- Cost tracking
- Diagnosis and procedure documentation
- Patient history

#### Billing
- Invoice display
- Payment status management
- Revenue tracking
- Financial reports

## Key Features Implementation

### Double Booking Prevention
```dart
bool conflictsWith(Appointment other) {
  if (appointmentDate != other.appointmentDate) return false;
  return !(endTime.isBefore(other.startTime) || 
           startTime.isAfter(other.endTime));
}
```

### Dynamic Pricing
- Per-treatment cost tracking
- Total revenue calculation
- Payment status updates

### Search Functionality
- Patient search by name and phone
- Real-time filtering

### Role-Based Access
- Admin: Full access to all features
- Dentist: Can view appointments and treatments
- Receptionist: Can manage patients and appointments

## Customization

### Theme Colors
Colors can be customized in `lib/core/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF0066CC); // Blue
static const Color accentColor = Color(0xFF00BCD4);  // Light Blue
static const Color successColor = Color(0xFF27AE60); // Green
static const Color errorColor = Color(0xFFE74C3C);   // Red
```

### Adding New Features
1. Create a new feature folder under `features/`
2. Set up presentation layer (pages, widgets)
3. Create Riverpod providers
4. Add routes in `core/router.dart`
5. Update service layer if needed

## Backend Integration Ready

The app is structured to easily connect to a backend API:

1. **Service Layer**: Update services to call REST API instead of mock data
2. **Model Serialization**: Models include copyWith for easy JSON conversion
3. **Error Handling**: Already implemented for network requests
4. **State Management**: Designed for async operations

## Dependencies

```yaml
flutter_riverpod: ^2.4.0      # State management
go_router: ^13.0.0             # Navigation
fl_chart: ^0.64.0              # Charts
table_calendar: ^3.0.9         # Calendar widget
intl: ^0.19.0                  # Internationalization
uuid: ^4.0.0                   # Unique IDs
```

## Testing

Mock data is pre-loaded for testing:
- 3 sample patients
- 2 sample appointments  
- 2 sample treatments

## Performance Optimizations

- Lazy loading of data
- Provider caching and invalidation
- Efficient widget rebuilds with Riverpod
- Minimal widget tree depth

## Code Quality

- Clean code principles
- Well-documented functions
- Type-safe Dart code
- Null safety enabled
- Proper separation of concerns
- Reusable components

## Future Enhancements

- [ ] Backend API integration
- [ ] Real-time notifications
- [ ] Image/file uploads
- [ ] PDF invoice generation
- [ ] Appointment reminders
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Advanced analytics
- [ ] SMS notifications
- [ ] Prescription management

## Support

For issues or questions, please create an issue in the repository.

## License

This project is licensed under the MIT License.

---

**Built with ❤️ using Flutter**
#   d e n t a l c a r e  
 