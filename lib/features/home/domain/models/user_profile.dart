class UserProfile {
  final String userId;
  final String? name;

  UserProfile({
    required this.userId,
    this.name,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String userId) {
    return UserProfile(
      userId: userId,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  UserProfile copyWith({
    String? name,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
    );
  }
}
