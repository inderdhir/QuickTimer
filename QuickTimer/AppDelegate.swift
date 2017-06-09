//
//  AppDelegate.swift
//  QuickTimer
//
//  Created by Inder Dhir on 5/24/17.
//  Copyright © 2017 Inder Dhir. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let popover = NSPopover()
    let startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopTimer), keyEquivalent: "S")
    var eventMonitor: EventMonitor?
    var timeMenuItems: [NSMenuItem]?
    var isTimerRunning = false
    var oneMinuteMenuItem: NSMenuItem?
    var twoMinuteMenuItem: NSMenuItem?
    var fiveMinuteMenuItem: NSMenuItem?
    var timeRemainingInSeconds = 1
    var currentSelectedTime: Int?
    var currentSelectedInterval: TimeInterval?
    var timer: Timer?
    var minutesLeftString = ""
    var secondsLeftString = ""
    var darkMode = false
    var timerRunningImage: NSImage?
    var timerStoppedImage: NSImage?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkMode = (appearance == "Dark")

        timerStoppedImage = darkMode ? NSImage(named: "AppIconDark") : NSImage(named: "AppIcon")
        timerRunningImage = darkMode ? NSImage(named: "TimerRunningDark") : NSImage(named: "TimerRunning")

        updateTimerIcon()

        // Menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(startStopMenuItem)
        menu.addItem(NSMenuItem.separator())

        oneMinuteMenuItem = NSMenuItem(title: "1 min", action: #selector(timer1), keyEquivalent: "1")
        oneMinuteMenuItem?.state = NSOnState
        oneMinuteMenuItem?.isEnabled = true
        currentSelectedTime = 1
        currentSelectedInterval = 60
        timeRemainingInSeconds = 60

        twoMinuteMenuItem = NSMenuItem(title: "2 min", action: #selector(timer2), keyEquivalent: "2")
        twoMinuteMenuItem?.isEnabled = true

        fiveMinuteMenuItem = NSMenuItem(title: "5 min", action: #selector(timer5), keyEquivalent: "5")
        fiveMinuteMenuItem?.isEnabled = true

        timeMenuItems = [NSMenuItem]()
        timeMenuItems?.append(oneMinuteMenuItem!)
        timeMenuItems?.append(twoMinuteMenuItem!)
        timeMenuItems?.append(fiveMinuteMenuItem!)

        menu.addItem(oneMinuteMenuItem!)
        menu.addItem(twoMinuteMenuItem!)
        menu.addItem(fiveMinuteMenuItem!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))

        statusItem.menu = menu

        // Event monitor to listen for clicks outside the popover
        eventMonitor = EventMonitor(mask: NSEventMask.leftMouseDown) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func timer1() {
        timer(1)
    }

    func timer2() {
        timer(2)
    }

    func timer5() {
        timer(5)
    }

    func timer(_ time: Int){
        switch time {
        case 1:
            oneMinuteMenuItem?.state = NSOnState
            twoMinuteMenuItem?.state = NSOffState
            fiveMinuteMenuItem?.state = NSOffState

            currentSelectedTime = 1
            currentSelectedInterval = 60
            timeRemainingInSeconds = 60
        case 2:
            oneMinuteMenuItem?.state = NSOffState
            twoMinuteMenuItem?.state = NSOnState
            fiveMinuteMenuItem?.state = NSOffState

            currentSelectedTime = 2
            currentSelectedInterval = 120
            timeRemainingInSeconds = 120
        case 5:
            oneMinuteMenuItem?.state = NSOffState
            twoMinuteMenuItem?.state = NSOffState
            fiveMinuteMenuItem?.state = NSOnState

            currentSelectedTime = 5
            currentSelectedInterval = 300
            timeRemainingInSeconds = 300
        default:
            break
        }
    }

    func startStopTimer() {
        isTimerRunning = !isTimerRunning
        isTimerRunning ? startTimer() : stopTimer()
        updateTimerIcon()
    }

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

    private func updateTimerIcon() {
        statusItem.button?.image = isTimerRunning ? timerRunningImage : timerStoppedImage
        statusItem.button?.imageScaling = NSImageScaling.scaleProportionallyDown
    }


    func timerUpdate() {
        timeRemainingInSeconds -= 1
        if timeRemainingInSeconds == 0 {
            stopTimer()
        }
        else {
            minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
            secondsLeftString = String(timeRemainingInSeconds % 60)
            startStopMenuItem.title = "Stop (\(minutesLeftString):\(secondsLeftString))"
        }
    }

    func terminate() {

    }

    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }

    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

