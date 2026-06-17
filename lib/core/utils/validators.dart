/// Centralized utility class for standard FormField input validations.
class AppValidators {
  AppValidators._();

  /// Validates that a field is not null or empty.
  static String? requiredField(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the username input field.
  static String? validateUsername(String? value) {
    return requiredField(value, 'Please enter your username');
  }

  /// Validates the password input field.
  static String? validatePassword(String? value) {
    return requiredField(value, 'Please enter your password');
  }
}
