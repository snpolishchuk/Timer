//
//  TimerViewController.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 18.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stopButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var startPauseButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var historyTableView: UITableView!

    // MARK: Properties
    private var timer: TimerType = TimeCounter()
    private var timeObservation: NSKeyValueObservation?
    private var timeIntervalsHistory = [(name: String, time: String)]()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        timer.delegate = self
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        resumeTimerIfNeeded()
    }
    
    // MARK: Button actions
    @IBAction func startPauseButtonPressed(_ sender: Any) {
        switch timer.state {
        case .running:
            timer.pauseTimer()
            
            // Next action for a user is to resume timer
            startPauseButton.backgroundColor = UIColor.green
            startPauseButton.setTitle("Resume", for: .normal)
        default:
            timer.startTimer()
            
            // Next action for a user is to pause timer
            startPauseButton.backgroundColor = UIColor.yellow
            startPauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        if timer.state == .running || timer.state == .paused {
            showAlert(time: timeLabel.text ?? "", completion: {
                self.timer.stopTimer()
                
                // Next action for a user is to start timer
                self.startPauseButton.backgroundColor = UIColor.green
                self.startPauseButton.setTitle("Start", for: .normal)
            })
        }
    }
    
    // MARK: Showing alert
    func showAlert(time: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Timer stopped", message: "Please enter a name for time interval to save it.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let textField = alert.textFields?.first {
                self.saveTimeInterval(name: textField.text ?? "", time: time)
            }
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Timer name"
        })
        
        present(alert, animated: true, completion: completion)
    }
}

extension TimerViewController: TimerTypeDelegate {
    func didUpdateTimeInterval(with timeInterval: String) {
        timeLabel.text = timeInterval
    }
 }

// MARK: TableView DataSource & Delegate
extension TimerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeIntervalsHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeIntervalData = timeIntervalsHistory[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeInterval") as! HistoryTableViewCell
        cell.setup(name: timeIntervalData.name, time: timeIntervalData.time)
        
        return cell
    }
    
    // Support swipe to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            timeIntervalsHistory.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
    }
}

// MARK: Private methods
private extension TimerViewController {
    // MARK: UI Configuration
    func configureUI() {
        // Set large font size to scale to the proper one after viewDidLayoutSubviews
        timeLabel.font = UIFont.systemFont(ofSize: 100)
        timeLabel.numberOfLines = 1
        
        // Actions needed to have time label size scale to the whole screen width on all devices
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.1
        
        adjustButtons()
    }
    
    func adjustButtons() {
        // Adjust button sizes to fit text
        let startButtonWidth = startPauseButton.intrinsicContentSize.width
        let stopButtonWidth = stopButton.intrinsicContentSize.width
        let maxWidth = startButtonWidth > stopButtonWidth ? startButtonWidth : stopButtonWidth
        startPauseButtonWidthConstraint.constant = maxWidth
        stopButtonWidthConstraint.constant = maxWidth
        
        // Make buttons round
        startPauseButton.layer.cornerRadius = startPauseButton.frame.size.height / 2
        stopButton.layer.cornerRadius = startPauseButton.frame.size.height / 2
        
        // Set titles for buttons
        startPauseButton.setTitle("Start", for: .normal)
        stopButton.setTitle("Stop", for: .normal)
    }
    
    // MARK: Timer UI Logic
    func saveTimeInterval(name: String, time: String) {
        timeIntervalsHistory.append((name: name, time: time))
        
        let indexPath = IndexPath(row: timeIntervalsHistory.count - 1, section: 0)
        
        historyTableView.beginUpdates()
        historyTableView.insertRows(at: [indexPath], with: .automatic)
        historyTableView.endUpdates()
    }
    
    func resumeTimerIfNeeded() {
//        if timer.
    }
}
