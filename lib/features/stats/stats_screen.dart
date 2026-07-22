import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'stats_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _StatsHeader()),
            SliverToBoxAdapter(child: _OverallCards()),
            SliverToBoxAdapter(child: _WeeklyBarChart()),
            SliverToBoxAdapter(child: _PlatformBreakdown()),
            SliverToBoxAdapter(child: _BestWorstDay()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics', style: AppTextStyles.headingLg),
          Text(
            'Apni kamaai ka poora hisaab',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ── Overall summary cards ─────────────────────────────────────────────────────

class _OverallCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Big total profit card
          _BigStatCard(
            label: 'TOTAL NET PROFIT',
            value: AppFormatters.rupee(p.totalProfit),
            isProfit: p.totalProfit >= 0,
            subtitle: '${p.totalEntries} entries · ${p.totalOrders} orders',
          ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  label: 'Total Kamaai',
                  value: AppFormatters.rupee(p.totalEarning),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.profit,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStatCard(
                  label: 'Total Fuel',
                  value: AppFormatters.rupee(p.totalFuel),
                  icon: Icons.local_gas_station_rounded,
                  color: AppColors.loss,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  label: 'Avg / Entry',
                  value: AppFormatters.rupee(p.avgProfitPerEntry),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.gold,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStatCard(
                  label: 'Total Days',
                  value: '${p.totalEntries}',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.other,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isProfit;
  final String subtitle;

  const _BigStatCard({
    required this.label,
    required this.value,
    required this.isProfit,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProfit
              ? [AppColors.profitBg, AppColors.surface]
              : [AppColors.lossBg, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProfit
              ? AppColors.profit.withValues(alpha: 0.25)
              : AppColors.loss.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.displayLg.copyWith(
              color: isProfit ? AppColors.profit : AppColors.loss,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.headingSm.copyWith(color: AppColors.textPrimary)),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

// ── Weekly bar chart ───────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatsProvider>();
    final data = p.weeklyData;
    final maxVal = p.maxWeeklyProfit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WEEKLY PROFIT', style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text('Pichhle 7 din ka profit/loss',
                style: AppTextStyles.bodySm),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxVal > 0 ? maxVal * 1.3 : 1000,
                  minY: data.any((d) => d.profit < 0)
                      ? -maxVal * 0.5
                      : 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.surfaceVariant,
                      getTooltipItem: (group, _, rod, _) {
                        final day = data[group.x];
                        return BarTooltipItem(
                          '${AppFormatters.dayName(day.date)}\n${AppFormatters.rupee(day.profit)}',
                          AppTextStyles.bodySm.copyWith(
                            color: day.profit >= 0
                                ? AppColors.profit
                                : AppColors.loss,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
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
                        getTitlesWidget: (val, meta) {
                          final day = data[val.toInt()].date;
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
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final d = data[i];
                    final isToday = _isToday(d.date);
                    final isPositive = d.profit >= 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.profit,
                          fromY: 0,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isToday
                                ? [AppColors.goldDark, AppColors.goldLight]
                                : isPositive
                                    ? [
                                        AppColors.profit.withValues(alpha: 0.5),
                                        AppColors.profit.withValues(alpha: 0.85),
                                      ]
                                    : [
                                        AppColors.loss.withValues(alpha: 0.85),
                                        AppColors.loss.withValues(alpha: 0.5),
                                      ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }
}

// ── Platform breakdown ─────────────────────────────────────────────────────────

class _PlatformBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatsProvider>();
    final map = p.platformEarnings;

    if (map.isEmpty) return const SizedBox.shrink();

    final total = map.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PLATFORM BREAKDOWN',
                style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 16),
            ...map.entries.map((e) {
              final pct = total > 0 ? e.value / total : 0.0;
              final color = AppColors.platformColor(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(e.key, style: AppTextStyles.labelLg),
                          ],
                        ),
                        Text(
                          '${AppFormatters.rupee(e.value)} (${(pct * 100).toStringAsFixed(0)}%)',
                          style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ── Best / Worst day ───────────────────────────────────────────────────────────

class _BestWorstDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatsProvider>();
    final best = p.bestEntry;
    final worst = p.worstEntry;

    if (best == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _DayHighlight(
              emoji: '🏆',
              label: 'Best Day',
              platform: best.platform,
              date: AppFormatters.entryDate(best.date),
              amount: AppFormatters.rupee(best.profit),
              color: AppColors.profit,
            ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
          ),
          const SizedBox(width: 10),
          if (worst != null && worst.id != best.id)
            Expanded(
              child: _DayHighlight(
                emoji: '📉',
                label: 'Worst Day',
                platform: worst.platform,
                date: AppFormatters.entryDate(worst.date),
                amount: AppFormatters.rupee(worst.profit),
                color: AppColors.loss,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ),
        ],
      ),
    );
  }
}

class _DayHighlight extends StatelessWidget {
  final String emoji;
  final String label;
  final String platform;
  final String date;
  final String amount;
  final Color color;

  const _DayHighlight({
    required this.emoji,
    required this.label,
    required this.platform,
    required this.date,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(platform, style: AppTextStyles.labelLg.copyWith(color: color)),
          Text(date, style: AppTextStyles.bodySm),
          const SizedBox(height: 6),
          Text(amount,
              style: AppTextStyles.headingSm.copyWith(color: color)),
        ],
      ),
    );
  }
}
