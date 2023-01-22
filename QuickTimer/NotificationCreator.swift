//
//  NotificationCreator.swift
//  QuickTimer
//
//  Created by Inder Dhir on 1/22/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Cocoa

final class NotificationModel {
    func show(title: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
