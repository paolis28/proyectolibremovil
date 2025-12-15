import '../../domain/entities/user.dart';

/// Modelo de datos para Usuario (extends entity)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    super.profileImageUrl,
    required super.role,
  });

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'role': role,
    };
  }
}