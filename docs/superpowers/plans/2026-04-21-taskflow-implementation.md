# TaskFlow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native macOS menu bar app for managing daily tasks, long-term goals, and quick notes with a glassmorphic Ocean Blue UI.

**Architecture:** SwiftUI app using `MenuBarExtra` for the menu bar popover, SwiftData for local persistence, sidebar navigation between four views (Today, Goals, Notes, Settings). No dock icon — menu bar only.

**Tech Stack:** Swift, SwiftUI, SwiftData, macOS 14+ (Sonoma), Manrope font

---

## File Structure

```
TaskFlow/
├── TaskFlowApp.swift              — App entry point, MenuBarExtra, SwiftData container
├── Models/
│   ├── DailyTask.swift            — SwiftData model for daily tasks
│   ├── Goal.swift                 — SwiftData model for goals + GoalTimeframe enum
│   ├── GoalSubTask.swift          — SwiftData model for goal sub-tasks
│   └── QuickNote.swift            — SwiftData model for notes
├── Views/
│   ├── ContentView.swift          — Root view: sidebar + main content area
│   ├── SidebarView.swift          — Icon sidebar navigation
│   ├── Today/
│   │   ├── TodayView.swift        — Daily task list with header + add button
│   │   ├── TaskRowView.swift      — Single task row with checkbox
│   │   └── DayRolloverView.swift  — Carry-forward prompt for uncompleted tasks
│   ├── Goals/
│   │   ├── GoalsView.swift        — Goals grouped by timeframe
│   │   ├── GoalRowView.swift      — Single goal with progress bar
│   │   ├── GoalDetailView.swift   — Expanded goal showing sub-tasks
│   │   └── AddGoalView.swift      — Form to add a new goal
│   ├── Notes/
│   │   ├── NotesView.swift        — Note list with input field
│   │   └── NoteRowView.swift      — Single note with timestamp
│   └── SettingsView.swift         — Settings toggles
├── Services/
│   └── DayRolloverService.swift   — Detects new day, manages rollover state
├── Utilities/
│   └── Theme.swift                — Colors, fonts, glassmorphic style constants
├── Resources/
│   └── Manrope.ttf               — Bundled Manrope font (or use system registration)
└── Info.plist                     — LSUIElement=true, font registration
```

---

### Task 1: Create Xcode Project Scaffold

**Files:**
- Create: `TaskFlow.xcodeproj` (via Xcode project generation)
- Create: `TaskFlow/TaskFlowApp.swift`
- Create: `TaskFlow/Info.plist`

- [ ] **Step 1: Generate the Xcode project**

Create a new SwiftUI macOS app project. Since we need specific Xcode project settings, use the command line:

```bash
mkdir -p TaskFlow/TaskFlow
```

Create the Swift package-like structure manually. We'll use `xcodegen` or create the project in Xcode. For this plan, create files and then open in Xcode to generate the project.

- [ ] **Step 2: Create the app entry point**

Create `TaskFlow/TaskFlow/TaskFlowApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            Text("TaskFlow — Coming Soon")
                .padding()
        }
        .menuBarExtraStyle(.window)
    }
}
```

- [ ] **Step 3: Configure Info.plist for menu-bar-only app**

Create `TaskFlow/TaskFlow/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
    <key>ATSApplicationFontsPath</key>
    <string>Fonts</string>
</dict>
</plist>
```

- [ ] **Step 4: Build and run to verify menu bar icon appears**

Run: `Cmd+R` in Xcode (or `xcodebuild -scheme TaskFlow -destination 'platform=macOS' build`)
Expected: App launches with no dock icon, a checklist icon appears in the menu bar, clicking it shows "TaskFlow — Coming Soon".

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/
git commit -m "feat: scaffold Xcode project with MenuBarExtra"
```

---

### Task 2: Theme and Style Constants

**Files:**
- Create: `TaskFlow/TaskFlow/Utilities/Theme.swift`

- [ ] **Step 1: Create the theme file with all design tokens**

Create `TaskFlow/TaskFlow/Utilities/Theme.swift`:

```swift
import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Colors {
        static let accent = Color(red: 56/255, green: 189/255, blue: 248/255) // #38bdf8
        static let accentGlow = accent.opacity(0.1)

        static let background = Color(red: 12/255, green: 25/255, blue: 41/255) // #0c1929
        static let backgroundGradientEnd = Color(red: 13/255, green: 31/255, blue: 61/255) // #0d1f3d

        static let cardBackground = Color.white.opacity(0.05)
        static let cardBorder = Color.white.opacity(0.08)
        static let cardBackgroundHover = Color.white.opacity(0.07)

        static let sidebarBackground = Color.white.opacity(0.03)
        static let sidebarBorder = Color.white.opacity(0.06)

        static let sidebarIconBackground = Color.white.opacity(0.04)
        static let sidebarIconBorder = Color.white.opacity(0.06)
        static let sidebarIconActiveBackground = accent.opacity(0.15)
        static let sidebarIconActiveBorder = accent.opacity(0.3)

        static let textPrimary = Color.white.opacity(0.94)
        static let textSecondary = Color.white.opacity(0.55)
        static let textMuted = Color.white.opacity(0.33)
        static let textDone = Color.white.opacity(0.33)

        static let checkboxBorder = Color.white.opacity(0.15)
        static let checkboxCheckedBackground = accent.opacity(0.15)
        static let checkboxCheckedBorder = accent.opacity(0.4)

        static let progressBarBackground = Color.white.opacity(0.06)
        static let progressBarFill = accent

        // Menu bar icon states
        static let statusGreen = Color(red: 74/255, green: 222/255, blue: 128/255)
        static let statusOrange = Color(red: 251/255, green: 146/255, blue: 60/255)
        static let statusRed = Color(red: 248/255, green: 113/255, blue: 113/255)

        static let badgeBackground = accent.opacity(0.08)
        static let badgeBorder = accent.opacity(0.15)
        static let badgeText = accent.opacity(0.8)

        static let addButtonBorder = Color.white.opacity(0.08)
        static let addButtonText = Color.white.opacity(0.2)

        static let inputBackground = accent.opacity(0.05)
        static let inputBorder = accent.opacity(0.1)
    }

    // MARK: - Dimensions
    enum Dimensions {
        static let popoverWidth: CGFloat = 380
        static let popoverMinHeight: CGFloat = 400
        static let sidebarWidth: CGFloat = 56
        static let sidebarIconSize: CGFloat = 34
        static let sidebarIconCornerRadius: CGFloat = 9
        static let cardCornerRadius: CGFloat = 10
        static let checkboxSize: CGFloat = 18
        static let checkboxCornerRadius: CGFloat = 5
        static let contentPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 6
    }

    // MARK: - Font
    static func manrope(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Manrope", size: size).weight(weight)
    }
}

// MARK: - Glassmorphic Card Modifier
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
```

- [ ] **Step 2: Build to verify no compilation errors**

Run: `xcodebuild -scheme TaskFlow -destination 'platform=macOS' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add TaskFlow/TaskFlow/Utilities/Theme.swift
git commit -m "feat: add theme constants for Ocean Blue glassmorphic design"
```

---

### Task 3: SwiftData Models

**Files:**
- Create: `TaskFlow/TaskFlow/Models/DailyTask.swift`
- Create: `TaskFlow/TaskFlow/Models/Goal.swift`
- Create: `TaskFlow/TaskFlow/Models/GoalSubTask.swift`
- Create: `TaskFlow/TaskFlow/Models/QuickNote.swift`

- [ ] **Step 1: Create DailyTask model**

Create `TaskFlow/TaskFlow/Models/DailyTask.swift`:

```swift
import Foundation
import SwiftData

@Model
final class DailyTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var date: Date
    var createdAt: Date
    var sortOrder: Int

    init(title: String, date: Date = .now, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.date = Calendar.current.startOfDay(for: date)
        self.createdAt = .now
        self.sortOrder = sortOrder
    }
}
```

- [ ] **Step 2: Create Goal and GoalTimeframe**

Create `TaskFlow/TaskFlow/Models/Goal.swift`:

```swift
import Foundation
import SwiftData

enum GoalTimeframe: String, Codable, CaseIterable {
    case threeMonth = "3 Month"
    case sixMonth = "6 Month"
    case oneYear = "1 Year"

    var sortOrder: Int {
        switch self {
        case .threeMonth: 0
        case .sixMonth: 1
        case .oneYear: 2
        }
    }
}

@Model
final class Goal {
    var id: UUID
    var title: String
    var timeframe: GoalTimeframe
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \GoalSubTask.goal)
    var subTasks: [GoalSubTask]

    init(title: String, timeframe: GoalTimeframe) {
        self.id = UUID()
        self.title = title
        self.timeframe = timeframe
        self.createdAt = .now
        self.subTasks = []
    }

    var completedSubTaskCount: Int {
        subTasks.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !subTasks.isEmpty else { return 0 }
        return Double(completedSubTaskCount) / Double(subTasks.count)
    }
}
```

- [ ] **Step 3: Create GoalSubTask model**

Create `TaskFlow/TaskFlow/Models/GoalSubTask.swift`:

```swift
import Foundation
import SwiftData

@Model
final class GoalSubTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var goal: Goal?

    init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.sortOrder = sortOrder
    }
}
```

- [ ] **Step 4: Create QuickNote model**

Create `TaskFlow/TaskFlow/Models/QuickNote.swift`:

```swift
import Foundation
import SwiftData

@Model
final class QuickNote {
    var id: UUID
    var text: String
    var createdAt: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = .now
    }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: .now)
    }
}
```

- [ ] **Step 5: Register models in the app entry point**

Update `TaskFlow/TaskFlow/TaskFlowApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            Text("TaskFlow — Coming Soon")
                .padding()
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
    }
}
```

- [ ] **Step 6: Build to verify models compile and container initializes**

Run: `xcodebuild -scheme TaskFlow -destination 'platform=macOS' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 7: Commit**

```bash
git add TaskFlow/TaskFlow/Models/ TaskFlow/TaskFlow/TaskFlowApp.swift
git commit -m "feat: add SwiftData models for tasks, goals, and notes"
```

---

### Task 4: Sidebar Navigation

**Files:**
- Create: `TaskFlow/TaskFlow/Views/SidebarView.swift`
- Create: `TaskFlow/TaskFlow/Views/ContentView.swift`
- Modify: `TaskFlow/TaskFlow/TaskFlowApp.swift`

- [ ] **Step 1: Create SidebarView**

Create `TaskFlow/TaskFlow/Views/SidebarView.swift`:

```swift
import SwiftUI

enum SidebarTab: String, CaseIterable {
    case today
    case goals
    case notes
    case settings

    var icon: String {
        switch self {
        case .today: "checkmark"
        case .goals: "target"
        case .notes: "square.and.pencil"
        case .settings: "gearshape"
        }
    }

    var isBottom: Bool {
        self == .settings
    }
}

struct SidebarView: View {
    @Binding var selectedTab: SidebarTab

    var body: some View {
        VStack(spacing: 10) {
            ForEach(SidebarTab.allCases.filter { !$0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
            Spacer()
            ForEach(SidebarTab.allCases.filter { $0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 7)
        .frame(width: Theme.Dimensions.sidebarWidth)
        .background(Theme.Colors.sidebarBackground)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Theme.Colors.sidebarBorder),
            alignment: .trailing
        )
    }

    private func sidebarIcon(_ tab: SidebarTab) -> some View {
        let isActive = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            Image(systemName: tab.icon)
                .font(.system(size: 14))
                .frame(width: Theme.Dimensions.sidebarIconSize, height: Theme.Dimensions.sidebarIconSize)
                .background(isActive ? Theme.Colors.sidebarIconActiveBackground : Theme.Colors.sidebarIconBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.sidebarIconCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Dimensions.sidebarIconCornerRadius)
                        .stroke(isActive ? Theme.Colors.sidebarIconActiveBorder : Theme.Colors.sidebarIconBorder, lineWidth: 1)
                )
                .shadow(color: isActive ? Theme.Colors.accentGlow : .clear, radius: 6)
        }
        .buttonStyle(.plain)
        .foregroundColor(isActive ? Theme.Colors.accent : Theme.Colors.textMuted)
    }
}
```

- [ ] **Step 2: Create ContentView**

Create `TaskFlow/TaskFlow/Views/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SidebarTab = .today

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)

            Group {
                switch selectedTab {
                case .today:
                    Text("Today View")
                case .goals:
                    Text("Goals View")
                case .notes:
                    Text("Notes View")
                case .settings:
                    Text("Settings View")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(Theme.Colors.textPrimary)
            .font(Theme.manrope(14))
        }
        .frame(width: Theme.Dimensions.popoverWidth, minHeight: Theme.Dimensions.popoverMinHeight)
        .background(
            LinearGradient(
                colors: [Theme.Colors.background, Theme.Colors.backgroundGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
```

- [ ] **Step 3: Wire ContentView into the app**

Replace `TaskFlow/TaskFlow/TaskFlowApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
    }
}
```

- [ ] **Step 4: Build and run**

Run: `Cmd+R`
Expected: Menu bar icon opens a popover with sidebar icons on the left. Clicking icons switches the placeholder text. Background is dark blue gradient.

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Views/SidebarView.swift TaskFlow/TaskFlow/Views/ContentView.swift TaskFlow/TaskFlow/TaskFlowApp.swift
git commit -m "feat: add sidebar navigation with glassmorphic styling"
```

---

### Task 5: Today View — Task List

**Files:**
- Create: `TaskFlow/TaskFlow/Views/Today/TaskRowView.swift`
- Create: `TaskFlow/TaskFlow/Views/Today/TodayView.swift`
- Modify: `TaskFlow/TaskFlow/Views/ContentView.swift`

- [ ] **Step 1: Create TaskRowView**

Create `TaskFlow/TaskFlow/Views/Today/TaskRowView.swift`:

```swift
import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: DailyTask

    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    task.isCompleted.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                        .fill(task.isCompleted ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                        .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(task.isCompleted ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(Theme.manrope(13))
                .foregroundColor(task.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                .strikethrough(task.isCompleted, color: Theme.Colors.textDone)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}
```

- [ ] **Step 2: Create TodayView**

Create `TaskFlow/TaskFlow/Views/Today/TodayView.swift`:

```swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
    @State private var newTaskTitle = ""
    @State private var isAddingTask = false

    private var todayTasks: [DailyTask] {
        let today = Calendar.current.startOfDay(for: .now)
        return allTasks
            .filter { $0.date == today }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedCount: Int {
        todayTasks.filter(\.isCompleted).count
    }

    private var completionPercent: Int {
        guard !todayTasks.isEmpty else { return 0 }
        return Int(Double(completedCount) / Double(todayTasks.count) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("\(todayTasks.count) tasks · \(completedCount) done")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
                if !todayTasks.isEmpty {
                    Text("\(completionPercent)%")
                        .font(Theme.manrope(10, weight: .semibold))
                        .foregroundColor(Theme.Colors.badgeText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Colors.badgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.Colors.badgeBorder, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Task list
            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(todayTasks) { task in
                        TaskRowView(task: task)
                    }

                    // Add task
                    if isAddingTask {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)

                            TextField("Task name", text: $newTaskTitle)
                                .textFieldStyle(.plain)
                                .font(Theme.manrope(13))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .onSubmit {
                                    addTask()
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassCard()
                    } else {
                        Button(action: { isAddingTask = true }) {
                            Text("+ Add task")
                                .font(Theme.manrope(12, weight: .medium))
                                .foregroundColor(Theme.Colors.addButtonText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                        .stroke(Theme.Colors.addButtonBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            isAddingTask = false
            return
        }
        let task = DailyTask(title: title, sortOrder: todayTasks.count)
        modelContext.insert(task)
        newTaskTitle = ""
        isAddingTask = false
    }
}
```

- [ ] **Step 3: Wire TodayView into ContentView**

In `TaskFlow/TaskFlow/Views/ContentView.swift`, replace the `switch` body:

```swift
switch selectedTab {
case .today:
    TodayView()
case .goals:
    Text("Goals View")
        .foregroundColor(Theme.Colors.textPrimary)
        .font(Theme.manrope(14))
case .notes:
    Text("Notes View")
        .foregroundColor(Theme.Colors.textPrimary)
        .font(Theme.manrope(14))
case .settings:
    Text("Settings View")
        .foregroundColor(Theme.Colors.textPrimary)
        .font(Theme.manrope(14))
}
```

Remove the `.foregroundColor` and `.font` modifiers from the `Group` as each view now handles its own styling.

- [ ] **Step 4: Build and run**

Run: `Cmd+R`
Expected: Today tab shows header with "0 tasks · 0 done". Click "+ Add task", type a task name, press Enter. Task appears with a checkbox. Click the checkbox — task gets strikethrough and percentage updates.

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Views/Today/ TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: add Today view with task list and add/complete functionality"
```

---

### Task 6: Goals View

**Files:**
- Create: `TaskFlow/TaskFlow/Views/Goals/GoalRowView.swift`
- Create: `TaskFlow/TaskFlow/Views/Goals/GoalDetailView.swift`
- Create: `TaskFlow/TaskFlow/Views/Goals/AddGoalView.swift`
- Create: `TaskFlow/TaskFlow/Views/Goals/GoalsView.swift`
- Modify: `TaskFlow/TaskFlow/Views/ContentView.swift`

- [ ] **Step 1: Create GoalRowView**

Create `TaskFlow/TaskFlow/Views/Goals/GoalRowView.swift`:

```swift
import SwiftUI

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(goal.title)
                .font(Theme.manrope(13, weight: .medium))
                .foregroundColor(Theme.Colors.textPrimary)

            if !goal.subTasks.isEmpty {
                HStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.Colors.progressBarBackground)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Colors.accent.opacity(0.6), Theme.Colors.accent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * goal.progress, height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text("\(goal.completedSubTaskCount)/\(goal.subTasks.count)")
                        .font(Theme.manrope(10, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(minWidth: 30, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}
```

- [ ] **Step 2: Create GoalDetailView**

Create `TaskFlow/TaskFlow/Views/Goals/GoalDetailView.swift`:

```swift
import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal
    @State private var newSubTaskTitle = ""
    @State private var isAddingSubTask = false

    private var sortedSubTasks: [GoalSubTask] {
        goal.subTasks.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back header
            HStack {
                Button(action: { /* handled by parent via binding */ }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
                .buttonStyle(.plain)

                Text(goal.title)
                    .font(Theme.manrope(15, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Text(goal.timeframe.rawValue)
                    .font(Theme.manrope(10, weight: .semibold))
                    .foregroundColor(Theme.Colors.badgeText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.Colors.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Theme.Colors.badgeBorder, lineWidth: 1)
                    )
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Sub-tasks
            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(sortedSubTasks) { subTask in
                        subTaskRow(subTask)
                    }

                    if isAddingSubTask {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)

                            TextField("Sub-task name", text: $newSubTaskTitle)
                                .textFieldStyle(.plain)
                                .font(Theme.manrope(13))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .onSubmit { addSubTask() }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassCard()
                    } else {
                        Button(action: { isAddingSubTask = true }) {
                            Text("+ Add sub-task")
                                .font(Theme.manrope(12, weight: .medium))
                                .foregroundColor(Theme.Colors.addButtonText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                        .stroke(Theme.Colors.addButtonBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func subTaskRow(_ subTask: GoalSubTask) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    subTask.isCompleted.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                        .fill(subTask.isCompleted ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                        .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(subTask.isCompleted ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                        )

                    if subTask.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(subTask.title)
                .font(Theme.manrope(13))
                .foregroundColor(subTask.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                .strikethrough(subTask.isCompleted, color: Theme.Colors.textDone)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }

    private func addSubTask() {
        let title = newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            isAddingSubTask = false
            return
        }
        let subTask = GoalSubTask(title: title, sortOrder: goal.subTasks.count)
        subTask.goal = goal
        modelContext.insert(subTask)
        newSubTaskTitle = ""
        isAddingSubTask = false
    }
}
```

- [ ] **Step 3: Create AddGoalView**

Create `TaskFlow/TaskFlow/Views/Goals/AddGoalView.swift`:

```swift
import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var timeframe: GoalTimeframe = .threeMonth
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Goal")
                .font(Theme.manrope(13, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)

            TextField("Goal title", text: $title)
                .textFieldStyle(.plain)
                .font(Theme.manrope(13))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Theme.Colors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                        .stroke(Theme.Colors.inputBorder, lineWidth: 1)
                )

            HStack(spacing: 6) {
                ForEach(GoalTimeframe.allCases, id: \.self) { tf in
                    Button(action: { timeframe = tf }) {
                        Text(tf.rawValue)
                            .font(Theme.manrope(11, weight: .semibold))
                            .foregroundColor(timeframe == tf ? Theme.Colors.accent : Theme.Colors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(timeframe == tf ? Theme.Colors.sidebarIconActiveBackground : Theme.Colors.sidebarIconBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(timeframe == tf ? Theme.Colors.sidebarIconActiveBorder : Theme.Colors.sidebarIconBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Button("Cancel") { onDismiss() }
                    .font(Theme.manrope(11, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .buttonStyle(.plain)

                Spacer()

                Button("Add") { addGoal() }
                    .font(Theme.manrope(11, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.sidebarIconActiveBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.Colors.sidebarIconActiveBorder, lineWidth: 1)
                    )
                    .buttonStyle(.plain)
            }
        }
        .padding(12)
        .glassCard()
    }

    private func addGoal() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let goal = Goal(title: trimmed, timeframe: timeframe)
        modelContext.insert(goal)
        onDismiss()
    }
}
```

- [ ] **Step 4: Create GoalsView**

Create `TaskFlow/TaskFlow/Views/Goals/GoalsView.swift`:

```swift
import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var allGoals: [Goal]
    @State private var selectedGoal: Goal?
    @State private var isAddingGoal = false

    private func goals(for timeframe: GoalTimeframe) -> [Goal] {
        allGoals
            .filter { $0.timeframe == timeframe }
            .sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        if let goal = selectedGoal {
            GoalDetailView(goal: goal)
                .overlay(alignment: .topLeading) {
                    Button(action: { selectedGoal = nil }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(Theme.Dimensions.contentPadding)
                    }
                    .buttonStyle(.plain)
                }
        } else {
            goalsList
        }
    }

    private var goalsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Goals")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("\(allGoals.count) active goals")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(GoalTimeframe.allCases, id: \.self) { timeframe in
                        let tfGoals = goals(for: timeframe)
                        if !tfGoals.isEmpty || true {
                            Text(timeframe.rawValue)
                                .font(Theme.manrope(10, weight: .bold))
                                .foregroundColor(Theme.Colors.accent.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(0.8)
                                .padding(.horizontal, Theme.Dimensions.contentPadding)
                                .padding(.top, timeframe == .threeMonth ? 0 : 12)
                                .padding(.bottom, 8)

                            VStack(spacing: Theme.Dimensions.cardSpacing) {
                                ForEach(tfGoals) { goal in
                                    Button(action: { selectedGoal = goal }) {
                                        GoalRowView(goal: goal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Theme.Dimensions.contentPadding)
                        }
                    }

                    // Add goal
                    if isAddingGoal {
                        AddGoalView(onDismiss: { isAddingGoal = false })
                            .padding(.horizontal, Theme.Dimensions.contentPadding)
                            .padding(.top, 12)
                    } else {
                        Button(action: { isAddingGoal = true }) {
                            Text("+ Add goal")
                                .font(Theme.manrope(12, weight: .medium))
                                .foregroundColor(Theme.Colors.addButtonText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                        .stroke(Theme.Colors.addButtonBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                        .padding(.top, 12)
                    }
                }
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }
}
```

- [ ] **Step 5: Wire GoalsView into ContentView**

In `TaskFlow/TaskFlow/Views/ContentView.swift`, replace the `.goals` case:

```swift
case .goals:
    GoalsView()
```

- [ ] **Step 6: Build and run**

Run: `Cmd+R`
Expected: Goals tab shows grouped headers (3 Month, 6 Month, 1 Year). Click "+ Add goal", fill title, pick timeframe, click Add. Goal appears. Click goal to see detail view with sub-task management.

- [ ] **Step 7: Commit**

```bash
git add TaskFlow/TaskFlow/Views/Goals/ TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: add Goals view with sub-tasks and progress tracking"
```

---

### Task 7: Quick Notes View

**Files:**
- Create: `TaskFlow/TaskFlow/Views/Notes/NoteRowView.swift`
- Create: `TaskFlow/TaskFlow/Views/Notes/NotesView.swift`
- Modify: `TaskFlow/TaskFlow/Views/ContentView.swift`

- [ ] **Step 1: Create NoteRowView**

Create `TaskFlow/TaskFlow/Views/Notes/NoteRowView.swift`:

```swift
import SwiftUI

struct NoteRowView: View {
    let note: QuickNote
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.text)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(3)

                Text(note.relativeTimestamp)
                    .font(Theme.manrope(10, weight: .medium))
                    .foregroundColor(Theme.Colors.textMuted)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.Colors.textMuted)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .opacity(0.5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}
```

- [ ] **Step 2: Create NotesView**

Create `TaskFlow/TaskFlow/Views/Notes/NotesView.swift`:

```swift
import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]
    @State private var newNoteText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notes")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Brain dump")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    // Input field
                    TextField("Type a quick note...", text: $newNoteText)
                        .textFieldStyle(.plain)
                        .font(Theme.manrope(12, weight: .medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                .stroke(Theme.Colors.inputBorder, lineWidth: 1)
                        )
                        .onSubmit { addNote() }

                    // Notes list
                    ForEach(notes) { note in
                        NoteRowView(note: note) {
                            withAnimation {
                                modelContext.delete(note)
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func addNote() {
        let text = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let note = QuickNote(text: text)
        modelContext.insert(note)
        newNoteText = ""
    }
}
```

- [ ] **Step 3: Wire NotesView into ContentView**

In `TaskFlow/TaskFlow/Views/ContentView.swift`, replace the `.notes` case:

```swift
case .notes:
    NotesView()
```

- [ ] **Step 4: Build and run**

Run: `Cmd+R`
Expected: Notes tab shows input field at top. Type a note, press Enter. Note appears below with relative timestamp. Click X to delete.

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Views/Notes/ TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: add Quick Notes view with add and delete"
```

---

### Task 8: Day Rollover

**Files:**
- Create: `TaskFlow/TaskFlow/Services/DayRolloverService.swift`
- Create: `TaskFlow/TaskFlow/Views/Today/DayRolloverView.swift`
- Modify: `TaskFlow/TaskFlow/Views/Today/TodayView.swift`

- [ ] **Step 1: Create DayRolloverService**

Create `TaskFlow/TaskFlow/Services/DayRolloverService.swift`:

```swift
import Foundation
import SwiftData
import Combine

@Observable
final class DayRolloverService {
    var hasUnresolvedRollover = false
    var pendingTasks: [DailyTask] = []

    private var timer: Timer?

    func checkRollover(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let descriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date < today && task.isCompleted == false
            }
        )

        do {
            let incompleteTasks = try modelContext.fetch(descriptor)
            if !incompleteTasks.isEmpty {
                pendingTasks = incompleteTasks
                hasUnresolvedRollover = true
            } else {
                pendingTasks = []
                hasUnresolvedRollover = false
            }
        } catch {
            pendingTasks = []
            hasUnresolvedRollover = false
        }
    }

    func carryForward(tasks: [DailyTask], modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        for task in tasks {
            let newTask = DailyTask(title: task.title, date: today, sortOrder: task.sortOrder)
            modelContext.insert(newTask)
            modelContext.delete(task)
        }
        // Delete remaining pending tasks that weren't carried forward
        for task in pendingTasks where !tasks.contains(where: { $0.id == task.id }) {
            modelContext.delete(task)
        }
        hasUnresolvedRollover = false
        pendingTasks = []
    }

    func clearAll(modelContext: ModelContext) {
        for task in pendingTasks {
            modelContext.delete(task)
        }
        hasUnresolvedRollover = false
        pendingTasks = []
    }

    func startPeriodicCheck(modelContext: ModelContext) {
        checkRollover(modelContext: modelContext)
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkRollover(modelContext: modelContext)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
```

- [ ] **Step 2: Create DayRolloverView**

Create `TaskFlow/TaskFlow/Views/Today/DayRolloverView.swift`:

```swift
import SwiftUI

struct DayRolloverView: View {
    let tasks: [DailyTask]
    var onKeepSelected: ([DailyTask]) -> Void
    var onClearAll: () -> Void

    @State private var selectedTaskIds: Set<UUID>

    init(tasks: [DailyTask], onKeepSelected: @escaping ([DailyTask]) -> Void, onClearAll: @escaping () -> Void) {
        self.tasks = tasks
        self.onKeepSelected = onKeepSelected
        self.onClearAll = onClearAll
        self._selectedTaskIds = State(initialValue: Set(tasks.map(\.id)))
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Carry forward?")
                .font(Theme.manrope(13, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)

            VStack(spacing: 4) {
                ForEach(tasks) { task in
                    HStack(spacing: 10) {
                        Button(action: { toggleTask(task) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                    .fill(selectedTaskIds.contains(task.id) ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                            .stroke(selectedTaskIds.contains(task.id) ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                    )

                                if selectedTaskIds.contains(task.id) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Text(task.title)
                            .font(Theme.manrope(12))
                            .foregroundColor(selectedTaskIds.contains(task.id) ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassCard()
                }
            }

            HStack(spacing: 8) {
                Button(action: {
                    let selected = tasks.filter { selectedTaskIds.contains($0.id) }
                    onKeepSelected(selected)
                }) {
                    Text("Keep Selected")
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.sidebarIconActiveBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.Colors.sidebarIconActiveBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(action: onClearAll) {
                    Text("Clear All")
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Theme.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                .stroke(Theme.Colors.inputBorder, lineWidth: 1)
        )
    }

    private func toggleTask(_ task: DailyTask) {
        if selectedTaskIds.contains(task.id) {
            selectedTaskIds.remove(task.id)
        } else {
            selectedTaskIds.insert(task.id)
        }
    }
}
```

- [ ] **Step 3: Integrate rollover into TodayView**

In `TaskFlow/TaskFlow/Views/Today/TodayView.swift`, add the rollover service and view. Add these properties:

```swift
@State private var rolloverService = DayRolloverService()
```

Add `.onAppear` to the outermost `VStack`:

```swift
.onAppear {
    rolloverService.startPeriodicCheck(modelContext: modelContext)
}
.onDisappear {
    rolloverService.stop()
}
```

Insert the rollover view above the task list, inside the `ScrollView`, before `ForEach(todayTasks)`:

```swift
if rolloverService.hasUnresolvedRollover {
    DayRolloverView(
        tasks: rolloverService.pendingTasks,
        onKeepSelected: { tasks in
            rolloverService.carryForward(tasks: tasks, modelContext: modelContext)
        },
        onClearAll: {
            rolloverService.clearAll(modelContext: modelContext)
        }
    )
    .padding(.bottom, 8)
}
```

- [ ] **Step 4: Build and run**

Run: `Cmd+R`
Expected: If there are uncompleted tasks from a previous day, the rollover prompt appears at the top of Today view. "Keep Selected" carries tasks forward, "Clear All" removes them.

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Services/ TaskFlow/TaskFlow/Views/Today/
git commit -m "feat: add day rollover with carry-forward prompt"
```

---

### Task 9: Menu Bar Icon Color

**Files:**
- Create: `TaskFlow/TaskFlow/Utilities/MenuBarIconManager.swift`
- Modify: `TaskFlow/TaskFlow/TaskFlowApp.swift`

- [ ] **Step 1: Create MenuBarIconManager**

Create `TaskFlow/TaskFlow/Utilities/MenuBarIconManager.swift`:

```swift
import SwiftUI
import SwiftData
import AppKit

@Observable
final class MenuBarIconManager {
    var statusColor: Color = Theme.Colors.statusGreen
    var iconName: String = "checklist"

    func update(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        // Check for overdue tasks (from previous days)
        let overdueDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date < today && task.isCompleted == false
            }
        )

        // Check today's tasks
        let todayDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date == today
            }
        )

        do {
            let overdueTasks = try modelContext.fetch(overdueDescriptor)
            let todayTasks = try modelContext.fetch(todayDescriptor)

            if !overdueTasks.isEmpty {
                statusColor = Theme.Colors.statusRed
            } else if todayTasks.isEmpty || todayTasks.allSatisfy(\.isCompleted) {
                statusColor = Theme.Colors.statusGreen
            } else {
                statusColor = Theme.Colors.statusOrange
            }
        } catch {
            statusColor = Theme.Colors.statusGreen
        }
    }
}
```

- [ ] **Step 2: Integrate into TaskFlowApp**

Replace `TaskFlow/TaskFlow/TaskFlowApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    @State private var iconManager = MenuBarIconManager()

    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            ContentView(iconManager: iconManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
    }
}
```

- [ ] **Step 3: Update ContentView to accept and pass iconManager**

In `TaskFlow/TaskFlow/Views/ContentView.swift`, add a property and pass it through:

```swift
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: SidebarTab = .today
    var iconManager: MenuBarIconManager

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)

            Group {
                switch selectedTab {
                case .today:
                    TodayView()
                case .goals:
                    GoalsView()
                case .notes:
                    NotesView()
                case .settings:
                    Text("Settings View")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .font(Theme.manrope(14))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: Theme.Dimensions.popoverWidth, minHeight: Theme.Dimensions.popoverMinHeight)
        .background(
            LinearGradient(
                colors: [Theme.Colors.background, Theme.Colors.backgroundGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            iconManager.update(modelContext: modelContext)
        }
        .onChange(of: selectedTab) {
            iconManager.update(modelContext: modelContext)
        }
    }
}
```

Note: The `MenuBarExtra` system image is static (SwiftUI limitation). The color-coded status will be rendered via a custom `NSImage` in a future enhancement. For now, the icon manager tracks the state for when we add the custom rendering.

- [ ] **Step 4: Build and run**

Run: `Cmd+R`
Expected: App compiles and runs. The icon manager tracks state internally (visual icon color change requires NSStatusItem customization, which we'll note as a follow-up).

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Utilities/MenuBarIconManager.swift TaskFlow/TaskFlow/TaskFlowApp.swift TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: add menu bar icon state tracking"
```

---

### Task 10: Settings View

**Files:**
- Create: `TaskFlow/TaskFlow/Views/SettingsView.swift`
- Modify: `TaskFlow/TaskFlow/Views/ContentView.swift`

- [ ] **Step 1: Create SettingsView**

Create `TaskFlow/TaskFlow/Views/SettingsView.swift`:

```swift
import SwiftUI
import SwiftData
import ServiceManagement

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("rolloverHour") private var rolloverHour = 0
    @State private var showExportSuccess = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(Theme.manrope(15, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.top, Theme.Dimensions.contentPadding)
                .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    // Launch at login
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Launch at Login")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Start TaskFlow when you log in")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $launchAtLogin)
                                .toggleStyle(.switch)
                                .tint(Theme.Colors.accent)
                                .labelsHidden()
                                .onChange(of: launchAtLogin) { _, newValue in
                                    do {
                                        if newValue {
                                            try SMAppService.mainApp.register()
                                        } else {
                                            try SMAppService.mainApp.unregister()
                                        }
                                    } catch {
                                        launchAtLogin = !newValue
                                    }
                                }
                        }
                    }

                    // Rollover time
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Day Rollover Time")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("When the new day starts")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Picker("", selection: $rolloverHour) {
                                Text("Midnight").tag(0)
                                Text("3:00 AM").tag(3)
                                Text("5:00 AM").tag(5)
                                Text("6:00 AM").tag(6)
                            }
                            .labelsHidden()
                            .frame(width: 110)
                            .tint(Theme.Colors.accent)
                        }
                    }

                    // Export data
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Save all data as JSON")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Button(action: exportData) {
                                Text(showExportSuccess ? "Saved!" : "Export")
                                    .font(Theme.manrope(11, weight: .semibold))
                                    .foregroundColor(Theme.Colors.accent)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Theme.Colors.sidebarIconActiveBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Theme.Colors.sidebarIconActiveBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func settingRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassCard()
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "taskflow-export.json"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let tasks = try modelContext.fetch(FetchDescriptor<DailyTask>())
            let goals = try modelContext.fetch(FetchDescriptor<Goal>())
            let notes = try modelContext.fetch(FetchDescriptor<QuickNote>())

            let export: [String: Any] = [
                "exportDate": ISO8601DateFormatter().string(from: .now),
                "tasks": tasks.map { ["id": $0.id.uuidString, "title": $0.title, "isCompleted": $0.isCompleted, "date": ISO8601DateFormatter().string(from: $0.date)] },
                "goals": goals.map { ["id": $0.id.uuidString, "title": $0.title, "timeframe": $0.timeframe.rawValue, "subTasks": $0.subTasks.map { ["title": $0.title, "isCompleted": $0.isCompleted] }] },
                "notes": notes.map { ["id": $0.id.uuidString, "text": $0.text, "createdAt": ISO8601DateFormatter().string(from: $0.createdAt)] }
            ]

            let data = try JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
            try data.write(to: url)

            showExportSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showExportSuccess = false
            }
        } catch {
            // Export failed silently
        }
    }
}
```

- [ ] **Step 2: Wire SettingsView into ContentView**

In `TaskFlow/TaskFlow/Views/ContentView.swift`, replace the `.settings` case:

```swift
case .settings:
    SettingsView()
```

- [ ] **Step 3: Build and run**

Run: `Cmd+R`
Expected: Settings tab shows three options: Launch at Login toggle, Day Rollover Time picker, and Export Data button. Export opens a save dialog and writes JSON.

- [ ] **Step 4: Commit**

```bash
git add TaskFlow/TaskFlow/Views/SettingsView.swift TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: add Settings view with launch-at-login, rollover time, and export"
```

---

### Task 11: Bundle Manrope Font

**Files:**
- Create: `TaskFlow/TaskFlow/Resources/Fonts/Manrope-VariableFont_wght.ttf`
- Modify: `TaskFlow/TaskFlow/Info.plist`

- [ ] **Step 1: Download and add Manrope font**

Download the Manrope font from Google Fonts and add it to the project:

```bash
mkdir -p TaskFlow/TaskFlow/Resources/Fonts
curl -L "https://github.com/nicokant/Manrope/releases/download/v4.505/Manrope-VariableFont_wght.ttf" -o TaskFlow/TaskFlow/Resources/Fonts/Manrope-VariableFont_wght.ttf
```

If the direct download doesn't work, download from Google Fonts manually and place the `.ttf` in `TaskFlow/TaskFlow/Resources/Fonts/`.

- [ ] **Step 2: Update Info.plist for font registration**

Ensure `TaskFlow/TaskFlow/Info.plist` contains:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
    <key>ATSApplicationFontsPath</key>
    <string>Fonts</string>
</dict>
</plist>
```

- [ ] **Step 3: Add font file to Xcode target**

In Xcode, drag `Manrope-VariableFont_wght.ttf` into the project navigator under Resources/Fonts. Make sure "Add to targets: TaskFlow" is checked and "Copy items if needed" is selected.

- [ ] **Step 4: Build and run to verify font loads**

Run: `Cmd+R`
Expected: All text in the popover renders in Manrope font instead of system font.

- [ ] **Step 5: Commit**

```bash
git add TaskFlow/TaskFlow/Resources/ TaskFlow/TaskFlow/Info.plist
git commit -m "feat: bundle Manrope font"
```

---

### Task 12: Keyboard Shortcut to Open Popover

**Files:**
- Modify: `TaskFlow/TaskFlow/TaskFlowApp.swift`

- [ ] **Step 1: Add global keyboard shortcut**

Update `TaskFlow/TaskFlow/TaskFlowApp.swift` to add the keyboard shortcut:

```swift
import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    @State private var iconManager = MenuBarIconManager()

    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            ContentView(iconManager: iconManager)
        }
        .menuBarExtraStyle(.window)
        .defaultPosition(.topTrailing)
        .modelContainer(for: [
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
    }
}
```

Note: SwiftUI's `MenuBarExtra` doesn't natively support global keyboard shortcuts to toggle the popover. To add `Cmd+Shift+T`, we need to use `NSEvent.addGlobalMonitorForEvents`. Add this to ContentView's `.onAppear`:

In `TaskFlow/TaskFlow/Views/ContentView.swift`, add to the existing `.onAppear`:

```swift
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.modifierFlags.contains([.command, .shift]) && event.characters == "t" {
        // MenuBarExtra toggle is handled by the system
        // This is a placeholder for future NSStatusItem-based approach
    }
}
```

Note: True global shortcut to toggle MenuBarExtra requires dropping down to NSStatusItem. This is a known SwiftUI limitation. The keyboard shortcut is logged as a future enhancement.

- [ ] **Step 2: Build and run**

Run: `Cmd+R`
Expected: App compiles. Menu bar icon click opens popover as before.

- [ ] **Step 3: Commit**

```bash
git add TaskFlow/TaskFlow/TaskFlowApp.swift TaskFlow/TaskFlow/Views/ContentView.swift
git commit -m "feat: note keyboard shortcut limitation for MenuBarExtra"
```

---

### Task 13: Delete Tasks and Goals

**Files:**
- Modify: `TaskFlow/TaskFlow/Views/Today/TaskRowView.swift`
- Modify: `TaskFlow/TaskFlow/Views/Goals/GoalsView.swift`

- [ ] **Step 1: Add swipe-to-delete on tasks**

In `TaskFlow/TaskFlow/Views/Today/TodayView.swift`, wrap each `TaskRowView` in the `ForEach` to support contextual delete. Replace the `ForEach(todayTasks)` block:

```swift
ForEach(todayTasks) { task in
    TaskRowView(task: task)
        .contextMenu {
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(task)
                }
            }
        }
}
```

- [ ] **Step 2: Add delete on goals**

In `TaskFlow/TaskFlow/Views/Goals/GoalsView.swift`, add a context menu to goal rows. Replace the `ForEach(tfGoals)` block in `goalsList`:

```swift
ForEach(tfGoals) { goal in
    Button(action: { selectedGoal = goal }) {
        GoalRowView(goal: goal)
    }
    .buttonStyle(.plain)
    .contextMenu {
        Button("Delete", role: .destructive) {
            withAnimation {
                modelContext.delete(goal)
            }
        }
    }
}
```

Add `@Environment(\.modelContext) private var modelContext` to `GoalsView` if not already present.

- [ ] **Step 3: Build and run**

Run: `Cmd+R`
Expected: Right-click a task or goal shows "Delete" context menu option. Clicking it removes the item.

- [ ] **Step 4: Commit**

```bash
git add TaskFlow/TaskFlow/Views/Today/TodayView.swift TaskFlow/TaskFlow/Views/Goals/GoalsView.swift
git commit -m "feat: add context menu delete for tasks and goals"
```
