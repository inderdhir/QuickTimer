//
//  AppDelegate.swift
//  QuickTimer
//
//  Created by Inder Dhir on 5/24/17.
//  Copyright © 2017 Inder Dhir. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopTimer), keyEquivalent: "S")
    var timeMenuItems: [NSMenuItem]?
    var isTimerRunning = false
    var oneMinuteMenuItem: NSMenuItem?
    var fiveMinuteMenuItem: NSMenuItem?
    var fifteenMinuteMenuItem: NSMenuItem?
    var thirtyMinuteMenuItem: NSMenuItem?
    var sixtyMinuteMenuItem: NSMenuItem?
    var selectedTimeInSeconds = 1
    var timeRemainingInSeconds = 1
    var timer: Timer?
    var minutesLeftString = ""
    var secondsLeftString = ""

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.image = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ?
            NSImage(named: "AppIconDark") : NSImage(named:"AppIcon")
        statusItem.button?.imageScaling = NSImageScaling.scaleProportionallyDown

        // Menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(startStopMenuItem)
        menu.addItem(NSMenuItem.separator())

        oneMinuteMenuItem = NSMenuItem(title: "1 min", action: #selector(timer1), keyEquivalent: "1")
        oneMinuteMenuItem?.state = NSOnState
        oneMinuteMenuItem?.isEnabled = true
        timeRemainingInSeconds = 60
        fiveMinuteMenuItem = NSMenuItem(title: "5 min", action: #selector(timer5), keyEquivalent: "2")
        fiveMinuteMenuItem?.isEnabled = true
        fifteenMinuteMenuItem = NSMenuItem(title: "15 min", action: #selector(timer15), keyEquivalent: "3")
        fifteenMinuteMenuItem?.isEnabled = true
        thirtyMinuteMenuItem = NSMenuItem(title: "30 min", action: #selector(timer30), keyEquivalent: "4")
        thirtyMinuteMenuItem?.isEnabled = true
        sixtyMinuteMenuItem = NSMenuItem(title: "60 min", action: #selector(timer60), keyEquivalent: "5")
        sixtyMinuteMenuItem?.isEnabled = true

        timeMenuItems = [NSMenuItem]()
        timeMenuItems?.append(oneMinuteMenuItem!)
        timeMenuItems?.append(fiveMinuteMenuItem!)
        timeMenuItems?.append(fifteenMinuteMenuItem!)
        timeMenuItems?.append(thirtyMinuteMenuItem!)
        timeMenuItems?.append(sixtyMinuteMenuItem!)

        menu.addItem(oneMinuteMenuItem!)
        menu.addItem(fiveMinuteMenuItem!)
        menu.addItem(fifteenMinuteMenuItem!)
        menu.addItem(thirtyMinuteMenuItem!)
        menu.addItem(sixtyMinuteMenuItem!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: Selectors

    func timer1() {
        timer(1)
    }

    func timer5() {
        timer(5)
    }

    func timer15() {
        timer(15)
    }

    func timer30() {
        timer(30)
    }

    func timer60() {
        timer(60)
    }

    func timer(_ time: Int){
        var selectedIndex = 0
        switch time {
        case 1:
            selectedTimeInSeconds = 60
        case 5:
            selectedIndex = 1
            selectedTimeInSeconds = 120
        case 15:
            selectedIndex = 2
            selectedTimeInSeconds = 120
        case 30:
            selectedIndex = 3
            selectedTimeInSeconds = 120
        case 60:
            selectedIndex = 4
            selectedTimeInSeconds = 120
        default:
            break
        }
        timeRemainingInSeconds = selectedTimeInSeconds

        for (index, menuItem) in timeMenuItems!.enumerated() {
            menuItem.state = index == selectedIndex ? NSOnState : NSOffState
        }
    }

    func startStopTimer() {
        isTimerRunning = !isTimerRunning
        isTimerRunning ? startTimer() : stopTimer()
    }

    func timerUpdate() {
        timeRemainingInSeconds -= 1
        if timeRemainingInSeconds == 0 {
            timeRemainingInSeconds = selectedTimeInSeconds

            stopTimer()
            displayNotification()
        }
        else {
            minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
            secondsLeftString = String(timeRemainingInSeconds % 60)
            startStopMenuItem.title = "Stop (\(minutesLeftString):\(secondsLeftString))"
        }
    }

    func terminate() {
        NSApp.terminate(self)
    }

    // MARK: Private methods

    private func startTimer() {
        startStopMenuItem.title = "Stop"
        for item in timeMenuItems! {
            item.isEnabled = false
        }

        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }

    private func stopTimer() {
        startStopMenuItem.title = "Start"
        for item in timeMenuItems! {
            item.isEnabled = true
        }

        timer?.invalidate()
        timer = nil
    }

    private func displayNotification() {
        let notification = NSUserNotification()
        notification.title = "It's time!"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }


    // MARK: NSUserNotificationCenterDelegate

    public func userNotificationCenter(_ center: NSUserNotificationCenter,
                                                  shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

