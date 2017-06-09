//
//  EventMonitor.swift
//  QuickTimer
//
//  Created by Inder Dhir on 5/30/17.
//  Copyright © 2017 Inder Dhir. All rights reserved.
//

import Foundation
import Cocoa

open class EventMonitor {
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> Void

    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    open func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }

    open func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
