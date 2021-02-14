//
//  main.swift
//  restarter
//
//  Created by Roman Sokolov on 14.02.2021.
//  Copyright © 2021 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Foundation
import AppKit

class TerminationListener: NSObject {
    let executablePath: String
    var parentProcessId: pid_t

    init(executablePath execPath: String, parentProcessId ppid: pid_t!) {
        executablePath = execPath
        parentProcessId = ppid
        super.init()

        NSWorkspace.shared.addObserver(self, forKeyPath: "runningApplications", options: [.old, .new], context: nil)

        if getppid() == 1 {
            // ppid is launchd (1) => parent terminated already
            relaunch()
        }
    }

    deinit {
        tryBlock {
            NSWorkspace.shared.removeObserver(self, forKeyPath: "runningApplications")
        }
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "runningApplications" {

            var notFound = true
            for app in NSWorkspace.shared.runningApplications {

                if app.processIdentifier == parentProcessId {
                    notFound = false
                    break
                }
            }
            if notFound {
                relaunch()
            }
        }
    }

    func relaunch() {
        NSWorkspace.shared.launchApplication(executablePath)
        exit(0)
    }
}

autoreleasepool {
    
    var listener = TerminationListener(executablePath: ProcessInfo.processInfo.arguments[1], parentProcessId: pid_t(ProcessInfo.processInfo.arguments[2]))
    NSApplication.shared.run()
}
