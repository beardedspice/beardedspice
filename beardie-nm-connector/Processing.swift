//
//  Processing.swift
//  beardie-nm-connector
//
//  Created by Roman Sokolov on 31.12.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa

typealias ExchangeDictionary = [String: Any]

/// Listener for obtaining Native Messaging messages from stdin and responds to stdout
struct MessageProcessing {
    private init(){}
    private static let workQueue = DispatchQueue(label: "MessageProcessingQueue")
    
    // MARK: Public methods
    
    /// Method for processing messages
    static func process(_ message: ExchangeDictionary, replay: @escaping (ExchangeDictionary)->Void) {
        let id = message["id"] as? String
        guard id != nil else {
            return
        }
        if let name = message["msg"] as? String {
            if let cmd = messageName[name] {
                workQueue.async {
                    cmd(message, replay)
                }
            }
        }
    }
}

// MARK: API (declaration)
extension MessageProcessing {
    private static let messageName =
    [
        "bundleId": bundleIdCmd,
        "accepters": acceptersCmd,
        "port": portCmd,
        "serverIsAlive": serverIsAliveCmd
    ]

    private static func responseDictionary(_ message: ExchangeDictionary, response: Any) -> ExchangeDictionary {
        return ["msg": message["msg"]!, "id": message["id"]!, "body": response]
    }
}

// MARK: Message commands implementations
extension MessageProcessing {
    
    private static let ppid = getppid()
    private static let app = NSRunningApplication(processIdentifier: ppid)
    private static let bundleId = app?.bundleIdentifier ?? BS_DEFAULT_CHROME_BUNDLE_ID
    
    typealias RequestFunc = (ExchangeDictionary, @escaping (ExchangeDictionary)->Void)->Void
    
    private static let bundleIdCmd: RequestFunc = { (message, response) in
        BSLog(BSLOG_DEBUG, "Bundle id connected app: \(bundleId)")
        response(responseDictionary(message, response: bundleId))
    }
    
    private static let acceptersCmd: RequestFunc = { (message, response) in
        BSSharedResources.accepters { (accepters) in
            BSLog(BSLOG_DEBUG, "Accepters requested, dict count: \(String(describing: accepters?.count))")
            response(responseDictionary(message, response: accepters ?? [:]))
        }
    }
    
    private static let portCmd: RequestFunc = { (message, response) in
        BSLog(BSLOG_DEBUG, "Port requested, value: \(BSSharedResources.tabPort)")
        response(responseDictionary(message, response: BSSharedResources.tabPort))
    }

    private static let serverIsAliveCmd: RequestFunc = { (message, response) in
        let running = (NSRunningApplication.runningApplications(withBundleIdentifier: BS_BUNDLE_ID).count > 0) && BSSharedResources.tabPort > 0;
        BSLog(BSLOG_DEBUG, "serverIsAlive requested, value: \(running)")
        response(responseDictionary(message, response: running))
    }
}
