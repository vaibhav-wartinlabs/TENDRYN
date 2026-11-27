/// Pure validators: return an error message, or null when valid.
abstract class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? value) {
    final missing = required(value, field: 'Email');
    if (missing != null) return missing;
    return _email.hasMatch(value!.trim()) ? null : 'Enter a valid email address';
  }

  static String? password(String? value, {int minLength = 8}) {
    final missing = required(value, field: 'Password');
    if (missing != null) return missing;
    return value!.length >= minLength ? null : 'Password must be at least $minLength characters';
  }
}
