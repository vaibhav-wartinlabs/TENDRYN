import 'package:tendryn/models/user.dart';

/// Demo user for the development preview (see `AppConfig.devOpenDashboard`).
/// Matches the Figma Dashboard content.
abstract class DevPreviewUser {
  static const User user = User(
    id: 'dev-preview',
    name: 'Lerato Mokoena',
    email: 'lerato@example.com',
    jobTitle: 'Receptionist',
    clinicName: 'Ubuntu Family Clinic',
  );
}
