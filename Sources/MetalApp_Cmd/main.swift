//
//  main.swift
//
//
//  Created by Christian Treffs on 25.02.21.
//

import MetalApp
#if os(macOS)
import AppKit

let app = NSApplication.shared
let strongDelegate = AppDelegate()
app.delegate = strongDelegate
_ = NSApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv)

#else
import UIKit
let app = UIApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
UIApplicationMain(CommandLine.argc,
                  CommandLine.unsafeArgv,
                  nil,
                  NSStringFromClass(AppDelegate.self))

#endif
