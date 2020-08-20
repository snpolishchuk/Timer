//
//  Timer.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

fileprivate typealias K = Constants.TimerModel

class TimeCounter: TimerType {
    // MARK: Output
    var state: TimerState = .none {
        didSet {
            delegate?.stateDidChange(state: state)
        }
    }
    weak var delegate: TimerTypeDelegate? {
        didSet {
            resumeCounterIfNeeded(from: startTime)
            resumePauseStateIfNeeded()
        }
    }

    // MARK: Properties
    private var actionTimerState: ActionTimerState = .suspended
    private var startTime: Date? {
        didSet {
            UserDefaults.standard.set(startTime, forKey: K.startTimeKey)
        }
    }
    private var actionTimer: DispatchSourceTimer?
    private var actualTimeInterval: TimeInterval = 0
    // Field needed to perform proper calculation of time after pause. This value is added to the general time interval.
    private var timeIntervalBeforePause: TimeInterval {
        didSet {
            UserDefaults.standard.set(timeIntervalBeforePause, forKey: K.timerIntervalBeforePauseKey)
        }
    }
    
    // MARK: Initialization
    init() {
        startTime = UserDefaults.standard.object(forKey: K.startTimeKey) as? Date
        timeIntervalBeforePause = UserDefaults.standard.double(forKey: K.timerIntervalBeforePauseKey)
    }
    
    deinit {
        actionTimer?.setEventHandler {}
        actionTimer?.cancel()
        actionTimer = nil
    }
    
    // MARK: Input
    func startPause() {
        switch state {
        case .running:
            pause()
        default:
            start()
        }
    }
    
    func stop() {
        state = .none
        
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
    // MARK: TimeCounter actions
    func start() {
        // Start only one timer
        guard actionTimer == nil else { return }
        
        if startTime == nil {
            startTime = Date()
        }
        
        startActionTimer()
    }
    
    func pause() {
        state = .paused
    
        timeIntervalBeforePause = actualTimeInterval
        
        startTime = nil
        
        stopActionTimer()
    }
    
    // MARK: TimeCounter logic
    func updateCounter() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let startTime = self.startTime else { return }
            self.state = .running
            self.actualTimeInterval = Date().timeIntervalSince(startTime) + self.timeIntervalBeforePause
            self.delegate?.didUpdateTimeInterval(with: self.actualTimeInterval.asString)
        }
    }
    
    func resumeCounterIfNeeded(from startTime: Date?) {
        if startTime != nil {
            start()
        }
    }
    
    func resumePauseStateIfNeeded() {
        if timeIntervalBeforePause > 0 {
            state = .paused
            actualTimeInterval = timeIntervalBeforePause
            delegate?.didUpdateTimeInterval(with: self.actualTimeInterval.asString)
        }
    }

    // MARK: ActionTimer actions
    func startActionTimer() {
        actionTimer = DispatchSource.makeTimerSource()
        actionTimer?.setEventHandler(handler: { [weak self] in
            self?.updateCounter()
        })
        actionTimer?.schedule(deadline: .now() + K.timerTimeInterval, repeating: K.timerTimeInterval)
        resumeActionTimer()
    }
    
    func stopActionTimer() {
        guard actionTimerState != .suspended else { return }
        actionTimerState = .suspended
        actionTimer?.cancel()
        actionTimer = nil
    }

    func resumeActionTimer() {
        guard actionTimerState != .resumed else { return }
        actionTimerState = .resumed
        actionTimer?.resume()
    }
}

private extension TimeCounter {
    enum ActionTimerState {
        case suspended
        case resumed
    }
}
