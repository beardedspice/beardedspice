//
//  UIController.swift
//  Beardie
//
//  Created by Roman Sokolov on 28.02.2021.
//  Copyright © 2021 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import AppKit

@objc
class UIController: NSObject {
    static let ACTIVATE_APP_DELAY = 0.3 // secconds
    
    @objc static func windowWillBeVisible(_ window: AnyObject?, completion: (()->Void)?) {
        
        // subscribe to notification
        struct once {
            static let observer = NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification,
                                                                         object: nil,
                                                                         queue: nil) { (noti) in
                if let window = noti.object as AnyObject? {
                    UIController.removeWindow(window)
                }
            }
            static func run(){ _ = self.observer }
        }
        once.run()
        //------
        
        if let window = window {
            lk.lock()
            defer {
                lk.unlock()
            }
            if self.openedWindows.count == 0 && NSApp.activationPolicy() != .regular {

                NSApp.setActivationPolicy(.regular)
                // needed to activate menu
                let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.loginwindow").first
                dock?.activate(options: .activateIgnoringOtherApps)
                DispatchQueue.main.asyncAfter(deadline: .now()+ACTIVATE_APP_DELAY) {
                    NSApp.activate(ignoringOtherApps: true)
                    completion?()
                }
            }
            else {
                DispatchQueue.main.async {
                    NSApp.activate(ignoringOtherApps: true)
                    completion?()
                }
            }
            self.openedWindows.add(window)
        }
        else {
            completion?()
        }
    }
    
    @objc static func removeWindow(_ window: AnyObject?) {
        if let window = window {
            lk.lock()
            defer {
                lk.unlock()
            }
            self.openedWindows.remove(window)
            if self.openedWindows.count == 0 && NSApp.activationPolicy() != .accessory {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
 
    // MARK: Private
    
    private static let openedWindows = NSMutableArray()
    private static let lk = NSLock()
}
