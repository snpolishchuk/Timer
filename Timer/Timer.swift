//
//  Timer.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

protocol TimerType {
    var delegate: TimerTypeDelegate? { get set }
    func startTimer()
    func stopTimer()
}

protocol TimerTypeDelegate: class {
    func didUpdateTimeInterval(with timeInterval: String)
}

class TimeCounter: TimerType {
    // MARK: Properties
    weak var delegate: TimerTypeDelegate?
    private var startTime = Date()
    private var actionTimer: Timer?
    
    // MARK: Input
    func startTimer() {
        if actionTimer == nil {
            actionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        actionTimer?.invalidate()
        actionTimer = nil
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: Private methods
    @objc func updateCounter() {
        let timeInterval = Date().timeIntervalSince(startTime)
        delegate?.didUpdateTimeInterval(with: timeInterval.asString)
    }
}

extension TimeInterval {
    var asString: String {
        // Get first two digits after point from double value
        let milliseconds = Int(self.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeIntervalRounded = Int(self)
        let seconds = timeIntervalRounded % 60
        let minutes = (timeIntervalRounded / 60) % 60
        let hours = timeIntervalRounded / 3600
        
        return hours > 0 ?
            String(format: "%0.2d:%0.2d:%0.2d.%0.2d", hours, minutes, seconds, milliseconds) :
            String(format: "%0.2d:%0.2d.%0.2d", minutes, seconds, milliseconds)
    }
}
