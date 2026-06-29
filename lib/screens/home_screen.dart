import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final c = isDark ? AppColors.neonBlue : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, state, isDark, c)),
            SliverToBoxAdapter(child: _buildProgressCard(context, state, isDark)),
            SliverToBoxAdapter(child: _buildStreakBanner(context, state, isDark)),
            SliverToBoxAdapter(child: _buildQuoteCard(context, state, isDark)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildSlotCard(ctx, state.slots[i], state, isDark, i),
                  childCount: state.slots.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state, bool isDark, Color c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${state.dayNumber} of ${state.totalDays}',
                  style: TextStyle(color: c, fontSize: 13, fontFamily: 'Orbitron', letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'नमस्ते, ${state.studentName}! 🎯',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  state.currentPhase,
                  style: TextStyle(color: state.phaseColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AppState>().speakMotivation(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border.all(color: c.withOpacity(0.4)),
              ),
              child: Icon(Icons.record_voice_over, color: c, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, AppState state, bool isDark) {
    final progress = state.slotsCompleted / state.totalSlots;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D1535), const Color(0xFF111D45)]
              : [Colors.white, AppColors.lightCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.neonBlue.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                  valueColor: AlwaysStoppedAnimation(
                    progress > 0.75 ? AppColors.neonGreen : AppColors.neonBlue,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.slotsCompleted}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'of ${state.totalSlots}',
                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow('⏱', '${state.todayHours.toStringAsFixed(1)} hrs', 'Today', isDark),
                const SizedBox(height: 8),
                _statRow('📅', '${state.daysRemaining} days', 'Remaining', isDark),
                const SizedBox(height: 8),
                _statRow('🎯', 'AIR ${state.targetAIR}', 'Target', isDark),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _statRow(String emoji, String value, String label, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          fontSize: 14,
        )),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          fontSize: 12,
        )),
      ],
    );
  }

  Widget _buildStreakBanner(BuildContext context, AppState state, bool isDark) {
    if (state.currentStreak == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF2D78)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${state.currentStreak} दिन की streak! Keep going!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Text(
            'Best: ${state.bestStreak}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildQuoteCard(BuildContext context, AppState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonPurple.withOpacity(0.1) : const Color(0xFFEDE7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💫', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.todayQuote,
              style: TextStyle(
                color: isDark ? AppColors.neonPurple : const Color(0xFF6B3FA0),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, StudySlot slot, AppState state, bool isDark, int idx) {
    final isNowSlot = _isCurrentSlot(slot);
    final color = slot.isBreak ? AppColors.neonOrange
        : slot.isDone ? AppColors.neonGreen
        : isNowSlot ? AppColors.neonBlue
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isNowSlot || slot.isDone ? 0.6 : 0.15),
          width: isNowSlot ? 1.5 : 1,
        ),
        boxShadow: isNowSlot
            ? [BoxShadow(color: AppColors.neonBlue.withOpacity(0.15), blurRadius: 15, spreadRadius: 1)]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: GestureDetector(
          onTap: () => state.toggleSlot(slot.id),
          child: AnimatedContainer(
            duration: 300.ms,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slot.isDone ? AppColors.neonGreen : Colors.transparent,
              border: Border.all(color: color, width: 2),
              boxShadow: slot.isDone ? [BoxShadow(color: AppColors.neonGreen.withOpacity(0.4), blurRadius: 10)] : null,
            ),
            child: slot.isDone
                ? const Icon(Icons.check, color: Colors.black, size: 18)
                : isNowSlot
                    ? Icon(Icons.arrow_right, color: color, size: 20)
                    : null,
          ),
        ),
        title: Row(
          children: [
            Text(
              '${slot.startTime}–${slot.endTime}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'Orbitron',
                letterSpacing: 0.5,
              ),
            ),
            if (isNowSlot) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('NOW', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.subject,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                decoration: slot.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            Text(
              slot.task,
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${slot.hours}h',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showEditDialog(context, slot, state),
              child: Icon(Icons.edit_outlined, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, size: 18),
            ),
          ],
        ),
      ),
    ).animate(delay: (idx * 50).ms).fadeIn().slideX(begin: 0.1);
  }

  bool _isCurrentSlot(StudySlot slot) {
    final now = TimeOfDay.now();
    final parts = slot.startTime.split(':');
    final endParts = slot.endTime.split(':');
    final startH = int.parse(parts[0]);
    final startM = int.parse(parts[1]);
    final endH = int.parse(endParts[0]);
    final endM = int.parse(endParts[1]);
    final nowMins = now.hour * 60 + now.minute;
    return nowMins >= startH * 60 + startM && nowMins < endH * 60 + endM;
  }

  void _showEditDialog(BuildContext context, StudySlot slot, AppState state) {
    final subjectCtrl = TextEditingController(text: slot.subject);
    final taskCtrl = TextEditingController(text: slot.task);
    final startCtrl = TextEditingController(text: slot.startTime);
    final endCtrl = TextEditingController(text: slot.endTime);
    final isDark = state.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Slot', style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editField(subjectCtrl, 'Subject', isDark),
            const SizedBox(height: 10),
            _editField(taskCtrl, 'Task', isDark),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _editField(startCtrl, 'Start (HH:MM)', isDark)),
              const SizedBox(width: 10),
              Expanded(child: _editField(endCtrl, 'End (HH:MM)', isDark)),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonBlue),
            onPressed: () {
              state.editSlot(slot.id, subjectCtrl.text, startCtrl.text, endCtrl.text, taskCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, bool isDark) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12),
        filled: true,
        fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
