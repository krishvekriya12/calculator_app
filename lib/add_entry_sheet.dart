import 'package:flutter/material.dart';
import 'daily_entry.dart';
import 'theme.dart';

class AddEntrySheet extends StatefulWidget {
  final Function(DailyEntry) onAdd;

  const AddEntrySheet({super.key, required this.onAdd});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final earningController = TextEditingController();
  final fuelController = TextEditingController();
  final ordersController = TextEditingController();
  String selectedPlatform = "Zomato";

  final platforms = ["Zomato", "Swiggy", "Ola", "Uber", "Rapido", "Other"];

  void submit() {
    if (earningController.text.isEmpty || fuelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Earning aur Fuel cost dono bharo")),
      );
      return;
    }

    try {
      final entry = DailyEntry(
        platform: selectedPlatform,
        earning: double.parse(earningController.text),
        fuelCost: double.parse(fuelController.text),
        ordersCount: int.tryParse(ordersController.text) ?? 0,
        date: DateTime.now(),
      );

      widget.onAdd(entry);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sahi number daalo")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NAYI ENTRY", style: AppText.label),
          const SizedBox(height: 16),

          // platform selector — chips ki tarah
          Wrap(
            spacing: 8,
            children: platforms.map((p) {
              final selected = selectedPlatform == p;
              return ChoiceChip(
                label: Text(p),
                selected: selected,
                onSelected: (_) => setState(() => selectedPlatform = p),
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: selected ? AppColors.background : AppColors.parchmentMuted,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _buildField(earningController, "Total Earning (₹)"),
          const SizedBox(height: 12),
          _buildField(fuelController, "Fuel/Petrol Cost (₹)"),
          const SizedBox(height: 12),
          _buildField(ordersController, "Orders/Rides Count (optional)"),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "SAVE ENTRY",
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: AppText.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.parchmentMuted),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}