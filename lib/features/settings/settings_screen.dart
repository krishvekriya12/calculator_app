import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final name = context.read<SettingsProvider>().userName;
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    context.read<SettingsProvider>().setUserName(_nameController.text);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Naam save ho gaya!')),
    );
  }

  Future<void> _resetAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: Text('Reset Data?', style: AppTextStyles.headingSm),
        content: Text(
          'Kya aap sach me saara hisaab aur entries delete karna chahte hain? Ye wapas nahi aayega.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loss,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('RESET EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await HiveService.clearAll();
      if (!mounted) return;
      await context.read<SettingsProvider>().clearAll();
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile section
            Text('PROFILE', style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aapka Naam', style: AppTextStyles.labelLg),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: AppTextStyles.bodyLg,
                          decoration: const InputDecoration(
                            hintText: 'Jaise: Rahul Sharma',
                            prefixIcon: Icon(Icons.person_rounded, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveName,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // Defaults section
            Text('PREFERENCES', style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delivery_dining_rounded, color: AppColors.gold),
                    title: Text('Default Platform', style: AppTextStyles.headingSm),
                    subtitle: Text(
                      settings.defaultPlatform,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.defaultPlatform,
                      dropdownColor: AppColors.surfaceVariant,
                      underline: const SizedBox.shrink(),
                      items: AppConstants.platforms.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p, style: AppTextStyles.bodyLg),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          settings.setDefaultPlatform(newVal);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            const SizedBox(height: 24),

            // Data management section
            Text('DATA & STORAGE', style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.loss),
                    title: Text('Reset App Data', style: AppTextStyles.headingSm.copyWith(color: AppColors.loss)),
                    subtitle: Text(
                      'Saari entries aur settings clear ho jaayegi',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                    onTap: _resetAllData,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

            const SizedBox(height: 36),

            // About section
            Center(
              child: Column(
                children: [
                  const Text('📱', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.headingSm,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made for Gig & Delivery Heroes ❤️',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
