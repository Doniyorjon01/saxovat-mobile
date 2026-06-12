import 'package:flutter/material.dart';
import 'auth_store.dart';
import '../screens/auth_screen.dart';

/// Ensures the donor is logged in before a protected action.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (AuthStore.instance.isLoggedIn) return true;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AuthScreen(
        onAuthenticated: () => Navigator.of(context).pop(),
      ),
      fullscreenDialog: true,
    ),
  );
  return AuthStore.instance.isLoggedIn;
}
