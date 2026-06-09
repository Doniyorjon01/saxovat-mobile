/// Donor profile — matches DonorOut from the backend.
class Donor {
  final String id;
  final String email;
  final String fullName;
  final String? phone;

  const Donor({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
    );
  }
}