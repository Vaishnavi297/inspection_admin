class AdminModel {
  final String id;
  final String email;
  final String password;
  final String name;
  final String role;
  final bool? isAdminLogout;
  final String createdAt;
  final String updatedAt;

  AdminModel({required this.id, required this.email, required this.password, required this.name, required this.role, this.isAdminLogout=false, required this.createdAt, required this.updatedAt});


  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      isAdminLogout: json['isAdminLogout'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'], 
    );
  }

  AdminModel copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? role,
    bool? isAdminLogout = false,
    String? createdAt,
    String? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      isAdminLogout: isAdminLogout ?? this.isAdminLogout ?? false,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ================================================================
  //   JSON (Serializable)
  // ================================================================


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'isAdminLogout': isAdminLogout ?? false,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }


}
