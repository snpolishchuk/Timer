//
//  TimeInterval.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

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
