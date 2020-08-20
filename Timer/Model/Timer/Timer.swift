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
    var state: TimerState = .none {
        didSet {
            delegate?.stateDidChange(state: state)
        }
    }
    weak var delegate: TimerTypeDelegate?

    // MARK: Properties
    private var actionTimerState: ActionTimerState = .suspended
    private var startTime: Date? {
        didSet {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        }
    }
    private var actionTimer: DispatchSourceTimer?
    private var actualTimeInterval: TimeInterval = 0
    // Field needed to perform proper calculation of time after pause. This value is added to the general time interval.
    private var timeIntervalBeforePause: TimeInterval = 0
    
    // MARK: Initialization
    init() {
        startTime = UserDefaults.standard.object(forKey: "startTime") as? Date
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
    // MARK: Timer actions
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
    
    // MARK: Timer logic
    func updateCounter() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let startTime = self.startTime else { return }
            self.state = .running
            self.actualTimeInterval = Date().timeIntervalSince(startTime) + self.timeIntervalBeforePause
            self.delegate?.didUpdateTimeInterval(with: self.actualTimeInterval.asString)
        }
    }
    
    func startActionTimer() {
        actionTimer = DispatchSource.makeTimerSource()
        actionTimer?.setEventHandler(handler: { [weak self] in
            self?.updateCounter()
        })
        actionTimer?.schedule(deadline: .now() + TimeCounter.timerTimeInterval, repeating: TimeCounter.timerTimeInterval)
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

// MARK: Constants
extension TimeCounter {
    static let timerTimeInterval = 0.01
}

private extension TimeCounter {
    enum ActionTimerState {
        case suspended
        case resumed
    }
}
