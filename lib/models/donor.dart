/// Donor profile — matches DonorOut from the backend (username-based auth).
class Donor {
  final String id;
  final String username;
  final String? email;
  final String fullName;
  final String? phone;
  final String? lastLoginAt;
  final String? createdAt;

  const Donor({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    this.lastLoginAt,
    this.createdAt,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
