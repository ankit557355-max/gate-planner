import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';

enum TimerMode { pomodoro, shortBreak, longBreak, stopwatch }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  TimerMode _mode = TimerMode.pomodoro;
  Timer? _timer;
  int _seconds = 25 * 60; // 25 min pomodoro
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  int _pomodorosCompleted = 0;
  String _selectedSubject = 'Geotechnical Engineering';
  String _stopwatchDisplay = '00:00:00';
  int _stopwatchSeconds = 0;
  late AnimationController _pulseController;
  final TTSService _tts = TTSService();

  // Custom timer fields
  int _customMinutes = 25;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_mode == TimerMode.stopwatch) {
        setState(() {
          _stopwatchSeconds++;
          final h = _stopwatchSeconds ~/ 3600;
          final m = (_stopwatchSeconds % 3600) ~/ 60;
          final s = _stopwatchSeconds % 60;
          _stopwatchDisplay =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
        });
      } else {
        if (_seconds > 0) {
          setState(() => _seconds--);
        } else {
          _onTimerComplete();
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = _totalSeconds;
      _stopwatchSeconds = 0;
      _stopwatchDisplay = '00:00:00';
    });
  }

  void _onTimerComplete() async {
    _timer?.cancel();
    setState(() => _isRunning = false);
    if (_mode == TimerMode.pomodoro) {
      _pomodorosCompleted++;
      await _tts.speak('Pomodoro complete! $_selectedSubject के लिए 25 मिनट पूरे हुए। अब 5 मिनट का break लो।');
      // Log time
      if (mounted) {
        context.read<AppState>().addSubjectLog(SubjectLog(
          date: DateTime.now().toString().split(' ')[0],
          subject: _selectedSubject,
          topic: 'Pomodoro session',
          timeSpent: 25 / 60,
        ));
      }
      // Auto switch to short break
      _setMode(TimerMode.shortBreak);
      _startTimer();
    } else if (_mode == TimerMode.shortBreak) {
      await _tts.speak('Break खत्म! वापस पढ़ाई शुरू करो।');
      _setMode(TimerMode.pomodoro);
    }
  }

  void _setMode(TimerMode mode) {
    _timer?.cancel();
    setState(() {
      _mode = mode;
      _isRunning = false;
      switch (mode) {
        case TimerMode.pomodoro:
          _seconds = _customMinutes * 60;
          _totalSeconds = _customMinutes * 60;
          break;
        case TimerMode.shortBreak:
          _seconds = 5 * 60;
          _totalSeconds = 5 * 60;
          break;
        case TimerMode.longBreak:
          _seconds = 15 * 60;
          _totalSeconds = 15 * 60;
          break;
        case TimerMode.stopwatch:
          _stopwatchSeconds = 0;
          _stopwatchDisplay = '00:00:00';
          break;
      }
    });
  }

  String get _timeDisplay {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => _mode == TimerMode.stopwatch ? 0.5 : 1 - (_seconds / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDarkMode;
    final c = isDark ? AppColors.neonBlue : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text('Study Timer', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: c)),
              const SizedBox(height: 8),

              // Subject Selector
              _buildSubjectSelector(isDark, c),
              const SizedBox(height: 20),

              // Mode Tabs
              _buildModeTabs(isDark, c),
              const SizedBox(height: 32),

              // Timer Ring
              _buildTimerRing(isDark, c),
              const SizedBox(height: 32),

              // Controls
              _buildControls(isDark, c),
              const SizedBox(height: 24),

              // Pomodoro count
              if (_mode != TimerMode.stopwatch) _buildPomodoroCount(isDark, c),

              // Custom time
              if (_mode == TimerMode.pomodoro) _buildCustomTime(isDark, c),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector(bool isDark, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubject,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 14),
          items: gateSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedSubject = v!),
        ),
      ),
    );
  }

  Widget _buildModeTabs(bool isDark, Color c) {
    final modes = [
      (TimerMode.pomodoro, '🍅 Pomodoro'),
      (TimerMode.shortBreak, '☕ 5 min'),
      (TimerMode.longBreak, '🌙 15 min'),
      (TimerMode.stopwatch, '⏱ Watch'),
    ];
    return Row(
      children: modes.map((m) {
        final selected = _mode == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => _setMode(m.$1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? c : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                m.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.black : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimerRing(bool isDark, Color c) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = _isRunning ? (0.4 + 0.4 * _pulseController.value) : 0.3;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: c.withOpacity(glow), blurRadius: 40, spreadRadius: 5)],
          ),
          child: CircularPercentIndicator(
            radius: 130,
            lineWidth: 12,
            percent: _progress.clamp(0.0, 1.0),
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            progressColor: c,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _mode == TimerMode.stopwatch ? _stopwatchDisplay : _timeDisplay,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: _mode == TimerMode.stopwatch ? 28 : 48,
                    fontWeight: FontWeight.bold,
                    color: c,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _mode == TimerMode.pomodoro ? '🍅 Pomodoro'
                      : _mode == TimerMode.shortBreak ? '☕ Short Break'
                      : _mode == TimerMode.longBreak ? '🌙 Long Break'
                      : '⏱ Stopwatch',
                  style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isDark, Color c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _controlBtn(Icons.refresh, isDark, () => _resetTimer()),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
            ),
            child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 36),
          ),
        ),
        const SizedBox(width: 20),
        _controlBtn(Icons.skip_next, isDark, () => _onTimerComplete()),
      ],
    );
  }

  Widget _controlBtn(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
        ),
        child: Icon(icon, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
      ),
    );
  }

  Widget _buildPomodoroCount(bool isDark, Color c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(8, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < _pomodorosCompleted ? AppColors.neonOrange : (isDark ? AppColors.darkCard : AppColors.lightCard),
            border: Border.all(color: AppColors.neonOrange.withOpacity(0.4)),
          ),
          child: Center(
            child: Text('🍅', style: TextStyle(fontSize: i < _pomodorosCompleted ? 14 : 10)),
          ),
        );
      }),
    );
  }

  Widget _buildCustomTime(bool isDark, Color c) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Focus time: ', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
          IconButton(
            onPressed: () {
              if (_customMinutes > 5) setState(() { _customMinutes -= 5; _setMode(TimerMode.pomodoro); });
            },
            icon: const Icon(Icons.remove_circle_outline),
            color: c,
          ),
          Text('$_customMinutes min', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
            onPressed: () {
              if (_customMinutes < 90) setState(() { _customMinutes += 5; _setMode(TimerMode.pomodoro); });
            },
            icon: const Icon(Icons.add_circle_outline),
            color: c,
          ),
        ],
      ),
    );
  }
}
