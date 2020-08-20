//
//  Constants+TimerViewController.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 20.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

extension Constants.TimerViewController {
    struct Alert {
        static let title = "Timer stopped"
        static let message = "Please enter a name for time interval to save it."
        static let cancelButtonTitle = "Cancel"
        static let saveButtonTitle = "Save"
        static let textFieldPlaceholder = "Timer name"
    }
    
    static let startButtonTitle = "Start"
    static let pauseButtonTitle = "Pause"
    static let resumeButtonTitle = "Resume"
    static let stopButtonTitle = "Stop"
    static let tableViewCellIdentifier = "TimeInterval"
    
    static let fontName = "Courier"
    static let fontSize = 100
}
