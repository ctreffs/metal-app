//
//  main.swift
//  MetalApp_macOS
//
//  Created by Christian Treffs on 25.02.21.
//

import AppKit

let app = NSApplication.shared
let strongDelegate = AppDelegate()
app.delegate = strongDelegate
_ = NSApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv)
