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
 
    @objc static var statusBarMenu: StatusBarMenu?
    
    // MARK: Private
    private static let openedWindows = NSMutableArray()
    private static let lk = NSLock()
}

@objcMembers
class StatusBarMenu: NSObject {
    
    /// Hide staus item User Defaults key
    static let BSHideStatusItem = "BSHideStatusItem"
    
    init(_ menu: NSMenu) {
        self.menu = menu
        self.statusItem = NSStatusBar.system.statusItem(withLength: self.length)
        self.statusItem.menu = self.menu
        self.statusItem.button?.image = NSImage(named: "beardie")
        self.statusItem.isVisible = !UserDefaults.standard.bool(forKey: Self.BSHideStatusItem)
    }
    
    func open() {
        self.statusItem.isVisible = true
        self.statusItem.button?.highlight(true)
        self.opened = true
        //TODO: check that we need "async after" on release version MacOS 11.3
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            var point: NSPoint
            if #available(macOS 11.0, *) {
                point = NSPoint(x: -self.length, y: 29.0)
            } else {
                point = NSPoint(x: 0.0, y: 26.0)
            }
            self.statusItem.menu?.popUp(positioning: nil, at: point, in: self.statusItem.button)
        }
    }
    
    func didClose() {
        if self.opened {
            self.statusItem.button?.highlight(false)
        }
        self.updateVisibility()
        self.opened = false
    }
    
    func updateVisibility() {
        self.statusItem.isVisible = !UserDefaults.standard.bool(forKey: Self.BSHideStatusItem)
    }
    
    // MARK: Private
    private let length = CGFloat(26.0)

    private let menu: NSMenu
    private let statusItem: NSStatusItem
    private var opened = false
}
