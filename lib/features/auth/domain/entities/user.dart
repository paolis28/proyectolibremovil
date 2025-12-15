import 'package:equatable/equatable.dart';

/// Entidad de dominio para Usuario
class User extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String role;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, profileImageUrl, role];
}