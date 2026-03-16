import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? shiftStatus;
  final Timestamp createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.shiftStatus,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? shiftStatus,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      shiftStatus: shiftStatus ?? this.shiftStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      role: data['role'] as String,
      email: data['email'] as String,
      createdAt: data['createdAt'] as Timestamp,
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'role': role, 'email': email, 'createdAt': createdAt};
  }
}
