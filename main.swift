import SwiftUI
import AppKit

private let appWindowSize = NSSize(width: 340, height: 500)

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        bringWindowsForward()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.activate(ignoringOtherApps: true)
            self.bringWindowsForward()
        }
    }

    private func bringWindowsForward() {
        guard let window = preferredWindow else { return }
        configure(window: window)

        if window.canBecomeKey {
            window.makeKeyAndOrderFront(nil)
        } else {
            window.orderFrontRegardless()
        }
    }

    private var preferredWindow: NSWindow? {
        NSApp.windows.first(where: { $0.canBecomeKey }) ?? NSApp.windows.first
    }

    private func configure(window: NSWindow) {
        window.styleMask.remove(.resizable)
        window.minSize = appWindowSize
        window.maxSize = appWindowSize
        window.setContentSize(appWindowSize)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        bringWindowsForward()
    }
}

@main
struct CalcApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: appWindowSize.width, height: appWindowSize.height)
    }
}