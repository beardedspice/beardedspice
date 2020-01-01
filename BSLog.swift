//
//  File.swift
//  Beardie
//
//  Created by Roman Sokolov on 10.12.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

import Foundation

public func BSLog(_ level: Int32, _ message: @autoclosure () -> String) {
    if (level >= LOG_LEVEL) { NSLog(message()); }
}
