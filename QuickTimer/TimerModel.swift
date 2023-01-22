//
//  TimerModel.swift
//  QuickTimer
//
//  Created by Inder Dhir on 1/22/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

protocol TimerModelDelegate {
    func didUpdateTime(timeRemainingInSeconds: Int)
    func didFinishTimer()
}

final class TimerModel {
    var delegate: TimerModelDelegate?

    private var selectedTimeInSeconds = 60
    private var timeRemainingInSeconds = 60
    private var timer: Timer?
    
    func updateTime(_ seconds: Int) {
        selectedTimeInSeconds = seconds
        resetTime()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerUpdate),
            userInfo: nil,
            repeats: true
        )
        timer?.fire()
    }

    func stopTimer() {
        resetTime()
        timer?.invalidate()
        timer = nil
    }

    @objc func timerUpdate() {
        timeRemainingInSeconds -= 1
        if timeRemainingInSeconds == 0 {
            stopTimer()
            resetTime()

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didFinishTimer()
            }
        }
        else {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.didUpdateTime(timeRemainingInSeconds: self.timeRemainingInSeconds)
            }
        }
    }
    
    private func resetTime() {
        timeRemainingInSeconds = selectedTimeInSeconds
    }
}
