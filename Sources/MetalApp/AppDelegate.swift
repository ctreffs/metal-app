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

#if os(macOS)
public final class AppDelegate: NSObject, APPLAppDelegate {
    var window: APPLWindow!
    lazy var viewController = MetalViewController()

    public func applicationDidFinishLaunching(_ notification: Notification) {
        viewController.view.frame.size.width = 800
        viewController.view.frame.size.height = 600
        let window = APPLWindow(contentViewController: viewController)
        window.title = "MetalApp"
        self.window = window
        window.makeFirstResponder(nil)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.center()
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#else
@UIApplicationMain
public final class AppDelegate: NSObject, APPLAppDelegate {
    public var window: APPLWindow?
    lazy var viewController = MetalViewController()

    public func applicationDidFinishLaunching(_ application: UIApplication) {
        let window = APPLWindow()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }
}
#endif
