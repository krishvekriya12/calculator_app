import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class SummaryCard extends StatelessWidget {
  final double totalProfit;
  final int totalEntries;

  const SummaryCard({
    super.key,
    required this.totalProfit,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL HISAAB", style: AppText.label),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  "$totalEntries ENTRIES",
                  style: AppText.label.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // count-up animation — number 0 se actual value tak animate hoga
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: totalProfit),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                formatter.format(value),
                style: AppText.ledgerNumber.copyWith(
                  color: totalProfit >= 0
                      ? AppColors.profitGreen
                      : AppColors.lossRed,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            totalProfit >= 0 ? "NET PROFIT" : "NET LOSS",
            style: AppText.label,
          ),
        ],
      ),
    );
  }
}