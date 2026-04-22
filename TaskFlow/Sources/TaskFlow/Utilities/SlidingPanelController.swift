import AppKit
import SwiftUI
import SwiftData

final class SlidingPanelController {
    private var panel: NSPanel?
    private let container: ModelContainer
    private let iconManager: MenuBarIconManager
    private let panelWidth: CGFloat = 440
    private var clickMonitor: Any?

    init(container: ModelContainer, iconManager: MenuBarIconManager) {
        self.container = container
        self.iconManager = iconManager
    }

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            createPanel()
        }
        guard let panel, let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let panelHeight = screenFrame.height
        let offScreenX = screenFrame.maxX
        let onScreenX = screenFrame.maxX - panelWidth

        panel.setFrame(
            NSRect(x: offScreenX, y: screenFrame.minY, width: panelWidth, height: panelHeight),
            display: false
        )
        panel.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(
                NSRect(x: onScreenX, y: screenFrame.minY, width: panelWidth, height: panelHeight),
                display: true
            )
        }

        startClickMonitor()
    }

    func hide() {
        guard let panel, let screen = NSScreen.main else { return }
        stopClickMonitor()

        let screenFrame = screen.visibleFrame
        let offScreenX = screenFrame.maxX

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().setFrame(
                NSRect(x: offScreenX, y: screenFrame.minY, width: panelWidth, height: screenFrame.height),
                display: true
            )
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func startClickMonitor() {
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let panel = self.panel, panel.isVisible else { return }
            let screenLocation = NSEvent.mouseLocation
            if !panel.frame.contains(screenLocation) {
                self.hide()
            }
        }
    }

    private func stopClickMonitor() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    private func createPanel() {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovable = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.becomesKeyOnlyIfNeeded = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = NSColor(red: 0.059, green: 0.125, blue: 0.153, alpha: 0.92)
        panel.hasShadow = true
        panel.hidesOnDeactivate = false

        let contentView = ContentView(iconManager: iconManager)
            .modelContainer(container)

        let hostingView = NSHostingView(rootView: contentView)
        panel.contentView = hostingView

        self.panel = panel
    }

    deinit {
        stopClickMonitor()
    }
}
