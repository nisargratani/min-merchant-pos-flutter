/// Roles supported by the POS system.
enum UserRole {
  admin,
  merchant,
  employee;

  /// Parse role string from API (e.g., 'ADMIN') to enum.
  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'MERCHANT':
        return UserRole.merchant;
      case 'EMPLOYEE':
        return UserRole.employee;
      default:
        return UserRole.employee;
    }
  }

  String toApiString() => name.toUpperCase();
}

/// User entity — core domain model.
class User {
  final int userId;
  final String name;
  final UserRole role;
  final String? token;

  const User({
    required this.userId,
    required this.name,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'role': role.toApiString(),
        if (token != null) 'token': token,
      };

  /// Role-based permission helpers
  bool get canManageProducts => role == UserRole.admin;
  bool get canCreateOrder => role == UserRole.admin || role == UserRole.merchant;
  bool get canMakePayment => role == UserRole.admin || role == UserRole.merchant;
  bool get canViewOwnOrders => role == UserRole.admin || role == UserRole.merchant;
  bool get canViewAllOrders => role == UserRole.admin;
  bool get canViewReports => role == UserRole.admin;

  User copyWith({
    int? userId,
    String? name,
    UserRole? role,
    String? token,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          name == other.name &&
          role == other.role &&
          token == other.token;

  @override
  int get hashCode => userId.hashCode ^ name.hashCode ^ role.hashCode ^ token.hashCode;
}
