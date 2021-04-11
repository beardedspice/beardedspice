//
//  main.swift
//  beardie-nm-connector
//
//  Created by Roman Sokolov on 04/11/2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa
import CocoaLumberjack

struct Main {
    /// Prevents instantiating
    private init(){}
    private static let RUNLOOP_TIMEOUT: TimeInterval = 5
    
    // MARK: Public funcs
    
    /// Defines listener for stdin
    static func listen() {
        // Read handler for stdin
        FileHandle.standardInput.readabilityHandler = { (fl: FileHandle) in
            let lenData = fl.readData(ofLength: 4)
            if lenData.count == MemoryLayout<UInt32>.size {
                let len = Int(lenData.withUnsafeBytes { $0.load(as: UInt32.self) })
                let requestData = fl.readData(ofLength: len)
                if requestData.count == len {
                    DDLogDebug("Message received \(len)bytes length.")
                    do {
                        if let message = try JSONSerialization.jsonObject(with: requestData) as? ExchangeDictionary {
                            // Call request processing
                            MessageProcessing.process(message) { (response) in
                                DispatchQueue.main.async {
                                    DDLogDebug("Response sending (count: \(response.count))")
                                    _ = send(response)
                                }
                            }
                        }
                    } catch {
                       DDLogError("Can't convert browser message to dictionary: \(error)")
                    }
                    
                }
                else {
                    DDLogError("Message from browser invalid. Must be \(len)bytes length, but received \(requestData.count)bytes.")
                }
            }
        }
        while FileHandle.standardInput.readabilityHandler != nil {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: RUNLOOP_TIMEOUT))
        }
    }
    
    /// Sends `dictionary` to stdout as JSON data in UTF-8 encoding (NM protocol)
    /// - Parameter object: Dictionary
    static func send(_ object: ExchangeDictionary) -> Bool {
        do {
            if JSONSerialization.isValidJSONObject(object) {
                let data = try JSONSerialization.data(withJSONObject: object)
                var len = UInt32(data.count)
                FileHandle.standardOutput.write(Data(bytes: &len, count: MemoryLayout<UInt32>.size))
                FileHandle.standardOutput.write(data)
            }
        } catch {
            DDLogError("Can't convert object to JSON data: \(object)")
            return false
        }
        return true
    }
    
}

BSSharedResources.initLogger(for: BS_B_NATIVE_MESSAGING_CONNECTOR_BUNDLE_ID)

// MARK: MAIN
Main.listen()

