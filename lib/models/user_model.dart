class UserModel {
  final String name;
  final String email;
  final String plan; // 'Basic', 'Silver', 'Gold'
  final bool isGuest;

  const UserModel({
    required this.name,
    required this.email,
    required this.plan,
    required this.isGuest,
  });

  factory UserModel.guest() {
    return const UserModel(
      name: 'Guest User',
      email: 'guest@quotverse.app',
      plan: 'Basic',
      isGuest: true,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? 'Guest User',
      email: json['email'] as String? ?? 'guest@quotverse.app',
      plan: json['plan'] as String? ?? 'Basic',
      isGuest: json['isGuest'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'plan': plan,
      'isGuest': isGuest,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? plan,
    bool? isGuest,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
