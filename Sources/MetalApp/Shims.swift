//
//  Shims.swift
//
//
//  Created by Christian Treffs on 25.02.21.
//

// MARK: - AppKit
#if os(macOS)
import AppKit

public typealias APPLAppDelegate = NSApplicationDelegate
public typealias APPLWindow = NSWindow
public typealias APPLViewController = NSViewController
public typealias APPLView = NSView
public typealias APPLDisplayLink = CVDisplayLink
public typealias APPLScreen = NSScreen

// MARK: - UIKit
#else
import UIKit

public typealias APPLAppDelegate = UIApplicationDelegate
public typealias APPLWindow = UIWindow
public typealias APPLViewController = UIViewController
public typealias APPLView = UIView
public typealias APPLDisplayLink = CADisplayLink
public typealias APPLScreen = UIScreen

#endif
