enum UserRole { admin, member }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.member,
    this.jobTitle,
    this.clinicName,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Display role shown in the header (e.g. "Receptionist").
  final String? jobTitle;

  /// Workspace the user belongs to (e.g. "Ubuntu Family Clinic").
  final String? clinicName;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.asNameMap()[json['role']] ?? UserRole.member,
        jobTitle: json['job_title'] as String?,
        clinicName: json['clinic_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        if (jobTitle != null) 'job_title': jobTitle,
        if (clinicName != null) 'clinic_name': clinicName,
      };
}
