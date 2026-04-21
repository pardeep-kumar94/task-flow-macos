# TaskFlow — macOS Menu Bar Task Widget

## Overview

A native macOS menu bar app for managing daily tasks, long-term goals, and quick notes. Lives in the menu bar as a color-coded icon; clicking it opens a glassmorphic popover with sidebar navigation.

**Target:** macOS 14+ (Sonoma)
**Tech:** SwiftUI + SwiftData
**Font:** Manrope
**Theme:** Ocean Blue glassmorphic (dark, translucent panels, `#38bdf8` accent)

## Features

### 1. Menu Bar Icon

- Color-coded status indicator:
  - Green: all daily tasks complete
  - Orange: tasks remaining
  - Red: overdue tasks from previous day (unresolved rollover)
- Click opens a popover (not a window)

### 2. Popover Layout

- **Width:** ~380px
- **Navigation:** Icon sidebar on the left (56px wide)
  - Today (checkmark icon)
  - Goals (target icon)
  - Notes (pencil icon)
  - Settings (gear icon, bottom)
- **Style:** Glassmorphic — translucent backgrounds (`rgba(255,255,255,0.05-0.06)`), subtle borders (`rgba(255,255,255,0.08)`), blur backdrop, soft glow on active elements

### 3. Today View

- Header showing "Today" with task count and completion percentage badge
- Task list with checkboxes
  - Tap checkbox to complete (strikethrough + dimmed)
  - Inline text field to add new tasks via "+ Add task" button
- Tasks persist for the current day

### 4. Day Rollover

- Triggered when the app detects a new day with uncompleted tasks from yesterday
- Shows a "Carry forward?" prompt listing yesterday's incomplete tasks
- Each task has a checkbox (pre-checked) — user deselects tasks they want to drop
- Two actions: "Keep Selected" (carries forward checked tasks) and "Clear All" (fresh start)

### 5. Goals View

- Goals grouped by timeframe: 3 Month, 6 Month, 1 Year
- Each goal has:
  - Title
  - Sub-tasks (milestones) — simple checklist items under the goal
  - Progress bar showing sub-task completion (e.g., 4/6)
- "+ Add goal" button at the bottom — prompts for title and timeframe

### 6. Quick Notes

- Text input field at the top for fast capture
- Notes displayed in reverse chronological order
- Each note shows text and relative timestamp ("2 hours ago", "Yesterday")
- Notes are persistent (not daily — they stick around until deleted)
- Swipe or button to delete individual notes

### 7. Settings

- Launch at login toggle
- Day rollover time (default: midnight, configurable)
- Data export (JSON dump)

## Data Model (SwiftData)

### DailyTask
- `id: UUID`
- `title: String`
- `isCompleted: Bool`
- `date: Date` (the day this task belongs to)
- `createdAt: Date`
- `sortOrder: Int`

### Goal
- `id: UUID`
- `title: String`
- `timeframe: GoalTimeframe` (enum: threeMonth, sixMonth, oneYear)
- `createdAt: Date`
- `subTasks: [GoalSubTask]` (relationship)

### GoalSubTask
- `id: UUID`
- `title: String`
- `isCompleted: Bool`
- `sortOrder: Int`
- `goal: Goal` (inverse relationship)

### QuickNote
- `id: UUID`
- `text: String`
- `createdAt: Date`

### GoalTimeframe (enum)
- `threeMonth`
- `sixMonth`
- `oneYear`

## Architecture

```
TaskFlowApp (SwiftUI App)
├── MenuBarExtra (menu bar icon + popover)
│   └── ContentView
│       ├── SidebarView (icon navigation)
│       └── Main content area
│           ├── TodayView
│           │   ├── TaskRowView
│           │   └── AddTaskView
│           ├── GoalsView
│           │   ├── GoalGroupView (per timeframe)
│           │   ├── GoalRowView
│           │   └── AddGoalView
│           ├── NotesView
│           │   ├── NoteInputView
│           │   └── NoteRowView
│           └── SettingsView
├── Models/ (SwiftData models)
├── Services/
│   └── DayRolloverService (detects new day, triggers rollover prompt)
└── Utilities/
    └── MenuBarIconManager (updates icon color based on task status)
```

## Storage

- Local only via SwiftData (backed by SQLite)
- Data stored in `~/Library/Application Support/TaskFlow/`
- No cloud sync

## Key Behaviors

- App has no dock icon (LSUIElement = true) — menu bar only
- Popover dismisses when clicking outside
- Day rollover check runs on app launch and on a timer (every hour)
- Menu bar icon color updates reactively when tasks change
- Keyboard shortcut to open popover (configurable, default: Cmd+Shift+T)
