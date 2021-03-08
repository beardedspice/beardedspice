//
//  AppDelegate.swift
//  BeardieLaunchAtLogin
//
//  Created by Roman Sokolov on 08.03.2021.
//  Copyright © 2021 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check if main app is already running; if yes, do nothing and terminate helper app
        if NSRunningApplication.runningApplications(withBundleIdentifier: BS_BUNDLE_ID).isEmpty {
            let launchUrl = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            NSLog("Beardie Login Helper try laungh: \(launchUrl)")
            _ = try? NSWorkspace.shared.launchApplication(at: launchUrl, configuration: [.environment : [BS_LAUNCHER_BUNDLE_ID: "1"] ])
        }
        NSApp.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

