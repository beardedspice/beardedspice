//
//  GetExtensions.swift
//  Beardie
//
//  Created by Roman Sokolov on 12.01.2020.
//  Copyright © 2020 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Cocoa

class GetExtensions: NSWindowController {

    // MARK: Private properties
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
    }
    
    @IBAction func clickOpenChromeExtensionUrl(_ sender: Any) {
    }
    
    @IBAction func clickClose(_ sender: Any) {
        self.parentWindowForSheet?.endSheet(self.window!)
    }
}
