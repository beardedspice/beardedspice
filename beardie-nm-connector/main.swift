//
//  main.swift
//  beardie-nm-connector
//
//  Created by Roman Sokolov on 04/11/2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa

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
            //TODO: delete this
            if lenData.count == 0 {
                FileHandle.standardInput.readabilityHandler = nil
            }
            //------------------
            if lenData.count == MemoryLayout<UInt32>.size {
                let len = Int(lenData.withUnsafeBytes { $0.load(as: UInt32.self) })
                let requestData = fl.readData(ofLength: len)
                if requestData.count == len {
                    BSLog(BSLOG_DEBUG, "Message received \(len)bytes length.")
                    do {
                        if let message = try JSONSerialization.jsonObject(with: requestData) as? ExchangeDictionary {
                            // Call request processing
                            MessageProcessing.process(message) { (response) in
                                DispatchQueue.main.async {
                                    BSLog(BSLOG_DEBUG, "Response sending (count: \(response.count))")
                                    _ = send(response)
                                }
                            }
                        }
                    } catch {
                       BSLog(BSLOG_ERROR, "Can't convert browser message to dictionary: \(error)")
                    }
                    
                }
                else {
                    BSLog(BSLOG_ERROR, "Message from browser invalid. Must be \(len)bytes length, but received \(requestData.count)bytes.")
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
            BSLog(BSLOG_ERROR, "Can't convert object to JSON data: \(object)")
            return false
        }
        return true
    }
    
}

// MARK: MAIN
Main.listen()


