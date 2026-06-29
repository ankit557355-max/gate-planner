import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _airCtrl;
  late TextEditingController _hoursCtrl;
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _nameCtrl = TextEditingController(text: s.studentName);
    _airCtrl = TextEditingController(text: '${s.targetAIR}');
    _hoursCtrl = TextEditingController(text: '${s.dailyHoursTarget}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _airCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final c = isDark ? AppColors.neonPurple : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: c)),
              const SizedBox(height: 20),

              // Theme
              _sectionCard('🎨 Appearance', isDark, [
                _switchTile('Dark Mode', isDark, state.isDarkMode, (v) => state.toggleTheme(), isDark),
              ]),
              const SizedBox(height: 12),

              // Profile
              _sectionCard('👤 Profile', isDark, [
                _textField(_nameCtrl, 'Your Name', isDark),
                const SizedBox(height: 10),
                _textField(_airCtrl, 'Target AIR', isDark, TextInputType.number),
                const SizedBox(height: 10),
                _textField(_hoursCtrl, 'Daily Hours Target', isDark, TextInputType.number),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      state.saveSettings(
                        name: _nameCtrl.text,
                        air: int.tryParse(_airCtrl.text),
                        hours: double.tryParse(_hoursCtrl.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Settings saved!'), backgroundColor: AppColors.neonGreen),
                      );
                    },
                    child: Text('Save Profile', style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Dates
              _sectionCard('📅 Exam Timeline', isDark, [
                _dateTile('Start Date', state.startDate, isDark, (d) => state.saveSettings(start: d)),
                const Divider(height: 1),
                _dateTile('Exam Date', state.examDate, isDark, (d) => state.saveSettings(exam: d)),
              ]),
              const SizedBox(height: 12),

              // Notifications
              _sectionCard('🔔 Notifications', isDark, [
                _switchTile('Enable All Notifications', isDark, _notifEnabled, (v) => setState(() => _notifEnabled = v), isDark),
                if (_notifEnabled) ...[
                  const Divider(height: 1),
                  _infoTile('Slot Start Alerts', 'When each study slot begins', isDark),
                  _infoTile('Break Reminder', 'At 5:00 PM daily', isDark),
                  _infoTile('Morning Motivation', 'At 6:00 AM in Hindi', isDark),
                  _infoTile('Midnight Warning', 'At 11:50 PM before reset', isDark),
                ],
              ]),
              const SizedBox(height: 12),

              // About
              _sectionCard('ℹ️ About', isDark, [
                _infoTile('App', 'GATE Daily Planner', isDark),
                _infoTile('Version', '1.0.0', isDark),
                _infoTile('Target', 'GATE CE AIR 100', isDark),
                _infoTile('Study Period', '${state.totalDays} days', isDark),
              ]),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            )),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController c, String label, bool isDark, [TextInputType? type]) {
    return TextField(
      controller: c,
      keyboardType: type,
      style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        filled: true,
        fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _switchTile(String title, bool isDark, bool value, ValueChanged<bool> onChanged, bool dark) {
    return Row(
      children: [
        Expanded(child: Text(title, style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 14))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.neonBlue,
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 13)),
          Text(value, style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, bool isDark, Function(DateTime) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
              Text('${date.day}/${date.month}/${date.year}',
                style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          )),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) onChanged(picked);
            },
            child: Text('Change', style: TextStyle(color: AppColors.neonBlue)),
          ),
        ],
      ),
    );
  }
}
