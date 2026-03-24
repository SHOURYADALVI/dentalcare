# Project Structure & File Reference

## Directory Tree

```
DentalCare/
├── lib/
│   ├── main.dart                                    [Entry point - App initialization]
│   ├── core/
│   │   ├── router.dart                             [Route configuration with Go Router]
│   │   ├── theme.dart                              [Theme colors, spacing, typography]
│   │   └── providers/
│   │       ├── auth_providers.dart                 [Auth state management]
│   │       ├── patient_providers.dart              [Patient CRUD operations]
│   │       ├── appointment_providers.dart          [Appointment management]
│   │       └── treatment_providers.dart            [Treatment records]
│   ├── models/
│   │   ├── patient.dart                            [Patient data model]
│   │   ├── appointment.dart                        [Appointment data model]
│   │   ├── treatment.dart                          [Treatment data model]
│   │   ├── invoice.dart                            [Invoice/billing model]
│   │   ├── user.dart                               [User/staff model]
│   │   └── user_role.dart                          [User role enum]
│   ├── services/
│   │   ├── auth_service.dart                       [Authentication logic]
│   │   ├── patient_service.dart                    [Patient data management]
│   │   ├── appointment_service.dart                [Appointment logic]
│   │   └── treatment_service.dart                  [Treatment records logic]
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/pages/
│   │   │       └── login_page.dart                 [Login screen with role selection]
│   │   ├── patients/
│   │   │   └── presentation/pages/
│   │   │       ├── patients_list_page.dart         [Patient list with search]
│   │   │       ├── patient_detail_page.dart        [Patient profile details]
│   │   │       └── add_edit_patient_page.dart      [Patient add/edit form]
│   │   ├── appointments/
│   │   │   └── presentation/pages/
│   │   │       └── appointments_page.dart          [Calendar & appointments view]
│   │   ├── treatments/
│   │   │   └── presentation/pages/
│   │   │       └── treatments_page.dart            [Treatment records]
│   │   ├── billing/
│   │   │   └── presentation/pages/
│   │   │       └── billing_page.dart               [Invoices & revenue]
│   │   └── dashboard/
│   │       └── presentation/pages/
│   │           └── dashboard_page.dart             [Main dashboard with metrics]
│   └── widgets/
│       ├── buttons.dart                            [Custom button components]
│       ├── cards.dart                              [Info cards, patient cards]
│       └── form_fields.dart                        [Form input widgets]
├── pubspec.yaml                                   [Project dependencies]
├── analysis_options.yaml                          [Linting configuration]
├── .gitignore                                     [Git ignore rules]
├── README.md                                      [Project documentation]
├── PROJECT_SUMMARY.md                             [Detailed project overview]
└── QUICKSTART.md                                  [Setup and usage guide]
```

## File Descriptions

### Core Files

#### `lib/main.dart`
- App entry point
- Sets up Riverpod ProviderScope
- Configures routing and theme
- Launches the application

#### `lib/core/router.dart`
- Go Router configuration
- Route definitions with named routes
- Role-based route access control
- Error handling and redirects

#### `lib/core/theme.dart`
- Material 3 theme configuration
- Color palette (primary, accent, error, success)
- Spacing constants
- Typography system
- Button and card styles

### Models Directory

Each model represents a core entity with:
- Constructor with required/optional fields
- `copyWith()` method for immutable updates
- `toString()` for debugging
- Type-safe null safety

#### `lib/models/patient.dart` (~60 lines)
- Full patient information
- Medical history tracking
- Contact details
- CRUD methods

#### `lib/models/appointment.dart` (~80 lines)
- Appointment scheduling
- Conflict detection logic
- Status tracking
- Patient references

#### `lib/models/treatment.dart` (~55 lines)
- Treatment procedure records
- Cost tracking
- Diagnosis documentation
- Patient references

#### `lib/models/invoice.dart` (~65 lines)
- Billing and invoicing
- Payment status tracking
- Treatment line items
- Calculation utilities

#### `lib/models/user.dart` & `user_role.dart` (~35 lines)
- User authentication data
- Role-based access control
- Staff information

### Services Directory

Mock data services providing async business logic:

#### `lib/services/auth_service.dart` (~50 lines)
- Mock authentication
- Role-based credentials
- Session management

#### `lib/services/patient_service.dart` (~90 lines)
- Patient CRUD operations
- Search functionality
- Patient statistics
- Mock patient data

#### `lib/services/appointment_service.dart` (~100 lines)
- Appointment management
- Time slot availability
- Double-booking prevention
- Appointment scheduling

#### `lib/services/treatment_service.dart` (~85 lines)
- Treatment record management
- Cost tracking
- Revenue calculations
- Date range filtering

### Providers Directory

Riverpod state management for data access:

#### `lib/core/providers/auth_providers.dart` (~40 lines)
- Current user state
- Login/logout operations
- Authentication status
- User role access

#### `lib/core/providers/patient_providers.dart` (~70 lines)
- Patients list provider
- Patient search provider
- Individual patient fetch
- CRUD operation providers
- Patient count provider

#### `lib/core/providers/appointment_providers.dart` (~60 lines)
- All appointments provider
- Patient appointments
- Date-specific appointments
- Available slots
- CRUD operations

#### `lib/core/providers/treatment_providers.dart` (~55 lines)
- Treatments list provider
- Patient treatments
- Date range filtering
- Revenue calculations
- CRUD operations

### Features Directory

Feature modules following clean architecture:

#### `lib/features/auth/presentation/pages/login_page.dart` (~130 lines)
- Role selection UI
- Email/password input
- Demo credentials display
- Login form with validation

#### `lib/features/patients/presentation/pages/patients_list_page.dart` (~100 lines)
- Patient list display
- Search functionality
- Patient cards with navigation
- Delete confirmation dialog

#### `lib/features/patients/presentation/pages/add_edit_patient_page.dart` (~150 lines)
- Patient form with full fields
- Input validation
- Edit mode for existing patients
- Success/error feedback

#### `lib/features/patients/presentation/pages/patient_detail_page.dart` (~180 lines)
- Complete patient profile
- Medical history display
- Appointments list
- Treatments history
- Quick action buttons

#### `lib/features/appointments/presentation/pages/appointments_page.dart` (~200 lines)
- Calendar view with table_calendar
- Appointment list for selected date
- New appointment dialog
- Time slot management
- Status tracking

#### `lib/features/treatments/presentation/pages/treatments_page.dart` (~170 lines)
- Treatment list display
- Treatment form UI
- Cost input and storage
- Diagnosis tracking
- Patient references

#### `lib/features/billing/presentation/pages/billing_page.dart` (~150 lines)
- Invoice display cards
- Revenue summary
- Payment status UI
- Mark as paid functionality

#### `lib/features/dashboard/presentation/pages/dashboard_page.dart` (~250 lines)
- Key metrics cards (Riverpod)
- Revenue bar chart
- Quick action buttons
- User greeting
- Logout functionality

### Widgets Directory

Reusable UI components:

#### `lib/widgets/buttons.dart` (~80 lines)
- PrimaryButton: Main action button
- SecondaryButton: Alternative action
- DangerButton: Delete/warning actions
- Loading state support

#### `lib/widgets/cards.dart` (~150 lines)
- InfoCard: Metric display cards
- PatientCard: Patient list item with avatar
- StatusBadge: Status indicator component

#### `lib/widgets/form_fields.dart` (~120 lines)
- CustomTextField: Text input with validation
- CustomDropdownField: Dropdown selector
- DatePickerField: Date selection
- TimePickerField: Time selection
- Password toggle support

### Configuration Files

#### `pubspec.yaml` (~45 lines)
```yaml
name: dental_clinic_app
version: 1.0.0+1
dependencies:
  flutter: sdk: flutter
  flutter_riverpod: ^2.4.0
  go_router: ^13.0.0
  fl_chart: ^0.64.0
  table_calendar: ^3.0.9
  intl: ^0.19.0
  uuid: ^4.0.0
```

#### `analysis_options.yaml`
- Dart analyzer configuration
- Lint rules for code quality
- Strictness settings

#### `.gitignore`
- Flutter/Dart build artifacts
- IDE files (VS Code, Android Studio)
- Platform-specific builds

### Documentation Files

#### `README.md` (~250 lines)
- Project overview
- Feature descriptions
- Architecture explanation
- Setup instructions
- Future enhancements

#### `PROJECT_SUMMARY.md` (~200 lines)
- Detailed project summary
- Technology stack
- File statistics
- Implementation details
- Roadmap

#### `QUICKSTART.md` (~250 lines)
- Quick start guide
- Feature walkthrough
- Code customization examples
- Troubleshooting tips
- Common tasks

## Code Statistics

| Component | Files | Lines |
|-----------|-------|-------|
| Models | 6 | ~350 |
| Services | 4 | ~325 |
| Providers | 4 | ~225 |
| Features (Pages) | 8 | ~1100+ |
| Widgets | 3 | ~350 |
| Core (Router + Theme) | 2 | ~250 |
| Main Entry Point | 1 | ~25 |
| **Total** | **28** | **~2600+** |

## Feature Complexity Reference

### Simple Features
- Login Page (Entry point)
- Info Cards (Dashboard)

### Medium Complexity
- Patient List (Search + CRUD)
- Treatments Page (Forms + List)
- Billing Page (Status management)

### Complex Features
- Patient Detail (Multiple sections)
- Appointments (Calendar + Logic)
- Dashboard (Analytics + Charts)

## Testing Points

Each module can be tested independently:
- Models: Unit tests for logic
- Services: Mock data verification
- Providers: State management tests
- Widgets: Widget tests for UI
- Pages: Integration tests for flows

## API Integration Points

Ready to replace mock services:
1. `PatientService` - Patient API calls
2. `AppointmentService` - Appointment API calls
3. `TreatmentService` - Treatment API calls
4. `AuthService` - Real authentication

## Performance Optimization Areas

- Lazy loading of providers
- Caching strategies
- Widget rebuild optimization
- Image optimization (when added)
- Database indexing (when backend integrated)

---

**Total Project Size**: ~2600+ lines of well-structured, production-ready Flutter code
