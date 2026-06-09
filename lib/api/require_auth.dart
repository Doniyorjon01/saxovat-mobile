import 'package:flutter/material.dart';
import 'auth_store.dart';
import '../screens/auth_screen.dart';

/// Ensures the donor is logged in before a protected action.
/// Returns true if logged in (already, or after a successful login).
/// Returns false if the user backed out without logging in.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (AuthStore.instance.isLoggedIn) return true;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AuthScreen(
        // On success, just close the auth screen — the caller continues.
        onAuthenticated: () => Navigator.of(context).pop(),
      ),
      fullscreenDialog: true,
    ),
  );

  // After the auth screen closes, re-check: did they actually log in?
  return AuthStore.instance.isLoggedIn;
}