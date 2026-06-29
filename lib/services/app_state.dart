import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'tts_service.dart';

class AppState extends ChangeNotifier {
  // ── Theme ──────────────────────────────────────────────────
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  // ── User Info ──────────────────────────────────────────────
  String studentName = 'Student';
  DateTime startDate = DateTime.now();
  DateTime examDate = DateTime.now().add(const Duration(days: 210));
  int targetAIR = 100;
  double dailyHoursTarget = 8.0;

  // ── Slots ──────────────────────────────────────────────────
  List<StudySlot> slots = getDefaultSlots();
  String _lastResetDate = '';

  // ── Streak ─────────────────────────────────────────────────
  int currentStreak = 0;
  int bestStreak = 0;

  // ── Subject Logs ───────────────────────────────────────────
  List<SubjectLog> subjectLogs = [];

  // ── Mock Tests ─────────────────────────────────────────────
  List<MockTest> mockTests = [];

  // ── PYQ ────────────────────────────────────────────────────
  List<PYQEntry> pyqEntries = [];

  // ── Services ───────────────────────────────────────────────
  final DatabaseService _db = DatabaseService();
  final NotificationService _notif = NotificationService();
  final TTSService _tts = TTSService();

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await _db.init();
    await _notif.init();
    await _tts.init();
    await _loadPrefs();
    await _checkMidnightReset();
    await _loadSubjectLogs();
    await _loadMockTests();
    await _loadPYQEntries();
    await _scheduleNotifications();
    notifyListeners();
  }

  // ── Load Preferences ───────────────────────────────────────
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    studentName = prefs.getString('studentName') ?? 'Student';
    targetAIR = prefs.getInt('targetAIR') ?? 100;
    dailyHoursTarget = prefs.getDouble('dailyHoursTarget') ?? 8.0;
    currentStreak = prefs.getInt('currentStreak') ?? 0;
    bestStreak = prefs.getInt('bestStreak') ?? 0;
    _lastResetDate = prefs.getString('lastResetDate') ?? '';

    final startMs = prefs.getInt('startDate');
    if (startMs != null) startDate = DateTime.fromMillisecondsSinceEpoch(startMs);

    final examMs = prefs.getInt('examDate');
    if (examMs != null) examDate = DateTime.fromMillisecondsSinceEpoch(examMs);

    // Load slot done states
    for (var slot in slots) {
      slot.isDone = prefs.getBool('slot_${slot.id}_done') ?? false;
      slot.subject = prefs.getString('slot_${slot.id}_subject') ?? slot.subject;
      slot.startTime = prefs.getString('slot_${slot.id}_start') ?? slot.startTime;
      slot.endTime = prefs.getString('slot_${slot.id}_end') ?? slot.endTime;
    }
  }

  // ── Midnight Reset ─────────────────────────────────────────
  Future<void> _checkMidnightReset() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    if (_lastResetDate != today) {
      final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
      // Check if yesterday was complete (6+ slots)
      final doneCount = slots.where((s) => s.isDone && !s.isBreak).length;
      if (doneCount >= 6 || _lastResetDate == yesterday) {
        // Was complete yesterday
        if (_lastResetDate == yesterday) {
          currentStreak++;
          if (currentStreak > bestStreak) bestStreak = currentStreak;
        }
      } else if (_lastResetDate.isNotEmpty && _lastResetDate != yesterday) {
        currentStreak = 0; // Missed a day
      }

      // Reset slots
      for (var slot in slots) {
        slot.isDone = false;
        prefs.remove('slot_${slot.id}_done');
      }
      _lastResetDate = today;
      prefs.setString('lastResetDate', today);
      prefs.setInt('currentStreak', currentStreak);
      prefs.setInt('bestStreak', bestStreak);
    }
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // ── Toggle Slot ────────────────────────────────────────────
  Future<void> toggleSlot(int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    final slot = slots.firstWhere((s) => s.id == slotId);
    slot.isDone = !slot.isDone;
    prefs.setBool('slot_${slotId}_done', slot.isDone);

    if (slot.isDone && !slot.isBreak) {
      await _tts.speak('बहुत अच्छा! ${slot.subject} slot complete हो गई। आगे बढ़ते रहो!');
      // Log time to subject
      await _db.insertSubjectLog(SubjectLog(
        date: _dateKey(DateTime.now()),
        subject: slot.subject,
        topic: slot.task,
        timeSpent: slot.hours,
      ));
      await _loadSubjectLogs();
    } else if (slot.isBreak && slot.isDone) {
      await _tts.speak('Break time! आराम करो, तुमने अच्छा काम किया!');
    }
    notifyListeners();
  }

  // ── Edit Slot ──────────────────────────────────────────────
  Future<void> editSlot(int slotId, String subject, String startTime, String endTime, String task) async {
    final prefs = await SharedPreferences.getInstance();
    final slot = slots.firstWhere((s) => s.id == slotId);
    slot.subject = subject;
    slot.startTime = startTime;
    slot.endTime = endTime;
    slot.task = task;
    prefs.setString('slot_${slotId}_subject', subject);
    prefs.setString('slot_${slotId}_start', startTime);
    prefs.setString('slot_${slotId}_end', endTime);
    notifyListeners();
  }

  // ── Theme Toggle ───────────────────────────────────────────
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // ── Save Settings ──────────────────────────────────────────
  Future<void> saveSettings({
    String? name,
    DateTime? start,
    DateTime? exam,
    int? air,
    double? hours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) { studentName = name; prefs.setString('studentName', name); }
    if (start != null) { startDate = start; prefs.setInt('startDate', start.millisecondsSinceEpoch); }
    if (exam != null) { examDate = exam; prefs.setInt('examDate', exam.millisecondsSinceEpoch); }
    if (air != null) { targetAIR = air; prefs.setInt('targetAIR', air); }
    if (hours != null) { dailyHoursTarget = hours; prefs.setDouble('dailyHoursTarget', hours); }
    notifyListeners();
  }

  // ── Computed Properties ────────────────────────────────────
  int get dayNumber => DateTime.now().difference(startDate).inDays + 1;
  int get totalDays => examDate.difference(startDate).inDays;
  int get daysRemaining => examDate.difference(DateTime.now()).inDays;

  String get currentPhase {
    final progress = dayNumber / totalDays;
    if (progress < 0.286) return 'Phase 1: Foundation';
    if (progress < 0.571) return 'Phase 2: Core Subjects';
    if (progress < 0.857) return 'Phase 3: Revision';
    return 'Phase 4: Final Sprint';
  }

  Color get phaseColor {
    final progress = dayNumber / totalDays;
    if (progress < 0.286) return const Color(0xFF00D4FF);
    if (progress < 0.571) return const Color(0xFF00FF9C);
    if (progress < 0.857) return const Color(0xFFBF5FFF);
    return const Color(0xFFFF6B35);
  }

  int get slotsCompleted => slots.where((s) => s.isDone).length;
  int get totalSlots => slots.length;
  double get todayHours => slots.where((s) => s.isDone).fold(0.0, (sum, s) => sum + s.hours);

  String get todayQuote {
    final idx = DateTime.now().day % hindiQuotes.length;
    return hindiQuotes[idx];
  }

  // ── DB Loaders ─────────────────────────────────────────────
  Future<void> _loadSubjectLogs() async {
    subjectLogs = await _db.getSubjectLogs();
    notifyListeners();
  }

  Future<void> _loadMockTests() async {
    mockTests = await _db.getMockTests();
    notifyListeners();
  }

  Future<void> _loadPYQEntries() async {
    pyqEntries = await _db.getPYQEntries();
    notifyListeners();
  }

  Future<void> addSubjectLog(SubjectLog log) async {
    await _db.insertSubjectLog(log);
    await _loadSubjectLogs();
  }

  Future<void> addMockTest(MockTest test) async {
    await _db.insertMockTest(test);
    await _loadMockTests();
  }

  Future<void> addPYQEntry(PYQEntry entry) async {
    await _db.insertPYQEntry(entry);
    await _loadPYQEntries();
  }

  // ── Notifications ──────────────────────────────────────────
  Future<void> _scheduleNotifications() async {
    await _notif.scheduleAll(slots);
  }

  // ── TTS ────────────────────────────────────────────────────
  Future<void> speakMotivation() async {
    await _tts.speak(todayQuote);
  }
}
