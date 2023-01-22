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

    var isTimerRunning = false
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var startStopMenuItem: NSMenuItem!
    var timeMenuItems: [NSMenuItem] = []
    let viewModel = TimerModel()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        viewModel.delegate = self
        
        setupStatusImage()
        setupMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    @objc func terminate() { NSApp.terminate(self) }
    
    private func setupStatusImage() {
        let image = NSImage(named: "AppIcon")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.imageScaling = .scaleProportionallyDown
    }

    private func setupMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopTimer), keyEquivalent: "S")
        menu.addItem(startStopMenuItem)
        
        menu.addItem(.separator())
        
        timeMenuItems = buildMenuTimeItems()
        timeMenuItems.forEach { menu.addItem($0) }

        menu.addItem(.separator())
        
        menu.addItem(.init(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func buildMenuTimeItems() -> [NSMenuItem] {
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
        
        return [
            oneMinuteMenuItem,
            fiveMinuteMenuItem,
            fifteenMinuteMenuItem,
            thirtyMinuteMenuItem,
            sixtyMinuteMenuItem
        ]
    }
    
    private func timer(_ time: Int){
        let selectedIndex: Int
        let selectedTimeInSeconds: Int
        
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
            selectedTimeInSeconds = 60
            break
        }
        
        viewModel.updateTime(selectedTimeInSeconds)
        updateMenuTimeItem(index: selectedIndex)
    }
    
    private func updateMenuTimeItem(index: Int) {
        timeMenuItems.enumerated().forEach { (i, menuItem) in
            menuItem.state = i == index ? .on : .off
        }
    }
    
    @objc private func startStopTimer() {
        isTimerRunning.toggle()
        
        if isTimerRunning {
            updateStartMenuItemTitle("Stop")
            updateTimerMenuItems(enabled: false)

            viewModel.startTimer()
        } else {
            updateStartMenuItemTitle("Start")
            updateTimerMenuItems(enabled: true)

            viewModel.stopTimer()
        }
    }
    
    @objc private func timer1() { timer(1) }
    @objc private func timer5() { timer(5) }
    @objc private func timer15() { timer(15) }
    @objc private func timer30() { timer(30) }
    @objc private func timer60() { timer(60) }
    
    private func updateStartMenuItemTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.startStopMenuItem.title = title
        }
    }
    
    private func updateTimerMenuItems(enabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.timeMenuItems.forEach { $0.isEnabled = enabled }
        }
    }

    // MARK: NSUserNotificationCenterDelegate

    public func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification
        ) -> Bool {
        true
    }
}

// MARK: TimerModelDelegate

extension AppDelegate: TimerModelDelegate {
    func didUpdateTime(timeRemainingInSeconds: Int) {
        let minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
        let secondsLeftString = String(format: "%02d", timeRemainingInSeconds % 60)
        updateStartMenuItemTitle("Stop (\(minutesLeftString):\(secondsLeftString))")
    }
    
    func didFinishTimer() {
        updateStartMenuItemTitle("Start")
        NotificationModel().show(title: "It's time!")
    }
}
