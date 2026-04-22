import AppKit
import SwiftUI
import SwiftData

final class DesktopWidgetController {
    private var widgetWindow: NSWindow?
    private let container: ModelContainer
    private var isDragging = false
    private var dragOffset: NSPoint = .zero

    init(container: ModelContainer) {
        self.container = container
    }

    var isVisible: Bool {
        widgetWindow?.isVisible ?? false
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if widgetWindow == nil {
            createWidget()
        }
        widgetWindow?.orderFront(nil)
    }

    func hide() {
        widgetWindow?.orderOut(nil)
    }

    private func createWidget() {
        let widgetSize = NSSize(width: 280, height: 320)
        guard let screen = NSScreen.main else { return }

        // Position bottom-right of screen
        let x = screen.visibleFrame.maxX - widgetSize.width - 24
        let y = screen.visibleFrame.minY + 24

        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: x, y: y), size: widgetSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.ignoresMouseEvents = false

        let widgetView = DesktopWidgetView(onClose: { [weak self] in self?.hide() })
            .modelContainer(container)

        let hostingView = NSHostingView(rootView: widgetView)
        window.contentView = hostingView

        self.widgetWindow = window
    }
}
