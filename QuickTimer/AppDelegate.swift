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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopTimer), keyEquivalent: "S")
    var timeMenuItems: [NSMenuItem]!
    var isTimerRunning = false
    var selectedTimeInSeconds = 60
    var timeRemainingInSeconds = 60
    var timer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let image = NSImage(named: "AppIcon")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.imageScaling = .scaleProportionallyDown

        // Menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(startStopMenuItem)
        menu.addItem(.separator())

        let oneMinuteMenuItem = NSMenuItem(title: "1 min", action: #selector(timer1), keyEquivalent: "1")
        oneMinuteMenuItem.state = .on
        oneMinuteMenuItem.isEnabled = true
        let fiveMinuteMenuItem = NSMenuItem(title: "5 min", action: #selector(timer5), keyEquivalent: "2")
        fiveMinuteMenuItem.isEnabled = true
        let fifteenMinuteMenuItem = NSMenuItem(title: "15 min", action: #selector(timer15), keyEquivalent: "3")
        fifteenMinuteMenuItem.isEnabled = true
        let thirtyMinuteMenuItem = NSMenuItem(title: "30 min", action: #selector(timer30), keyEquivalent: "4")
        thirtyMinuteMenuItem.isEnabled = true
        let sixtyMinuteMenuItem = NSMenuItem(title: "60 min", action: #selector(timer60), keyEquivalent: "5")
        sixtyMinuteMenuItem.isEnabled = true

        timeMenuItems = [oneMinuteMenuItem, fiveMinuteMenuItem, fifteenMinuteMenuItem, thirtyMinuteMenuItem, sixtyMinuteMenuItem]

        menu.addItem(oneMinuteMenuItem)
        menu.addItem(fiveMinuteMenuItem)
        menu.addItem(fifteenMinuteMenuItem)
        menu.addItem(thirtyMinuteMenuItem)
        menu.addItem(sixtyMinuteMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    // MARK: Selectors

    @objc func timer1() { timer(1) }

    @objc func timer5() { timer(5) }

    @objc func timer15() { timer(15) }

    @objc func timer30() { timer(30) }

    @objc func timer60() { timer(60) }

    func timer(_ time: Int){
        let selectedIndex: Int
        switch time {
        case 1:
            selectedIndex = 0
            selectedTimeInSeconds = 60
        case 5:
            selectedIndex = 1
            selectedTimeInSeconds = 300
        case 15:
            selectedIndex = 2
            selectedTimeInSeconds = 900
        case 30:
            selectedIndex = 3
            selectedTimeInSeconds = 1800
        case 60:
            selectedIndex = 4
            selectedTimeInSeconds = 3600
        default:
            selectedIndex = 0
            break
        }
        timeRemainingInSeconds = selectedTimeInSeconds

        for (index, menuItem) in timeMenuItems.enumerated() {
            menuItem.state = index == selectedIndex ? .on : .off
        }
    }

    @objc func startStopTimer() {
        isTimerRunning = !isTimerRunning
        isTimerRunning ? startTimer() : stopTimer()
    }

    @objc func timerUpdate() {
        timeRemainingInSeconds -= 1
        if timeRemainingInSeconds == 0 {
            stopTimer()
            displayNotification()

            timeRemainingInSeconds = selectedTimeInSeconds
        }
        else {
            let minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
            let secondsLeftString = String(format: "%02d", timeRemainingInSeconds % 60)
            startStopMenuItem.title = "Stop (\(minutesLeftString):\(secondsLeftString))"
        }
    }

    @objc func terminate() { NSApp.terminate(self) }

    // MARK: Private methods

    private func startTimer() {
        startStopMenuItem.title = "Stop"
        timeMenuItems.forEach { $0.isEnabled = false }
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerUpdate),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer { RunLoop.main.add(timer, forMode: .common) }
    }

    private func stopTimer() {
        startStopMenuItem.title = "Start"
        timeMenuItems.forEach { $0.isEnabled = true }
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

    public func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification
        ) -> Bool {
        return true
    }
}

