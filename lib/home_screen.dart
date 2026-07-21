import 'package:flutter/material.dart';
import 'daily_entry.dart';
import 'theme.dart';
import 'add_entry_sheet.dart';
import 'widgets/summary_card.dart';
import 'widgets/entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DailyEntry> entries = [];

  double get totalProfit =>
      entries.fold(0.0, (sum, entry) => sum + entry.profit);

  void addEntry(DailyEntry entry) {
    setState(() {
      entries.insert(0, entry); // naya entry sabse upar
    });
  }

  void openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEntrySheet(onAdd: addEntry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DAILY HISAAB", style: AppText.display),
              const SizedBox(height: 4),
              Text(
                "Apni daily earning aur kharcha yahan likho",
                style: AppText.body.copyWith(color: AppColors.parchmentMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SummaryCard(totalProfit: totalProfit, totalEntries: entries.length),
              const SizedBox(height: 24),
              Text("RECENT ENTRIES", style: AppText.label),
              const SizedBox(height: 12),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                  child: Text(
                    "Abhi koi entry nahi hai\nNeeche + button dabao",
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(color: AppColors.parchmentMuted),
                  ),
                )
                    : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return EntryCard(entry: entries[index], index: index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddSheet,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }
}