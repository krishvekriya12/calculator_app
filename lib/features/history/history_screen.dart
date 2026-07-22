import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'history_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/daily_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _HistoryHeader(),
            _FilterChips(),
            _SummaryRow(),
            Expanded(child: _EntryList()),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text('History', style: AppTextStyles.headingLg),
          const Spacer(),
          Consumer<HistoryProvider>(
            builder: (_, p, child) => PopupMenuButton<SortOrder>(
              color: AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (val) => p.setSortOrder(val),
              itemBuilder: (_) => SortOrder.values
                  .map((o) => PopupMenuItem(
                        value: o,
                        child: Text(o.label,
                            style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textPrimary)),
                      ))
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort_rounded,
                        size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text('Sort',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ── Filter chips ───────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HistoryProvider>();
    final platforms = ['All', ...AppConstants.platforms];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: platforms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final platform = platforms[i];
          final isAll = platform == 'All';
          final selected = isAll
              ? p.selectedPlatform == null
              : p.selectedPlatform == platform;
          final color = isAll
              ? AppColors.gold
              : AppColors.platformColor(platform);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              p.setPlatform(isAll ? null : platform);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? color : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                platform,
                style: AppTextStyles.labelLg.copyWith(
                  color: selected ? color : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HistoryProvider>();
    final count = p.filtered.length;
    final profit = p.filteredProfit;
    final isPos = profit >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$count entries', style: AppTextStyles.labelLg),
            Text(
              '${isPos ? "+" : ""}${AppFormatters.rupee(profit)} net',
              style: AppTextStyles.labelLg.copyWith(
                color: isPos ? AppColors.profit : AppColors.loss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry list ─────────────────────────────────────────────────────────────────

class _EntryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HistoryProvider>();
    final entries = p.filtered;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Koi entry nahi mili',
                style: AppTextStyles.headingSm
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Filter change karke dekho',
                style: AppTextStyles.bodySm),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _HistoryEntryCard(entry: entry, index: index),
        );
      },
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  final DailyEntry entry;
  final int index;

  const _HistoryEntryCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final platformColor = AppColors.platformColor(entry.platform);
    final isProfit = entry.isProfit;

    return Dismissible(
      key: Key('hist_${entry.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return await _confirm(context);
      },
      onDismissed: (_) {
        context.read<HistoryProvider>().deleteEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry delete ho gayi')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.loss.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.loss, size: 26),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: platformColor,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.platformBg(entry.platform),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    entry.platform.toUpperCase(),
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: platformColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${entry.ordersCount} orders',
                                    style: AppTextStyles.bodySm),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.entryDate(entry.date),
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${AppFormatters.rupee(entry.earning)} earn  ·  ${AppFormatters.rupee(entry.fuelCost)} fuel',
                              style: AppTextStyles.bodySm,
                            ),
                            if (entry.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(entry.notes!,
                                  style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.rupee(entry.profit),
                            style: AppTextStyles.headingSm.copyWith(
                              color: isProfit
                                  ? AppColors.profit
                                  : AppColors.loss,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isProfit ? '✅ Profit' : '❌ Loss',
                            style: AppTextStyles.bodySm.copyWith(
                              color: isProfit
                                  ? AppColors.profit
                                  : AppColors.loss,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 40).ms, duration: 300.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOut);
  }

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete karo?', style: AppTextStyles.headingSm),
        content: Text('Ye entry hamesha ke liye mit jaayegi.',
            style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.loss),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
