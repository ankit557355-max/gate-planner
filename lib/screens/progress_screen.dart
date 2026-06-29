import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress', style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: isDark ? AppColors.neonGreen : AppColors.lightPrimary,
              )),
              const SizedBox(height: 20),
              _buildStatsGrid(state, isDark),
              const SizedBox(height: 20),
              _buildWeeklyChart(context, state, isDark),
              const SizedBox(height: 20),
              _buildSubjectChart(context, state, isDark),
              const SizedBox(height: 20),
              _buildMockTestChart(context, state, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AppState state, bool isDark) {
    final stats = [
      ('📅', 'Day', '${state.dayNumber}', AppColors.neonBlue),
      ('🔥', 'Streak', '${state.currentStreak}', AppColors.neonOrange),
      ('🏆', 'Best', '${state.bestStreak}', AppColors.neonPurple),
      ('⏳', 'Left', '${state.daysRemaining}d', AppColors.neonGreen),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: stats.map((s) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: s.$4.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.$1, style: const TextStyle(fontSize: 20)),
            Text(s.$3, style: TextStyle(color: s.$4, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(s.$2, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 11)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, AppState state, bool isDark) {
    // Sample data from subject logs
    final logs = state.subjectLogs;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = '${day.year}-${day.month}-${day.day}';
      final total = logs
          .where((l) => l.date == key)
          .fold(0.0, (sum, l) => sum + l.timeSpent);
      return total;
    });

    return _chartCard(
      'Weekly Hours',
      isDark,
      BarChart(
        BarChartData(
          maxY: 12,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.textSecondary.withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              return Text(days[v.toInt()], style: TextStyle(color: AppColors.textSecondary, fontSize: 11));
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              if (v % 4 == 0) return Text('${v.toInt()}h', style: TextStyle(color: AppColors.textSecondary, fontSize: 10));
              return const Text('');
            }, reservedSize: 28)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(7, (i) => BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(
              toY: weekData[i],
              color: weekData[i] >= 8 ? AppColors.neonGreen : AppColors.neonBlue,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 12,
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
            )],
          )),
        ),
      ),
    );
  }

  Widget _buildSubjectChart(BuildContext context, AppState state, bool isDark) {
    if (state.subjectLogs.isEmpty) {
      return _chartCard('Subject Breakdown', isDark,
        Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No subject data yet. Start studying!',
            style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
        )),
      );
    }

    // Aggregate by subject
    final totals = <String, double>{};
    for (final log in state.subjectLogs) {
      totals[log.subject] = (totals[log.subject] ?? 0) + log.timeSpent;
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    final colors = [AppColors.neonBlue, AppColors.neonGreen, AppColors.neonPurple,
                    AppColors.neonOrange, AppColors.neonPink, const Color(0xFFFFD700)];

    return _chartCard(
      'Subject Time Breakdown',
      isDark,
      Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(PieChartData(
              sections: List.generate(top.length, (i) {
                final pct = top[i].value / totals.values.fold(0.0, (a, b) => a + b) * 100;
                return PieChartSectionData(
                  value: top[i].value,
                  color: colors[i % colors.length],
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  radius: 60,
                );
              }),
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            )),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: List.generate(top.length, (i) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, color: colors[i % colors.length]),
                const SizedBox(width: 4),
                Text(
                  '${top[i].key.split(' ').first}: ${top[i].value.toStringAsFixed(1)}h',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTestChart(BuildContext context, AppState state, bool isDark) {
    if (state.mockTests.isEmpty) {
      return _chartCard('Mock Test Trend', isDark,
        Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No mock tests logged yet.',
            style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
        )),
      );
    }

    final tests = state.mockTests.reversed.toList();
    final spots = List.generate(tests.length, (i) => FlSpot(i.toDouble(), tests[i].percentage));

    return _chartCard(
      'Mock Test Score Trend 📈',
      isDark,
      LineChart(LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.textSecondary.withOpacity(0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            return Text('${v.toInt()}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 10));
          }, reservedSize: 32)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < tests.length) return Text('T${i + 1}', style: TextStyle(color: AppColors.textSecondary, fontSize: 10));
            return const Text('');
          })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.neonGreen,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.neonGreen.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _chartCard(String title, bool isDark, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontSize: 16,
          )),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}
