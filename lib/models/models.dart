// ─── SLOT MODEL ───────────────────────────────────────────────
class StudySlot {
  final int id;
  String startTime;
  String endTime;
  String subject;
  String task;
  double hours;
  bool isDone;
  bool isBreak;

  StudySlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.task,
    required this.hours,
    this.isDone = false,
    this.isBreak = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'task': task,
    'hours': hours,
    'isDone': isDone ? 1 : 0,
    'isBreak': isBreak ? 1 : 0,
  };

  factory StudySlot.fromMap(Map<String, dynamic> m) => StudySlot(
    id: m['id'],
    startTime: m['startTime'],
    endTime: m['endTime'],
    subject: m['subject'],
    task: m['task'],
    hours: m['hours'],
    isDone: m['isDone'] == 1,
    isBreak: m['isBreak'] == 1,
  );
}

// ─── SUBJECT LOG MODEL ────────────────────────────────────────
class SubjectLog {
  final int? id;
  final String date;
  final String subject;
  final String topic;
  final double timeSpent;

  SubjectLog({
    this.id,
    required this.date,
    required this.subject,
    required this.topic,
    required this.timeSpent,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'subject': subject,
    'topic': topic,
    'timeSpent': timeSpent,
  };
}

// ─── MOCK TEST MODEL ─────────────────────────────────────────
class MockTest {
  final int? id;
  final String date;
  final double score;
  final double total;
  final String platform;
  final String? rank;
  final String notes;

  MockTest({
    this.id,
    required this.date,
    required this.score,
    required this.total,
    required this.platform,
    this.rank,
    this.notes = '',
  });

  double get percentage => (score / total) * 100;

  Map<String, dynamic> toMap() => {
    'date': date,
    'score': score,
    'total': total,
    'platform': platform,
    'rank': rank ?? '',
    'notes': notes,
  };
}

// ─── PYQ ENTRY MODEL ─────────────────────────────────────────
class PYQEntry {
  final int? id;
  final String subject;
  final int year;
  final int attempted;
  final int correct;

  PYQEntry({
    this.id,
    required this.subject,
    required this.year,
    required this.attempted,
    required this.correct,
  });

  double get accuracy => attempted > 0 ? (correct / attempted) * 100 : 0;

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'year': year,
    'attempted': attempted,
    'correct': correct,
  };
}

// ─── POMODORO SESSION MODEL ───────────────────────────────────
class PomodoroSession {
  final String subject;
  final int completedPomodoros;
  final double totalMinutes;
  final String date;

  PomodoroSession({
    required this.subject,
    required this.completedPomodoros,
    required this.totalMinutes,
    required this.date,
  });
}

// ─── DEFAULT SLOTS ────────────────────────────────────────────
List<StudySlot> getDefaultSlots() => [
  StudySlot(id: 1, startTime: '06:00', endTime: '08:00', subject: 'Revision', task: 'Previous topic revision / formulas', hours: 2),
  StudySlot(id: 2, startTime: '08:00', endTime: '11:00', subject: 'Geotechnical Engineering', task: 'New topic theory + derivations', hours: 3),
  StudySlot(id: 3, startTime: '11:00', endTime: '13:00', subject: 'Problem Solving', task: 'Textbook problems', hours: 2),
  StudySlot(id: 4, startTime: '14:00', endTime: '17:00', subject: 'Engineering Mathematics', task: 'Theory + practice questions', hours: 3),
  StudySlot(id: 5, startTime: '17:00', endTime: '18:00', subject: '☕ Break', task: 'Rest + Exercise — mandatory!', hours: 1, isBreak: true),
  StudySlot(id: 6, startTime: '18:00', endTime: '20:00', subject: 'Practice', task: '50 questions on today\'s topic', hours: 2),
  StudySlot(id: 7, startTime: '20:30', endTime: '21:30', subject: 'Short Notes', task: 'Make formula sheet / notes', hours: 1),
  StudySlot(id: 8, startTime: '21:30', endTime: '22:00', subject: 'Planning', task: 'Plan tomorrow + review today', hours: 0.5),
];

// ─── SUBJECTS LIST ────────────────────────────────────────────
const List<String> gateSubjects = [
  'Geotechnical Engineering',
  'Engineering Mathematics',
  'Structural Analysis',
  'Strength of Materials',
  'RCC & Steel Design',
  'Fluid Mechanics',
  'Hydraulics',
  'Environmental Engineering',
  'Transportation Engineering',
  'Surveying',
  'Building Materials',
  'General Aptitude',
  'Revision',
  'Problem Solving',
  'Mock Test',
  'Other',
];

// ─── HINDI MOTIVATION QUOTES ──────────────────────────────────
const List<String> hindiQuotes = [
  'मेहनत वो चाबी है जो किस्मत का ताला खोलती है।',
  'सपने देखो, काम करो, AIR 100 पाओ!',
  'हर सुबह एक नया मौका है बेहतर बनने का।',
  'GATE की तैयारी आसान नहीं, लेकिन तुम इससे भी आसान नहीं हो।',
  'एक दिन की मेहनत एक कदम आगे, रोज़ चलो, मंज़िल पास है।',
  'थकान तब आती है जब हम हार मान लेते हैं।',
  'आज का पसीना कल की सफलता है।',
  'Rank नहीं, ज्ञान पहले — Rank खुद चली आएगी।',
  'जितना पढ़ोगे, उतना जीतोगे।',
  'Consistency is the key. आज भी पढ़ो!',
  'तुम्हारी मेहनत किसी दिन तुम्हें रुलाएगी — खुशी के आँसू।',
  'असफलता रास्ता बताती है, मंज़िल नहीं।',
  'हर सवाल का जवाब है, बस ढूंढते रहो।',
  'GATE एक exam नहीं, एक journey है।',
  'आज का काम आज — कल पर मत छोड़ो।',
];
