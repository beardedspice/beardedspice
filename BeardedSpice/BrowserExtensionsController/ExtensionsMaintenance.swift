//
//  ExtensionsMaintenance.swift
//  Beardie
//
//  Created by Roman Sokolov on 07.12.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Foundation
import CocoaLumberjack

// MARK: - Protocols
/// Native messaging controller protocol
protocol NativeMessaging {
    static func updateManifest() -> Bool
    static func removeManifest() -> Bool
}

// MARK: - ChromeNativeMessaging
@objc
class ChromeNativeMessaging : NSObject, NativeMessaging {
    
    static private let chromePath = NSString(string: "~/Library/Application Support/Google/Chrome/NativeMessagingHosts/\(BS_NATIVE_MESSAGING_CONNECTOR_BUNDLE_ID).json").expandingTildeInPath
    static private let chromiumPath = NSString(string: "~/Library/Application Support/Chromium/NativeMessagingHosts/\(BS_NATIVE_MESSAGING_CONNECTOR_BUNDLE_ID).json").expandingTildeInPath

    @objc
    static func updateManifest() -> Bool {
        guard let nmPath = ((Bundle.main.executablePath as NSString?)?.deletingLastPathComponent as NSString?)?.appendingPathComponent(BS_NATIVE_MESSAGING_CONNECTOR_NAME) else {
            return false
        }
        let manifest = """
        {
        "name": "\(BS_NATIVE_MESSAGING_CONNECTOR_BUNDLE_ID)",
        "description": "Beardie connector",
        "path": "\(nmPath)",
        "type": "stdio",
        "allowed_origins": [
        "chrome-extension://\(BS_CHROME_EXTENSION_ID)/",
        "chrome-extension://\(BS_CHROME_EXTENSION_ID_DEV)/"
        ]
        }
        """
        var result = true
        let write: (String)->Void = { (aPath: String) in
            do {
                try manifest.write(toFile: aPath, atomically: true, encoding: .utf8)
            } catch  {
                DDLogError("Can't save manifest for \"\(aPath)\": \(error)")
                result = false;
            }
        }
        write(chromePath)
        write(chromiumPath)
        return result
    }
    @objc
    static func removeManifest() -> Bool {
        var result = true
        let remove: (String)->Void = { (aPath: String) in
            do {
                try FileManager.default.removeItem(atPath: aPath)
            } catch  {
                DDLogError("Can't remove manifest for \"\(aPath)\": \(error)")
                result = false;
            }
        }
        remove(chromePath)
        remove(chromiumPath)
        return result
    }
}

// MARK: - ChromeExtensionMaintenance

class ChromeExtensionMaintenance : NSObject {
    
    static private let chromePath = NSString(string: "~/Library/Application Support/Google/Chrome/External Extensions/\(BS_CHROME_EXTENSION_ID).json").expandingTildeInPath
    
    @objc
    static func install() -> Bool {
        let content = """
        {
        "external_update_url": "https://clients2.google.com/service/update2/crx"
        }
        """
        var result = true
        let write: (String)->Void = { (aPath: String) in
            do {
                let folder = (aPath as NSString).deletingLastPathComponent
                try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
                try content.write(toFile: aPath, atomically: true, encoding: .utf8)
            } catch  {
                DDLogError("Can't save extension file for \"\(aPath)\": \(error)")
                result = false;
            }
        }
        write(chromePath)
        return result
    }
    
    @objc
    static func uninstall() -> Bool {
        var result = true
        let remove: (String)->Void = { (aPath: String) in
            do {
                try FileManager.default.removeItem(atPath: aPath)
            } catch  {
                DDLogError("Can't remove extension file for \"\(aPath)\": \(error)")
                result = false;
            }
        }
        remove(chromePath)
        return result
    }
}
