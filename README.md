# TaskFlow
* Vibe Coded using Claude
A native macOS menu bar app for managing daily tasks, long-term goals, and quick notes. Lives in your menu bar, slides open from the right edge of your screen, and optionally shows a desktop widget with a clock and task summary.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green) ![SwiftData](https://img.shields.io/badge/SwiftData-✓-green) [![Release](https://img.shields.io/github/v/release/fathah/task-flow-macos?label=latest&color=brightgreen)](https://github.com/fathah/task-flow-macos/releases/latest)

## Download

Grab the latest prebuilt DMG from the **[Releases page](https://github.com/fathah/task-flow-macos/releases/latest)** — no build tools required.

1. Download `TaskFlow-vX.X.X.dmg` from the latest release
2. Open the DMG and drag **TaskFlow** to your **Applications** folder
3. On first launch, right-click the app and choose **Open** (the build is unsigned)

Requires macOS 14 (Sonoma) or later. All [past releases](https://github.com/fathah/task-flow-macos/releases) are also available.

## Features

- **Menu Bar App** — Click the checklist icon in your menu bar to open a sliding panel from the right edge of your screen. Click outside to dismiss.
- **Daily Tasks** — Add tasks, check them off, and track your completion with a progress ring.
- **Task History** — Completed tasks are automatically grouped by date in the History tab.
- **Goals** — Set 3-month, 6-month, and 1-year goals with sub-tasks and progress tracking.
- **Quick Notes** — Brain dump anything. Notes are sorted by creation time.
- **Desktop Widget** — Optional floating widget showing a clock, date, and today's pending tasks. Right-click the menu bar icon to toggle it.
- **Day Rollover** — When a new day starts, you're prompted to carry forward or clear unfinished tasks.
- **Local Only** — All data stays on your machine via SwiftData (SQLite). No accounts, no cloud.
- **Glassmorphic UI** — Vibrant teal gradient background with frosted glass cards using Apple's native `.ultraThinMaterial`.

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/desktop-task-widget.git
cd desktop-task-widget/TaskFlow
```

### 2. Install xcodegen (if you don't have it)

```bash
brew install xcodegen
```

### 3. Generate the Xcode project

```bash
xcodegen generate
```

This creates `TaskFlow.xcodeproj` from the `project.yml` spec.

### 4. Build and run

**Option A — Xcode:**
```bash
open TaskFlow.xcodeproj
```
Then press `Cmd + R` to build and run.

**Option B — Command line:**
```bash
xcodebuild -project TaskFlow.xcodeproj -scheme TaskFlow -configuration Debug build
```
Then open the built app:
```bash
open ~/Library/Developer/Xcode/DerivedData/TaskFlow-*/Build/Products/Debug/TaskFlow.app
```

### 5. Using the app

- **Left-click** the menu bar icon → opens the sliding panel
- **Right-click** the menu bar icon → menu with "Show/Hide Desktop Widget" and "Quit"
- Click **outside the panel** to close it
- The **desktop widget** is a floating window you can drag anywhere

## Project Structure

```
TaskFlow/
├── project.yml                  # xcodegen project spec
├── Info.plist                   # App config (LSUIElement = true, no dock icon)
├── Package.swift                # SPM manifest (for editor support)
└── Sources/TaskFlow/
    ├── TaskFlowApp.swift        # App entry point, AppDelegate, NSStatusItem
    ├── Models/
    │   ├── DailyTask.swift      # @Model — daily tasks with date, completion, sort order
    │   ├── Goal.swift           # @Model — goals with timeframe enum, sub-task relationship
    │   ├── GoalSubTask.swift    # @Model — sub-tasks belonging to a goal
    │   └── QuickNote.swift      # @Model — timestamped notes
    ├─��� Views/
    │   ├── ContentView.swift    # Root layout — sidebar + content area
    │   ├─�� SidebarView.swift    # Tab navigation (Today, History, Goals, Notes, Settings)
    │   ├── DesktopWidgetView.swift  # Floating clock + task summary widget
    │   ├── SettingsView.swift   # Launch at login, rollover time, export
    │   ├── Today/
    │   │   ├── TodayView.swift      # Today's tasks with input, progress ring, stats
    │   ��   ├── TaskRowView.swift    # Individual task with animated checkbox
    │   │   └── DayRolloverView.swift # Carry-forward prompt for unfinished tasks
    │   ├── History/
    │   │   └── HistoryView.swift    # Completed tasks grouped by date
    │   ├── Goals/
    │   │   ��── GoalsView.swift      # Goals grouped by timeframe
    │   │   ├── GoalRowView.swift    # Goal card with progress bar
    │   │   ├── GoalDetailView.swift # Expanded goal with sub-tasks
    │   │   └── AddGoalView.swift    # Add goal button + dialog
    │   └── Notes/
    │       ├── NotesView.swift      # Notes list with inline input
    │       └── NoteRowView.swift    # Note card with accent line
    ├── Services/
    │   └── DayRolloverService.swift # Detects new day, manages carry-forward
    └── Utilities/
        ├── Theme.swift              # Colors, dimensions, fonts, GlassCard modifier
        ├���─ SlidingPanelController.swift  # NSPanel that slides from right edge
        ├── DesktopWidgetController.swift # Floating desktop widget window
        ├── MenuBarIconManager.swift      # Menu bar icon state
        └── InputDialog.swift             # NSAlert-based input dialogs
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData (SQLite) |
| Window Management | AppKit (NSPanel, NSStatusItem) |
| Project Generation | xcodegen |
| Minimum Target | macOS 14.0 Sonoma |
| Font | [Manrope](https://fonts.google.com/specimen/Manrope) (falls back to system font if not installed) |

## Data Storage

All data is stored locally at:
```
~/Library/Application Support/default.store
```

This is a standard SwiftData/SQLite database. You can export your data as JSON from Settings.

## Customization

### Changing the color scheme

Edit `Sources/TaskFlow/Utilities/Theme.swift`. The main colors to change:

```swift
// Background gradient
static let bgTop = Color(...)
static let bgMid = Color(...)
static let bgBottom = Color(...)

// Primary accent
static let accent = Color(...)
```

### Changing the font

Replace `"Manrope"` in the `Theme.manrope()` function with any font name. Install the font in `Sources/TaskFlow/Resources/` and reference it in `Info.plist` under `ATSApplicationFontsPath`.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
