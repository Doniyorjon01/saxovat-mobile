import 'package:flutter/material.dart';

/// Sahovat design system — colors.
/// Mapped 1:1 from the dark-navy mockup (CSS variables).
/// One source of truth so every screen stays on-brand.
class AppColors {
  // ── Navy surfaces (--n0 … --n5) ──────────────────────
  static const Color n0 = Color(0xFF070E1C); // deepest (onboarding bg)
  static const Color n1 = Color(0xFF0B1628); // app / page background
  static const Color n2 = Color(0xFF0F1E38); // header / nav bar
  static const Color n3 = Color(0xFF162544); // card
  static const Color n4 = Color(0xFF1E3155); // raised chip / avatar bg
  static const Color n5 = Color(0xFF243A63);

  // ── Blue scale (--b0 … --b5) ─────────────────────────
  static const Color b0 = Color(0xFF1D4ED8);
  static const Color b1 = Color(0xFF2563EB); // primary button / active
  static const Color b2 = Color(0xFF3B82F6); // progress fill
  static const Color b3 = Color(0xFF60A5FA); // primary text accent
  static const Color b4 = Color(0xFFBFDBFE);
  static const Color b5 = Color(0xFFEFF6FF);

  // ── Gold (--g0 … --g2) ───────────────────────────────
  static const Color g0 = Color(0xFFD4A843); // gold accent
  static const Color g1 = Color(0xFFEAB308);
  static const Color g2 = Color(0xFFFEF3C7);

  // ── Red (--r0 … --r2) ────────────────────────────────
  static const Color r0 = Color(0xFFDC2626);
  static const Color r1 = Color(0xFFEF4444);
  static const Color r2 = Color(0xFFFEE2E2);

  // ── Teal (--t0 … --t2) ───────────────────────────────
  static const Color t0 = Color(0xFF0891B2);
  static const Color t1 = Color(0xFF06B6D4);
  static const Color t2 = Color(0xFFCFFAFE);

  // ── Green (--gr0 … --gr2) ────────────────────────────
  static const Color gr0 = Color(0xFF16A34A);
  static const Color gr1 = Color(0xFF22C55E);
  static const Color gr2 = Color(0xFFDCFCE7);

  // ── Text & lines ─────────────────────────────────────
  static const Color white  = Color(0xFFFFFFFF);
  static const Color muted  = Color(0xFF7A93BC); // secondary text
  static const Color muted2 = Color(0xFF4B6A96); // tertiary / placeholder

  // Borders (blue at low opacity)
  static const Color border  = Color(0x263B82F6); // rgba(59,130,246,0.15)
  static const Color border2 = Color(0x473B82F6); // rgba(59,130,246,0.28)
}


