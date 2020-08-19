//
//  TimerType.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

enum TimerState {
     case none
     case running
     case paused
     case stopped
 }

protocol TimerType {
    var state: TimerState { get }
    var delegate: TimerTypeDelegate? { get set }
    func startTimer()
    func pauseTimer()
    func stopTimer()
}

protocol TimerTypeDelegate: class {
    func didUpdateTimeInterval(with timeInterval: String)
}
