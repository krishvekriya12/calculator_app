import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../home/home_provider.dart';
import '../settings/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/daily_entry.dart';

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _earningCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _ordersCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _platform;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _platform = context.read<SettingsProvider>().defaultPlatform;
    _earningCtrl.addListener(_update);
    _fuelCtrl.addListener(_update);
  }

  void _update() => setState(() {});

  double get _liveProfit {
    final e = double.tryParse(_earningCtrl.text) ?? 0;
    final f = double.tryParse(_fuelCtrl.text) ?? 0;
    return e - f;
  }

  bool get _hasData =>
      _earningCtrl.text.isNotEmpty && _fuelCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    try {
      final entry = DailyEntry.create(
        platform: _platform,
        earning: double.parse(_earningCtrl.text),
        fuelCost: double.parse(_fuelCtrl.text),
        ordersCount: int.tryParse(_ordersCtrl.text) ?? 0,
        date: _date,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      await context.read<HomeProvider>().addEntry(entry);
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.profit, size: 18),
              const SizedBox(width: 10),
              Text('Entry save ho gayi! 🎉',
                  style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error hua. Sahi number daalo.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.gold,
                onPrimary: AppColors.background,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  void dispose() {
    _earningCtrl
      ..removeListener(_update)
      ..dispose();
    _fuelCtrl
      ..removeListener(_update)
      ..dispose();
    _ordersCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Text('NAYI ENTRY', style: AppTextStyles.headingMd),
                        const Spacer(),
                        // Date picker
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  AppFormatters.dateShort(_date),
                                  style: AppTextStyles.labelLg,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.1, end: 0),

                    const SizedBox(height: 20),

                    // Platform selector
                    Text('Platform chuno', style: AppTextStyles.labelLg),
                    const SizedBox(height: 10),
                    _PlatformSelector(
                      selected: _platform,
                      onSelect: (p) => setState(() => _platform = p),
                    ).animate().fadeIn(delay: 50.ms, duration: 300.ms),

                    const SizedBox(height: 20),

                    // Earning field
                    _AmountField(
                      controller: _earningCtrl,
                      label: 'Total Kamaai',
                      hint: '0',
                      prefix: '₹',
                      color: AppColors.profit,
                      icon: Icons.arrow_upward_rounded,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Earning likhna zaroori hai';
                        if (double.tryParse(v) == null) return 'Sahi number likhо';
                        return null;
                      },
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                    const SizedBox(height: 12),

                    // Fuel field
                    _AmountField(
                      controller: _fuelCtrl,
                      label: 'Petrol/Fuel Kharcha',
                      hint: '0',
                      prefix: '₹',
                      color: AppColors.loss,
                      icon: Icons.local_gas_station_rounded,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Fuel cost likhna zaroori hai';
                        if (double.tryParse(v) == null) return 'Sahi number likho';
                        return null;
                      },
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                    const SizedBox(height: 12),

                    // Orders field
                    TextFormField(
                      controller: _ordersCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Orders / Rides (optional)',
                        prefixIcon: const Icon(Icons.delivery_dining_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                    const SizedBox(height: 12),

                    // Notes field
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                    const SizedBox(height: 20),

                    // Live profit preview
                    if (_hasData)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _liveProfit >= 0
                              ? AppColors.profitBg
                              : AppColors.lossBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _liveProfit >= 0
                                ? AppColors.profit.withValues(alpha: 0.3)
                                : AppColors.loss.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _liveProfit >= 0
                                      ? '📈 Aaj ka Profit'
                                      : '📉 Aaj ka Nuksaan',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: _liveProfit >= 0
                                        ? AppColors.profit
                                        : AppColors.loss,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Earning - Fuel',
                                  style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            Text(
                              AppFormatters.rupee(_liveProfit),
                              style: AppTextStyles.headingMd.copyWith(
                                color: _liveProfit >= 0
                                    ? AppColors.profit
                                    : AppColors.loss,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.95, end: 1),

                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background,
                                  ),
                                )
                              : const Text('ENTRY SAVE KARO'),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Platform selector ──────────────────────────────────────────────────────────

class _PlatformSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _PlatformSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.platforms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = AppConstants.platforms[i];
          final isSelected = p == selected;
          final color = AppColors.platformColor(p);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(p);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                p,
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Amount field ───────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String prefix;
  final Color color;
  final IconData icon;
  final FormFieldValidator<String>? validator;

  const _AmountField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefix,
    required this.color,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: color, size: 20),
        prefixText: '$prefix ',
        prefixStyle: AppTextStyles.bodyLg.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}
