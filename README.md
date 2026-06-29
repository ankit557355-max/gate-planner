# 🎯 GATE Daily Planner — Flutter App

**AIR 100 study tracker with Pomodoro, Hindi voice alarms, charts & more**

---

## 📱 App Features

### 🏠 Today Screen
- Day counter (Day X of Y)
- Current phase badge (Phase 1–4)
- 8 editable study slots with tick buttons
- Live progress ring (slots done / total)
- Hours studied today
- 🔥 Streak banner
- 💫 Daily Hindi motivation quote
- 🎙️ Voice button to hear quote aloud

### ⏱️ Timer Screen
- **Pomodoro** (custom duration: 5–90 min) + 5 min break
- **Simple Stopwatch** with hours:min:sec
- **Subject selector** — auto-logs time to subject
- Animated glowing ring
- 🍅 Pomodoro counter (8 tomatoes)
- Hindi voice on completion: *"Pomodoro complete! Break lo!"*

### 📊 Progress Screen
- Weekly bar chart (hours per day)
- Subject-wise pie chart
- Mock test line chart (score trend)
- Stats grid: Day, Streak, Best, Days Remaining

### 📝 Mock Tests Screen
- Log: Score, Total, Platform, Rank
- Accuracy color coding (green/orange/red)
- Average & best score cards
- Supports: MADE EASY, Testbook, ACE, GATE Official

### 📄 PYQ Tracker Screen
- Log by subject + year (2010–2024)
- Accuracy % per subject
- Progress bar & year count
- Weak subjects highlighted in red

### ⚙️ Settings Screen
- Dark / Light theme toggle
- Edit name, target AIR, daily hours
- Set start date & exam date
- Notification controls

---

## 🔔 Notifications (Hindi)
| Time | Message |
|------|---------|
| 6:00 AM | Morning motivation |
| Each slot start | "Subject शुरू करो!" |
| 5:00 PM | "Break time!" |
| 11:50 PM | "Progress save हो रहा है..." |

---

## 🛠️ How to Build APK

### Prerequisites
- Flutter SDK 3.x → https://flutter.dev/docs/get-started/install
- Android Studio
- JDK 17+

### Steps

```bash
# 1. Clone / extract this project
cd gate_planner

# 2. Get dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install on phone
```bash
flutter install
# OR copy APK to phone and install manually
```

---

## 🆓 Free Online Build (No PC needed)

### Option A — FlutLab.io
1. Go to https://flutlab.io
2. Create new project → paste all files
3. Build → Download APK

### Option B — Replit
1. Go to https://replit.com → New Repl → Flutter
2. Upload these files
3. Run `flutter build apk`

### Option C — GitHub + Codemagic (100% free)
1. Push to GitHub repo
2. Connect at https://codemagic.io
3. Build triggered automatically → APK emailed to you

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry + bottom nav
├── theme/
│   └── app_theme.dart        # Dark/Light futuristic themes
├── models/
│   └── models.dart           # Data models + default slots
├── services/
│   ├── app_state.dart        # State management (Provider)
│   ├── database_service.dart # SQLite local storage
│   ├── notification_service.dart # Push notifications
│   └── tts_service.dart      # Hindi Text-to-Speech
└── screens/
    ├── home_screen.dart       # Today's slots
    ├── timer_screen.dart      # Pomodoro + Stopwatch
    ├── progress_screen.dart   # Charts & stats
    ├── mock_pyq_screens.dart  # Mock tests + PYQ tracker
    └── settings_screen.dart   # Settings
```

---

## 🎨 Design System
- **Background:** `#050B1F` (deep space navy)
- **Cards:** `#111D45` (dark glass)
- **Neon Blue:** `#00D4FF`
- **Neon Green:** `#00FF9C`
- **Neon Purple:** `#BF5FFF`
- **Neon Orange:** `#FF6B35`
- **Font:** Orbitron (headers) + Poppins (body)

---

## 📦 Dependencies
```yaml
provider: ^6.1.1          # State management
sqflite: ^2.3.0           # Local database
flutter_local_notifications # Push notifications
flutter_tts: ^4.0.2       # Hindi voice
fl_chart: ^0.68.0         # Charts
flutter_animate: ^4.5.0   # Animations
google_fonts: ^6.2.1      # Orbitron + Poppins
percent_indicator: ^4.2.3 # Progress rings
```

---

Made for GATE CE aspirants targeting AIR 100 🎯
