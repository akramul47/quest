# Quest - AI Coding Agent Instructions

## Project Overview
Quest is a cross-platform Flutter productivity app ("Your life, organized by intent") combining task management, habit tracking, and focus tools. It runs on Windows, macOS, Linux, Android, iOS, and Web with platform-specific optimizations.

## Architecture & State Management

### Provider Pattern
All state is managed through Provider with four main providers in `lib/providers/`:
- `TodoList` - Task management (extends `ChangeNotifier`)
- `HabitList` - Habit tracking with streak calculations
- `FocusProvider` - Pomodoro timer with session history
- `ThemeProvider` - Theme switching

Providers are initialized in `main.dart` using `MultiProvider`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TodoList()),
    ChangeNotifierProvider(create: (_) => HabitList()),
    ChangeNotifierProvider(create: (_) => FocusProvider()..initialize()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  // ...
)
```

### Navigation Structure
- Bottom navigation on mobile (`_buildMobileLayout()`)
- Tab navigation on tablet/desktop (`_buildTabletDesktopLayout()`)
- Four main screens: HomeScreen (TO-DO), HabitsScreen, FocusScreen, QuestScreen
- See `lib/screens/main_navigation_screen.dart` for responsive layout switching

## Platform-Specific Patterns

### Conditional Imports for Cross-Platform Compatibility
Use stub files to handle platform-specific imports:
```dart
import 'package:window_manager/window_manager.dart'
    if (dart.library.html) '../services/window_manager_stub.dart';
```
All platform-specific stubs are in `lib/services/*_stub.dart`.

### Platform Detection Helpers
From `lib/main.dart`:
```dart
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isDesktopPlatform => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
```

Use `ResponsiveLayout` class (`lib/Utils/responsive_layout.dart`) for device-specific layouts:
- `ResponsiveLayout.getDeviceType(context)` returns `DeviceType.mobile/tablet/desktop`
- Breakpoints: mobile < 600px, tablet < 900px, desktop >= 900px

### Windows-Specific Features
- **Always-on-top toggle** in `WindowControlsBar` widget
- **Window state persistence** via `StorageService.saveWindowState()`
- **Safe window positioning** prevents windows from appearing off-screen (see `_getSafeWindowPosition()` in `main.dart`)
- **Custom title bar** with hidden native controls (`setTitleBarStyle(TitleBarStyle.hidden)`)
- **System tray integration** in `lib/services/system_tray.dart`

## Data Models & Storage

### Model Structure
All models in `lib/models/`:
- `Todo` - Has priority enum (`mainQuest` vs `sideQuest`)
- `Habit` - Supports two types: `HabitType.boolean` (yes/no) or `HabitType.measurable` (numeric values)
  - History stored as `Map<String, dynamic>` with ISO date strings as keys
  - Streak calculation via `getCurrentStreak()` method
- `TimerState` - Focus session state with `SessionType` enum (focus/shortBreak/longBreak)

### Persistence
`StorageService` (`lib/services/storage_service.dart`) uses:
- `shared_preferences` for simple key-value storage (window state, settings)
- JSON serialization for todos/habits via `toJson()`/`fromJson()` methods
- Archive system for completed tasks in application documents directory

## UI & Theming

### Glass Morphism Design System
Theme constants in `lib/Utils/app_theme.dart`:
- Light mode: `glassBackground` (0x99FFFFFF), `taskCardBackground` (0x88FFFFFF)
- Dark mode: Pure black AMOLED backgrounds (0xFF000000), subtle gradients
- Glass effects use `BoxDecoration` with border, blur, and transparency

### Theme Switching
- Dynamic system UI overlay colors configured based on theme in `MaterialApp`
- Edge-to-edge mode enabled on mobile platforms
- Use `Theme.of(context).brightness` to check current mode

### Custom Widgets
Key reusable widgets in `lib/widgets/`:
- `WindowControlsBar` - Desktop window controls (minimize, close, always-on-top toggle)
- `glass_task_card.dart` - Glass morphism task cards
- `circular_timer_display.dart` - Focus timer with smooth sub-second progress interpolation
- `completion_celebration.dart` - Confetti animations for task completion
- `animated_boom_logo.dart` - Animated BOOM logo with wavy borders (top/bottom waves animate for 3 seconds)

### Wave Animation Pattern
The app uses a consistent wavy animation style:
- `circular_timer_display.dart` demonstrates the core wave animation using `CustomPainter`
- Waves are created using sine functions: `math.sin(angle * frequency + wavePhase) * amplitude`
- Animation controllers manage phase changes over time for smooth flowing motion
- `animated_boom_logo.dart` applies the same pattern to horizontal waves on the About page

## Development Workflows

### Running the App
```powershell
flutter run -d windows  # or macos, chrome, android, etc.
flutter build windows --release
```

### Dependencies
Notable packages:
- `window_manager` - Desktop window control (Windows/macOS/Linux)
- `glass_kit` - Glass morphism effects
- `confetti` - Celebration animations
- `google_fonts` - Typography
- `visibility_detector` - Trigger animations when widgets become visible

### Testing
Test files in `test/` directory. Run with:
```powershell
flutter test
```

## Key Conventions

### File Organization
- Screens in `lib/screens/` (one per main navigation tab)
- Providers in `lib/providers/` (extend `ChangeNotifier`)
- Models in `lib/models/` with JSON serialization
- Services in `lib/services/` for platform interactions
- Utils in `lib/Utils/` (note: capitalized "U")
- Widgets in `lib/widgets/` (reusable components)

### Naming Patterns
- Provider classes: `*Provider` or descriptive names like `TodoList`, `HabitList`
- Screens: `*Screen` suffix
- Models: Domain entities without suffixes (Todo, Habit)
- Services: `*Service` suffix

### State Updates
Always call `notifyListeners()` after modifying provider state. Providers handle persistence automatically (e.g., `HabitList` methods save to storage).

## Common Tasks

### Adding a New Feature
1. Create model in `lib/models/` with JSON serialization
2. Create provider in `lib/providers/` extending `ChangeNotifier`
3. Add provider to `MultiProvider` in `main.dart`
4. Create screen in `lib/screens/` using responsive layout patterns
5. Add persistence in `StorageService` if needed

### Platform-Specific Code
Always check platform before using platform-specific APIs:
```dart
if (!kIsWeb && Platform.isWindows) {
  // Windows-specific code
}
```

### Responsive UI
Use `ResponsiveLayout` helpers and provide separate layouts for mobile vs tablet/desktop in each screen's build method.
