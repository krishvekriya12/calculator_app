import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../model/daily_entry.dart';
import '../core/theme.dart';

class EntryCard extends StatelessWidget {
  final DailyEntry entry;
  final int index;

  const EntryCard({super.key, required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final isProfit = entry.profit >= 0;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.platform.toUpperCase(), style: AppText.label),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM, EEE').format(entry.date),
                  style: AppText.body.copyWith(color: AppColors.parchmentMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  "${entry.ordersCount} orders  •  Earning ${formatter.format(entry.earning)}  •  Fuel ${formatter.format(entry.fuelCost)}",
                  style: AppText.body.copyWith(fontSize: 12, color: AppColors.parchmentMuted),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -0.08,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatter.format(entry.profit),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return card
        .animate()
        .fadeIn(duration: 350.ms, delay: (index * 40).ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}