import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panelController: SlidingPanelController!
    private var widgetController: DesktopWidgetController!
    private let iconManager = MenuBarIconManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let schema = Schema([
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        panelController = SlidingPanelController(container: container, iconManager: iconManager)
        widgetController = DesktopWidgetController(container: container)

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "TaskFlow")
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Widget is on-demand via right-click menu
    }

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            panelController.toggle()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        let widgetItem = NSMenuItem(
            title: widgetController.isVisible ? "Hide Desktop Widget" : "Show Desktop Widget",
            action: #selector(toggleWidget),
            keyEquivalent: "w"
        )
        widgetItem.target = self
        menu.addItem(widgetItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit TaskFlow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Reset so left click works again
    }

    @objc private func toggleWidget() {
        widgetController.toggle()
    }
}
