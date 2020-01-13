//
//  GetExtensions.swift
//  Beardie
//
//  Created by Roman Sokolov on 12.01.2020.
//  Copyright © 2020 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa
import SafariServices

class GetExtensions: NSWindowController {

    // MARK: Private properties
    private static let CHROME_WEB_STORE_URL_FORMAT = "https://chrome.google.com/webstore/detail/%@/"
    
    private unowned(unsafe) var parentWindowForSheet: NSWindow? = nil
    private var selfHolder: GetExtensions?

    // MARK: Public methods
    override func windowDidLoad() {
        super.windowDidLoad()
        if (parentWindowForSheet != nil) {
            
            DispatchQueue.main.async {
                self.beginSheetForWindow(self.parentWindowForSheet!)
            }
        }
    }
    
    @objc
    func beginSheetForWindow(_ window: NSWindow) {
        
        self.parentWindowForSheet = window
        
        if self.isWindowLoaded {
            
            self.selfHolder = self
            window.beginSheet(self.window!) {
                _ = $0
                self.window?.orderOut(self)
                self.selfHolder = nil
            }
        }
        else {
            _ = self.window
            
        }
    }

    // MARK: Actions
    
    @IBAction func clickOpenSafariPrefs(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: BS_SAFARI_EXTENSION_BUNDLE_ID) { (error) in
            BSLog(BSLOG_INFO, "Open Safari preferences result: \(String(describing: error))")
            if error == nil {
                DispatchQueue.main.async {
                    self.clickClose(sender)
                }
            }
        }
    }
    
    @IBAction func clickOpenChromeExtensionUrl(_ sender: Any) {
        if let url = URL(string: String(format: GetExtensions.CHROME_WEB_STORE_URL_FORMAT, BS_CHROME_EXTENSION_ID)) {
            let result = NSWorkspace.shared.open(url)
            BSLog(BSLOG_INFO, "Open url to Chrome Web Store result: \(result)")
            if result {
                DispatchQueue.main.async {
                    self.clickClose(sender)
                }
            }
        }
    }
    
    @IBAction func clickClose(_ sender: Any) {
        self.parentWindowForSheet?.endSheet(self.window!)
    }
}
