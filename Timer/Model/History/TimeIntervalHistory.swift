//
//  TimeIntervalHistory.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 19.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import Foundation

struct TimeIntervalHistory: Codable {
    // MARK: Properties
    var timeIntervals = [TimeIntervalEntity]() {
        didSet {
            saveToDocumentDirectory()
        }
    }

    private var json: Data? {
        return try? JSONEncoder().encode(timeIntervals)
    }
    
    // MARK: Initialization
    init() {
        // try to load history from stored JSON file
        if let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("History.json") {
            if let jsonData = try? Data(contentsOf: url) {
                timeIntervals = getHistoryFrom(json: jsonData)
            } else {
                // Use base data
               timeIntervals = [TimeIntervalEntity]()
            }
        }
    }
}

// MARK: Document Directory operations
private extension TimeIntervalHistory {
    // Saving to Document Directory
    func saveToDocumentDirectory() {
        if let json = json {
            if let url = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("History.json") {
                do {
                    try json.write(to: url)
                } catch let error {
                    print("ERROR: Couldn't save history json. - \(error) ")
                }
            }
        }
    }
    
    // Fetching from Document Directory
    func getHistoryFrom(json: Data) -> [TimeIntervalEntity] {
        if let newValue = try? JSONDecoder().decode([TimeIntervalEntity].self, from: json) {
            return newValue
        } else {
            return [TimeIntervalEntity]()
        }
    }
}
