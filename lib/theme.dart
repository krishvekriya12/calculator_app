import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF1F1B16);   // ledger cover leather
  static const surface = Color(0xFF2A241C);       // ledger page card
  static const divider = Color(0xFF4A3F30);        // stitched line
  static const gold = Color(0xFFD4A94A);           // gilded edge accent
  static const profitGreen = Color(0xFF5C8A6A);    // credit ink
  static const lossRed = Color(0xFFC1440E);        // debit ink
  static const parchment = Color(0xFFF0E6D2);      // main text
  static const parchmentMuted = Color(0xFFA79C87); // secondary text
}

class AppText {
  static const display = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 26,
    color: AppColors.parchment,
    letterSpacing: 0.3,
  );

  static const ledgerNumber = TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w700,
    fontSize: 34,
    color: AppColors.parchment,
    letterSpacing: 1,
  );

  static const label = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.parchmentMuted,
    letterSpacing: 2,
  );

  static const body = TextStyle(
    fontSize: 15,
    color: AppColors.parchment,
  );
}