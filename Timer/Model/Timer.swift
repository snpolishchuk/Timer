//
//  Timer.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

class TimeCounter: TimerType {
    // MARK: Output
    var state: TimerState = .none
    weak var delegate: TimerTypeDelegate?

    // MARK: Properties
    private var startTime: Date? {
        didSet {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        }
    }
    private var actionTimer: Timer?
    private var actualTimeInterval: TimeInterval = 0
    // Field needed to perform proper calculation of time after pause. This value is added to the general time interval.
    private var timeIntervalBeforePause: TimeInterval = 0
    
    // MARK: Initialization
    init() {
        startTime = UserDefaults.standard.object(forKey: "startTime") as? Date
        resumeCounterIfNeeded(from: startTime)
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: Input
    func startTimer() {
        // Start only one timer
        guard actionTimer == nil else { return }
        
        if startTime == nil {
            startTime = Date()
        }
        
        state = .running
        actionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        state = .paused
    
        timeIntervalBeforePause = actualTimeInterval
        self.startTime = nil
        
        stopActionTimer()
    }
    
    func stopTimer() {
        state = .stopped
        
        // Reset time
        actualTimeInterval = 0
        delegate?.didUpdateTimeInterval(with: actualTimeInterval.asString)
        
        // Cleaning
        stopActionTimer()
        timeIntervalBeforePause = 0
        startTime = nil
    }
}

// MARK: Private methods
private extension TimeCounter {
    @objc func updateCounter() {
        guard let startTime = self.startTime else { return }
        actualTimeInterval = Date().timeIntervalSince(startTime) + timeIntervalBeforePause
        delegate?.didUpdateTimeInterval(with: actualTimeInterval.asString)
    }
    
    func stopActionTimer() {
        if actionTimer != nil {
            actionTimer?.invalidate()
            actionTimer = nil
        }
    }

    func resumeCounterIfNeeded(from startTime: Date?) {
        if startTime != nil {
            startTimer()
        }
    }
}
