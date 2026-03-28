import SwiftUI
import AppKit

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
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
            window.makeKeyAndOrderFront(nil)
        } else if let window = NSApp.windows.first {
            window.orderFrontRegardless()
        }
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
        .defaultSize(width: 320, height: 720)
    }
}