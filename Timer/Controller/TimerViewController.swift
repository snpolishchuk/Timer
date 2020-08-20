//
//  TimerViewController.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 18.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import UIKit

fileprivate typealias K = Constants.TimerViewController

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
    private var timeIntervalsHistory = TimeIntervalHistory()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addGesturesRecognition()
        
        timer.delegate = self
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
    }
    
    // MARK: Button actions
    @IBAction func startPauseButtonPressed(_ sender: Any) {
        startPauseAction()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopAction()
    }
    
    // MARK: Showing alert
    func showAlert(time: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: K.Alert.title, message: K.Alert.message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: K.Alert.cancelButtonTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: K.Alert.saveButtonTitle, style: .default, handler: { _ in
            if let textField = alert.textFields?.first {
                self.saveTimeInterval(name: textField.text ?? "", time: time)
            }
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = K.Alert.textFieldPlaceholder
        })
        
        present(alert, animated: true, completion: completion)
    }
}

extension TimerViewController: TimerTypeDelegate {
    func stateDidChange(state: TimerState) {
        switch state {
        case .none:
            // Next action for a user is to start timer
            startPauseButton.backgroundColor = UIColor.green
            startPauseButton.setTitle(K.startButtonTitle, for: .normal)
        case .running:
            // Next action for a user is to pause timer
            startPauseButton.backgroundColor = UIColor.yellow
            startPauseButton.setTitle(K.pauseButtonTitle, for: .normal)
        case .paused:
            // Next action for a user is to resume timer
            startPauseButton.backgroundColor = UIColor.green
            startPauseButton.setTitle(K.resumeButtonTitle, for: .normal)
        }
    }
    
    func didUpdateTimeInterval(with timeInterval: String) {
        timeLabel.text = timeInterval
    }
 }

// MARK: TableView DataSource & Delegate
extension TimerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeIntervalsHistory.timeIntervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeIntervalData = timeIntervalsHistory.timeIntervals[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableViewCellIdentifier) as! HistoryTableViewCell
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
            timeIntervalsHistory.timeIntervals.remove(at: indexPath.row)
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
        timeLabel.font = UIFont.systemFont(ofSize: CGFloat(K.fontSize))
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
        
        // Set initial titles for buttons
        startPauseButton.setTitle(K.startButtonTitle, for: .normal)
        stopButton.setTitle(K.stopButtonTitle, for: .normal)
    }
    
    // MARK: Timer UI Logic
    func saveTimeInterval(name: String, time: String) {
        timeIntervalsHistory.timeIntervals.append(TimeIntervalEntity(name: name, time: time))
        
        let indexPath = IndexPath(row: timeIntervalsHistory.timeIntervals.count - 1, section: 0)
        
        historyTableView.beginUpdates()
        historyTableView.insertRows(at: [indexPath], with: .automatic)
        historyTableView.endUpdates()
    }
    
    // MARK: Gestures
    func addGesturesRecognition() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func tapped() {
        startPauseAction()
    }
    
    @objc func doubleTapped() {
        stopAction()
    }
    
    // MARK: Timer Actions
    func startPauseAction() {
        timer.startPause()
    }
    
    func stopAction() {
        // Otherwise here is nothing to stop
        if timer.state == .running || timer.state == .paused {
            showAlert(time: timeLabel.text ?? "", completion: {
                self.timer.stop()
            })
        }
    }
}
