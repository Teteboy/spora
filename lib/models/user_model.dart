enum UserRole { player, agent, recruiter, club, admin }

enum SubscriptionType { free, premium }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final SubscriptionType subscription;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.subscription = SubscriptionType.free,
    required this.createdAt,
  });

  bool get isPremium => subscription == SubscriptionType.premium;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    SubscriptionType? subscription,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
