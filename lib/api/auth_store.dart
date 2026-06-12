import '../models/donor.dart';

/// In-memory session store for the logged-in donor.
/// DEV NOTE: tokens live only while the app is open. Production → secure storage.
class AuthStore {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  String? accessToken;
  String? refreshToken;
  Donor? donor;

  bool get isLoggedIn => accessToken != null;

  void setSession({
    required String access,
    required String refresh,
    required Donor donorProfile,
  }) {
    accessToken = access;
    refreshToken = refresh;
    donor = donorProfile;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
    donor = null;
  }
}
