import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

// ──────────────────────────────────────────────
//  MOCK TEST SCREEN
// ──────────────────────────────────────────────
class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final c = isDark ? AppColors.neonGreen : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c,
        onPressed: () => _showAddDialog(context, state, isDark),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Add Test', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mock Tests', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: c)),
              const SizedBox(height: 16),
              if (state.mockTests.isNotEmpty) _buildSummary(state, isDark),
              const SizedBox(height: 12),
              Expanded(
                child: state.mockTests.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No mock tests yet.\nTap + to add your first test!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: state.mockTests.length,
                        itemBuilder: (ctx, i) => _buildTestCard(state.mockTests[i], isDark),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(AppState state, bool isDark) {
    final avg = state.mockTests.fold(0.0, (s, t) => s + t.percentage) / state.mockTests.length;
    final best = state.mockTests.map((t) => t.percentage).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        _chip('Avg', '${avg.toStringAsFixed(1)}%', AppColors.neonBlue, isDark),
        const SizedBox(width: 10),
        _chip('Best', '${best.toStringAsFixed(1)}%', AppColors.neonGreen, isDark),
        const SizedBox(width: 10),
        _chip('Total', '${state.mockTests.length}', AppColors.neonPurple, isDark),
      ],
    );
  }

  Widget _chip(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildTestCard(MockTest test, bool isDark) {
    final pct = test.percentage;
    final color = pct >= 70 ? AppColors.neonGreen : pct >= 50 ? AppColors.neonOrange : AppColors.neonPink;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
            ),
            child: Center(
              child: Text('${pct.toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${test.score}/${test.total}',
                  style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold, fontSize: 16)),
                Text(test.platform, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
                Text(test.date, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 11)),
              ],
            ),
          ),
          if (test.rank != null && test.rank!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Rank ${test.rank}', style: const TextStyle(color: AppColors.neonPurple, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppState state, bool isDark) {
    final scoreCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '100');
    final rankCtrl = TextEditingController();
    String platform = 'MADE EASY';
    final platforms = ['MADE EASY', 'Testbook', 'ACE', 'GATE Official', 'Other'];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx2).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Mock Test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _field(scoreCtrl, 'Score', isDark, TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _field(totalCtrl, 'Total', isDark, TextInputType.number)),
              ]),
              const SizedBox(height: 10),
              _field(rankCtrl, 'Rank (optional)', isDark),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: platform,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                decoration: InputDecoration(
                  labelText: 'Platform',
                  filled: true,
                  fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                items: platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setS(() => platform = v!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final score = double.tryParse(scoreCtrl.text) ?? 0;
                    final total = double.tryParse(totalCtrl.text) ?? 100;
                    state.addMockTest(MockTest(
                      date: DateTime.now().toString().split(' ')[0],
                      score: score,
                      total: total,
                      platform: platform,
                      rank: rankCtrl.text.isEmpty ? null : rankCtrl.text,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Test', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, bool isDark, [TextInputType? type]) {
    return TextField(
      controller: c,
      keyboardType: type,
      style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  PYQ TRACKER SCREEN
// ──────────────────────────────────────────────
class PYQScreen extends StatelessWidget {
  const PYQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final c = isDark ? AppColors.neonOrange : AppColors.lightPrimary;

    // Aggregate by subject
    final bySubject = <String, Map<String, int>>{};
    for (final e in state.pyqEntries) {
      bySubject.putIfAbsent(e.subject, () => {'attempted': 0, 'correct': 0, 'years': 0});
      bySubject[e.subject]!['attempted'] = bySubject[e.subject]!['attempted']! + e.attempted;
      bySubject[e.subject]!['correct'] = bySubject[e.subject]!['correct']! + e.correct;
      bySubject[e.subject]!['years'] = bySubject[e.subject]!['years']! + 1;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c,
        onPressed: () => _showAddDialog(context, state, isDark),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Log PYQ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PYQ Tracker', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: c)),
              Text('2010–2024 Papers', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Expanded(
                child: state.pyqEntries.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📄', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No PYQs logged yet.\nSolve and track here!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                        ],
                      ))
                    : ListView(
                        children: bySubject.entries.map((entry) {
                          final attempted = entry.value['attempted']!;
                          final correct = entry.value['correct']!;
                          final years = entry.value['years']!;
                          final acc = attempted > 0 ? (correct / attempted * 100) : 0.0;
                          final color = acc >= 70 ? AppColors.neonGreen : acc >= 50 ? AppColors.neonOrange : AppColors.neonPink;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(entry.key,
                                      style: TextStyle(fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary))),
                                    Text('${acc.toStringAsFixed(0)}%',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: acc / 100,
                                    backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                                    valueColor: AlwaysStoppedAnimation(color),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Text('✅ $correct/$attempted correct',
                                    style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
                                  const Spacer(),
                                  Text('📅 $years/15 years',
                                    style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
                                ]),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppState state, bool isDark) {
    String subject = gateSubjects[0];
    final yearCtrl = TextEditingController(text: '2024');
    final attCtrl = TextEditingController();
    final corrCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx2).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log PYQ Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: subject,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                decoration: InputDecoration(labelText: 'Subject', filled: true,
                  fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                items: gateSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)))).toList(),
                onChanged: (v) => setS(() => subject = v!),
              ),
              const SizedBox(height: 10),
              _field(yearCtrl, 'Year (e.g. 2023)', isDark, TextInputType.number),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(attCtrl, 'Attempted', isDark, TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _field(corrCtrl, 'Correct', isDark, TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    state.addPYQEntry(PYQEntry(
                      subject: subject,
                      year: int.tryParse(yearCtrl.text) ?? 2024,
                      attempted: int.tryParse(attCtrl.text) ?? 0,
                      correct: int.tryParse(corrCtrl.text) ?? 0,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, bool isDark, [TextInputType? type]) {
    return TextField(
      controller: c,
      keyboardType: type,
      style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
