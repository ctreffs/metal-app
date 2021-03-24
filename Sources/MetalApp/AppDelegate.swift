//
//  AppDelegate.swift
//  
//
//  Created by Christian Treffs on 25.02.21.
//
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import Foundation

public final class AppDelegate: NSObject, APPLAppDelegate {
    #if os(macOS)
    var window: APPLWindow!
    #else
    public var window: APPLWindow?
    #endif

    lazy var viewController = MetalViewController()

    #if os(macOS)
    // MARK: - AppKit
    public func applicationDidFinishLaunching(_ notification: Notification) {
        viewController.view.frame.size.width = 800
        viewController.view.frame.size.height = 600
        let window = APPLWindow(contentViewController: viewController)
        self.window = window
        window.title = "MetalApp"
        window.makeFirstResponder(nil)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.center()
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    #else
    // MARK: - UIKit
    public func applicationDidFinishLaunching(_ application: UIApplication) {
        let window = APPLWindow()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }
    #endif
}
