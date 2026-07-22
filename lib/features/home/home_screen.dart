import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_provider.dart';
import '../settings/settings_provider.dart';
import '../add_entry/add_entry_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/daily_entry.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: _TodaySummaryCard()),
            SliverToBoxAdapter(child: _WeeklyChart()),
            SliverToBoxAdapter(child: _SectionTitle(
              title: 'Recent Entries',
              actionLabel: 'Sab Dekho',
              onAction: () => context.go('/history'),
            )),
            _EntriesList(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _AddFab(),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final name = settings.userName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppFormatters.greeting(),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? 'Bhai! 👋' : '$name! 👋',
                  style: AppTextStyles.headingLg,
                ),
                Text(
                  AppFormatters.dateFull(DateTime.now()),
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }
}

// ── Today's summary card ──────────────────────────────────────────────────────

class _TodaySummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final isProfit = p.todayProfit >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceVariant,
              AppColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isProfit
                ? AppColors.profit.withValues(alpha: 0.25)
                : AppColors.loss.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isProfit
                  ? AppColors.profit.withValues(alpha: 0.08)
                  : AppColors.loss.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AAJ KA HISAAB',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? AppColors.profitBg
                          : AppColors.lossBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isProfit ? '📈 FAAYDA' : '📉 NUKSAAN',
                      style: AppTextStyles.labelMd.copyWith(
                        color: isProfit
                            ? AppColors.profit
                            : AppColors.loss,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Animated profit number
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p.todayProfit),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  AppFormatters.rupee(value),
                  style: AppTextStyles.displayLg.copyWith(
                    color:
                        isProfit ? AppColors.profit : AppColors.loss,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                'Net ${isProfit ? "Profit" : "Loss"} today',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 20),

              // Stats row
              _StatsRow(
                earning: p.todayEarning,
                fuel: p.todayFuel,
                orders: p.todayOrders,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatsRow extends StatelessWidget {
  final double earning;
  final double fuel;
  final int orders;

  const _StatsRow({
    required this.earning,
    required this.fuel,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.arrow_upward_rounded,
          label: 'Earning',
          value: AppFormatters.rupee(earning),
          color: AppColors.profit,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.local_gas_station_rounded,
          label: 'Fuel',
          value: AppFormatters.rupee(fuel),
          color: AppColors.loss,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.delivery_dining_rounded,
          label: 'Orders',
          value: '$orders',
          color: AppColors.gold,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(value,
                style:
                    AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
            Text(label,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ── Weekly chart ───────────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final data = p.last7DaysData;
    final maxVal = data.map((d) => d.earning).fold(0.0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('7 DIN KI KAMAAI',
                    style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
                Text(
                  AppFormatters.monthYear(DateTime.now()),
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: data.every((d) => d.earning == 0)
                  ? Center(
                      child: Text('Koi data nahi abhi',
                          style: AppTextStyles.bodySm))
                  : BarChart(
                      BarChartData(
                        maxY: maxVal > 0 ? maxVal * 1.3 : 1000,
                        minY: 0,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final day = data[value.toInt()].date;
                                final isToday = _isToday(day);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    AppFormatters.dayName(day),
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: isToday
                                          ? AppColors.gold
                                          : AppColors.textMuted,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final d = data[i];
                          final isToday = _isToday(d.date);
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: d.earning,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday
                                      ? [AppColors.goldDark, AppColors.goldLight]
                                      : [
                                          AppColors.profit.withValues(alpha: 0.4),
                                          AppColors.profit.withValues(alpha: 0.7),
                                        ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headingMd),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Entries list ──────────────────────────────────────────────────────────────

class _EntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final entries = p.recentEntries;

    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text('🧾', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text(
                'Koi entry nahi',
                style: AppTextStyles.headingSm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Neeche + button dabao aur pehli entry karo!',
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: _EntryCard(entry: entry, index: index),
          );
        },
        childCount: entries.length,
      ),
    );
  }
}

// ── Entry card ─────────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final DailyEntry entry;
  final int index;

  const _EntryCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final platformColor = AppColors.platformColor(entry.platform);
    final isProfit = entry.isProfit;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return await _confirmDelete(context);
      },
      onDismissed: (_) {
        context.read<HomeProvider>().deleteEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${entry.platform} entry delete ho gayi'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.loss.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: AppColors.loss, size: 26),
            const SizedBox(height: 4),
            Text('Delete',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.loss)),
          ],
        ),
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
              // Platform color accent strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: platformColor,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16)),
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
                                    color: AppColors.platformBg(entry.platform),
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
                                Text(
                                  '${entry.ordersCount} rides',
                                  style: AppTextStyles.bodySm,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.entryDate(entry.date),
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earn ${AppFormatters.rupee(entry.earning)}  ·  Fuel ${AppFormatters.rupee(entry.fuelCost)}',
                              style: AppTextStyles.bodySm,
                            ),
                          ],
                        ),
                      ),
                      // Profit badge
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isProfit
                                  ? AppColors.profitBg
                                  : AppColors.lossBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isProfit
                                    ? AppColors.profit.withValues(alpha: 0.3)
                                    : AppColors.loss.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              AppFormatters.rupee(entry.profit),
                              style: AppTextStyles.labelLg.copyWith(
                                color: isProfit
                                    ? AppColors.profit
                                    : AppColors.loss,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isProfit ? 'Profit' : 'Loss',
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
        .fadeIn(delay: (index * 60).ms, duration: 350.ms)
        .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete karo?', style: AppTextStyles.headingSm),
        content: Text(
          '${entry.platform} ki entry hamesha ke liye delete ho jaayegi.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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

// ── FAB ───────────────────────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useSafeArea: true,
          builder: (_) => const AddEntrySheet(),
        );
      },
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.background,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text(
        'Nayi Entry',
        style: AppTextStyles.buttonMd.copyWith(color: AppColors.background),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
